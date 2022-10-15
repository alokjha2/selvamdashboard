import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:selvam_broilers/models/collection_agent.dart';
import 'package:selvam_broilers/models/driver.dart';
import 'package:selvam_broilers/models/farm.dart';
import 'package:selvam_broilers/models/loadman.dart';
import 'package:selvam_broilers/models/purchase_order.dart';
import 'package:selvam_broilers/models/route.dart';
import 'package:selvam_broilers/models/sale_order.dart';
import 'package:selvam_broilers/models/shop.dart';
import 'package:selvam_broilers/models/shop_payment.dart';
import 'package:selvam_broilers/models/trip.dart';
import 'package:selvam_broilers/models/vehicle.dart';
import 'package:selvam_broilers/services/routes_db.dart';
import 'package:selvam_broilers/services/shops_db.dart';
import 'package:selvam_broilers/services/storage.dart';
import 'package:selvam_broilers/utils/flags.dart';
import 'package:intl/intl.dart';
import 'package:selvam_broilers/utils/utils.dart';
import '../models/direct_sale.dart';
import 'farm_db.dart';

class ReportDatabase {
  Storage storage = Storage();
  static final ReportDatabase _databaseInstance = ReportDatabase._();

  factory ReportDatabase() {
    return _databaseInstance;
  }

  ReportDatabase._();

  Future<Map> getSaleReport({
    Shop? shop,
    TripRoute? route,
    Driver? driver,
    LoadMan? loadMan,
    Vehicle? vehicle,
    DateTime? startDate,
    DateTime? endDate,
    required List<Shop> shopList,
    required List<TripRoute> routeList,
    required int salesType,
  }) async {
    var header = [
      'Sl\nNo',
      'Order Id',
      'Shop Name',
      'Date & Time',
      'Area Name',
      'Items',
      'Volume'
    ];

    // try {
    Query saleOrderQuery = FirebaseFirestore.instance
        .collection('sale_orders')
        .where('orderStatus', isEqualTo: OrderStatus.COMPLETED.index);

    Query dSaleQuery = FirebaseFirestore.instance.collection('direct_sales');

    if (shop != null) {
      saleOrderQuery = saleOrderQuery.where('shopID', isEqualTo: shop.docID);
      dSaleQuery = dSaleQuery.where('shopID', isEqualTo: shop.docID);
    }

    if (route != null) {
      saleOrderQuery = saleOrderQuery.where('routeID', isEqualTo: route.docID);
    }

    if (startDate != null && endDate != null) {
      saleOrderQuery = saleOrderQuery.where('completedTime',
          isGreaterThanOrEqualTo: startDate, isLessThan: endDate);

      dSaleQuery = dSaleQuery.where('createdTime',
          isGreaterThanOrEqualTo: startDate, isLessThan: endDate);
    }

    if (driver != null) {
      saleOrderQuery =
          saleOrderQuery.where('driverID', isEqualTo: driver.docID);
    }

    if (vehicle != null) {
      saleOrderQuery =
          saleOrderQuery.where('vehicleID', isEqualTo: vehicle.docID);
    }

    if (loadMan != null) {
      saleOrderQuery =
          saleOrderQuery.where('loadManIDs', arrayContains: loadMan.docID);
    }

    saleOrderQuery = saleOrderQuery.orderBy('completedTime', descending: true);
    dSaleQuery = dSaleQuery.orderBy('createdTime', descending: true);

    var saleOrderSnap = await saleOrderQuery.get();
    var directSaleSnap = await dSaleQuery.get();

    List<DirectSale> directSalesList = [];
    directSaleSnap.docs.forEach((doc) {
      directSalesList.add(DirectSale.fromFirestore(doc));
    });

    List<SaleOrder> saleOrderList = [];
    saleOrderSnap.docs.forEach((doc) {
      saleOrderList.add(SaleOrder.fromFirestore(doc));
    });

    int i = 0;
    double kgTotal = 0;
    double amountTotal = 0;
    int size = 0;
    if (salesType == 1 || salesType == 2) {
      size += saleOrderSnap.size;
    }
    if (salesType == 1 || salesType == 3) {
      size += directSaleSnap.size;
    }

    List<List<dynamic>> twoDList = List.generate(
        size, (i) => List.filled(header.length, '', growable: false),
        growable: false);

    if (salesType == 1 || salesType == 2) {
      for (SaleOrder order in saleOrderList) {
        var shops = shopList.where((element) => element.docID == order.shopID);
        Shop? shop;
        if (shops.isNotEmpty) {
          shop = shops.first;
        }
        TripRoute? route;
        var routes =
            routeList.where((element) => element.docID == order.routeID);
        if (routes.isNotEmpty) {
          route = routes.first;
        }

        twoDList[i][0] = (i + 1).toString();
        twoDList[i][1] = '${order.orderID}\n(Delivery)';
        if (shop == null) {
          twoDList[i][2] = '';
        } else {
          twoDList[i][2] = shop.shopName;
        }
        twoDList[i][3] = order.completedTime;
        // ('d MMM, yyyy\nhh:mm aa').format(order.completedTime!).toString();
        if (route == null) {
          twoDList[i][4] = '';
        } else {
          twoDList[i][4] = '${route.routeName}\n(${route.routeNumber})';
        }

        String items = '';
        if (order.deliveredRegularInKG! > 0) {
          items +=
              'Regular - ${order.deliveredRegularInKG?.toStringAsFixed(2)} KG\n';
        }

        if (order.deliveredSmallInKG! > 0) {
          items += 'Small - ${order.deliveredSmallInKG?.toStringAsFixed(2)} KG';
        }

        twoDList[i][5] = items;
        twoDList[i][6] = '${order.kgTotal?.toStringAsFixed(2)} KG';

        kgTotal += (order.kgTotal ?? 0);
        amountTotal += (order.netTotal ?? 0);
        i++;
      }
    }

    // i = 0;
    if (salesType == 1 || salesType == 3) {
      for (var order in directSalesList) {
        var shops = shopList.where((element) => element.docID == order.shopID);
        Shop? shop;
        if (shops.isNotEmpty) {
          shop = shops.first;
        }
        TripRoute? route;
        var routes =
            routeList.where((element) => element.docID == order.routeID);
        if (routes.isNotEmpty) {
          route = routes.first;
        }

        twoDList[i][0] = (i + 1).toString();
        twoDList[i][1] = '${order.orderID}\n(Store Sale)';
        if (shop == null) {
          twoDList[i][2] = '';
        } else {
          twoDList[i][2] = shop.shopName;
        }
        twoDList[i][3] = order.createdTime;
        // DateFormat('d MMM, yyyy\nhh:mm aa').format(order.createdTime).toString();
        if (route == null) {
          twoDList[i][4] = '';
        } else {
          twoDList[i][4] = '${route.routeName}\n(${route.routeNumber})';
        }
        String items = '';
        double totalKGDelivered = 0;
        order.deliveryDetails.forEach((key, value) {
          if (value['kg'] > 0 || value['count'] > 0)
            items +=
                '$key - ${(value['kg']).toStringAsFixed(2)} KG x ${(value['rate']).toStringAsFixed(2)}\n';
          totalKGDelivered += value['kg'];
        });

        twoDList[i][5] = items;
        twoDList[i][6] = '${totalKGDelivered.toStringAsFixed(2)} KG';

        kgTotal += totalKGDelivered;
        amountTotal += (order.netTotal ?? 0);
        i++;
      }
    }

    int comparisonIndex = 3;

    List<List<dynamic>> sortedList = twoDList
      ..sort((y, x) => (x[comparisonIndex] as dynamic)
          .compareTo((y[comparisonIndex] as dynamic)));

    sortedList.forEach((row) {
      row[comparisonIndex] =
          getFormattedDateTime(row[comparisonIndex], 'd MMM, yyyy\nhh:mm aa');
    });

//////////////////////

    return {
      'data': sortedList,
      'header': header,
      'kgTotal': kgTotal,
      'amountTotal': amountTotal
    };
    // } catch (err) {
    //   print(err);
    //   return {'data': [], 'header': header};
    // }
  }

  Future<Map> getPurchaseReport(
      {Farm? farm,
      TripRoute? route,
      Driver? driver,
      LoadMan? loadMan,
      Vehicle? vehicle,
      DateTime? startDate,
      DateTime? endDate,
      required List<Farm> farmList}) async {
    var header = [
      'Sl\nNo',
      'Order Id',
      'Farm Name',
      'Date & Time',
      'Area Name',
      'Purchased\nItems',
      'Total\nDelivered'
    ];

    try {
      Query query = FirebaseFirestore.instance
          .collection('purchase_orders')
          .where('orderStatus', isEqualTo: OrderStatus.COMPLETED.index);

      if (farm != null) {
        query = query.where('farmID', isEqualTo: farm.docID);
      }

      if (route != null) {
        query = query.where('routeID', isEqualTo: route.docID);
      }

      if (startDate != null && endDate != null) {
        query = query.where('completedTime',
            isGreaterThanOrEqualTo: startDate, isLessThan: endDate);
      }

      if (driver != null) {
        query = query.where('driverID', isEqualTo: driver.docID);
      }

      if (vehicle != null) {
        query = query.where('vehicleID', isEqualTo: vehicle.docID);
      }

      if (loadMan != null) {
        query = query.where('loadManIDs', arrayContains: loadMan.docID);
      }

      query = query.orderBy('completedTime', descending: true);

      var snap = await query.get();

      List twoDList = List.generate(
          snap.size, (i) => List.filled(header.length, '', growable: false),
          growable: false);

      int i = 0;
      double kgTotal = 0;
      double amountTotal = 0;
      for (var doc in snap.docs) {
        PurchaseOrder order = PurchaseOrder.fromFirestore(doc);
        Farm? farm;
        var list =
            farmList.where((element) => element.docID == order.farmID).toList();
        if (list.isNotEmpty) {
          farm = list.first;
        }

        TripRoute? route = await _fetchRouteInfo(order.routeID);
        twoDList[i][0] = (i + 1).toString();
        twoDList[i][1] = order.orderID.toString();
        if (farm == null) {
          twoDList[i][2] = '[DELETED]';
        } else {
          twoDList[i][2] = farm.farmName;
        }
        twoDList[i][3] = DateFormat('d MMM, yyyy\nhh:mm aa')
            .format(order.createdTime)
            .toString();
        if (route == null) {
          twoDList[i][4] = '[DELETED]';
        } else {
          twoDList[i][4] = '${route.routeName}\n(${route.routeNumber})';
        }

        String items = '';
        if (order.pickupRegularInKG! > 0) {
          items += 'Regular - ${order.pickupRegularInKG!} KG\n';
        }
        if (order.pickupSmallInKG! > 0) {
          items += 'Small - ${order.pickupSmallInKG!} KG';
        }

        twoDList[i][5] = items;
        twoDList[i][6] = '${order.kgTotal?.toStringAsFixed(2)} KG';
        kgTotal += (order.kgTotal ?? 0);
        amountTotal += (order.purchasePrice ?? 0);
        i++;
      }
      return {
        'data': twoDList,
        'header': header,
        'kgTotal': kgTotal,
        'amountTotal': amountTotal
      };
    } catch (err) {
      print(err);
      return {'data': [], 'header': header};
    }
  }

  Future<Map> getPaymentReport({
    required List<Shop> shopList,
    required List<CollectionAgent> agentList,
    required List<Driver> driverList,
    required List<PaymentMode> paymentModes,
    required Driver? driver,
    required CollectionAgent? agent,
    required PaidTo? paidTo,
    required Shop? shop,
    required DateTime? startDate,
    required DateTime? endDate,
  }) async {
    var header = [
      'Sl\nNo',
      'Shop Name',
      'Date\nTime',
      'Payment\nmode(s)',
      'Paid to',
      'Amount',
      'Closing\nBalance'
    ];

    // try {
    Query query = FirebaseFirestore.instance.collectionGroup('payments');

    if (shop != null) {
      query = query.where('shopID', isEqualTo: shop.docID);
    }

    if (paidTo != null) {
      print('filter += paidTo');
      query = query.where('paidTo', isEqualTo: paidTo.index);
      if (agent != null) {
        print('filter += agentID');
        query = query.where('agentID', isEqualTo: agent.docID);
      }

      if (driver != null) {
        print('filter += driverID');
        query = query.where('driverID', isEqualTo: driver.docID);
      }
    }

    if (startDate != null && endDate != null) {
      print('filter += paymentTime');
      query = query.where('paymentTime',
          isGreaterThanOrEqualTo: startDate, isLessThan: endDate);
    }
    query = query.orderBy('paymentTime', descending: true);

    var snap = await query.get();

    List<ShopPayment> payments = [];
    for (var doc in snap.docs) {
      ShopPayment payment = ShopPayment.fromFirestore(doc);

      if (paymentModes.isNotEmpty) {
        if (!payment.paymentModes
            .any((element) => paymentModes.contains(element))) {
          continue;
        }
      }
      payments.add(payment);
    }

    List twoDList = List.generate(
        payments.length, (i) => List.filled(header.length, '', growable: false),
        growable: false);

    int i = 0;
    double amountTotal = 0;
    for (var payment in payments) {
      var shops = shopList.where((element) => element.docID == payment.shopID);
      twoDList[i][0] = (i + 1).toString();
      twoDList[i][1] = shops.isEmpty ? ' - ' : shops.first.shopName;

      twoDList[i][2] = DateFormat('d MMM, yyyy(EEE)\nhh:mm aa')
          .format(payment.paymentTime)
          .toString();

      String paidTo = '';
      if (payment.paidTo == PaidTo.ADMIN) {
        paidTo = 'Admin';
      } else if (payment.paidTo == PaidTo.COLLECTOR) {
        var list =
            agentList.where((element) => element.docID == payment.agentID);
        if (list.isNotEmpty) paidTo = list.first.fullName + '\n(Agent)';
      } else if (payment.paidTo == PaidTo.COLLECTOR) {
        var list =
            driverList.where((element) => element.docID == payment.driverID);
        if (list.isNotEmpty) paidTo = list.first.fullName + '\n(Driver)';
      }

      twoDList[i][3] = getPaymentText(payment.paymentModes);
      twoDList[i][4] = paidTo;
      twoDList[i][5] = 'Rs. ${payment.totalAmount.toStringAsFixed(2)}';
      twoDList[i][6] = 'Rs. ${payment.closingBalance?.toStringAsFixed(2)}';

      amountTotal += payment.totalAmount;
      i++;
    }
    return {'data': twoDList, 'header': header, 'amountTotal': amountTotal};
    // } catch (err) {
    //   print(err);
    //   return {'data': [], 'header': header};
    // }
  }

  Map<String, TripRoute> _routeList = {};
  Future<TripRoute?> _fetchRouteInfo(String docID) async {
    if (_routeList.containsKey(docID)) {
      return _routeList[docID];
    }

    final route = await RouteDatabase().getRoute(docID);
    if (route != null) {
      _routeList[route.docID!] = route;
      return route;
    }

    return null;
  }
}
