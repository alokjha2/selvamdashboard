import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:selvam_broilers/models/additional_amount.dart';
import 'package:selvam_broilers/models/direct_sale.dart';
import 'package:selvam_broilers/models/discount.dart';
import 'package:selvam_broilers/models/route.dart';
import 'package:selvam_broilers/models/sale_order.dart';
import 'package:selvam_broilers/models/shop.dart';
import 'package:selvam_broilers/models/shop_payment.dart';
import 'package:selvam_broilers/utils/flags.dart';
import 'package:selvam_broilers/services/storage.dart';
import 'package:intl/intl.dart';
import 'package:selvam_broilers/utils/utils.dart';

class DirectSaleDatabase {
  Storage storage = Storage();
  static final DirectSaleDatabase _databaseInstance = DirectSaleDatabase._();

  factory DirectSaleDatabase() {
    return _databaseInstance;
  }

  DirectSaleDatabase._();

  Future<bool> submitDirectSaleOrder({
    required DirectSale order,
    required ShopPayment payment,
    PlatformFile? chequePhoto,
    required bool isChildShop,
  }) async {
    try {
      var shopDoc = await FirebaseFirestore.instance
          .collection('shops')
          .doc(order.shopID)
          .get();
      if (!shopDoc.exists) {
        return false;
      }
      var shop = Shop.fromFirestore(shopDoc);

      //adding shop number of boxes given and taken & closing balance
      shop.boxesInShop = ((shop.boxesInShop ?? 0) + (order.boxesGiven ?? 0)) -
          (order.boxesTaken ?? 0);

      WriteBatch batch = FirebaseFirestore.instance.batch();

      if (isChildShop) {
        Shop childShop = shop;
        //get parent and add the current order total rs to its closing balance
        var parentDoc = await FirebaseFirestore.instance
            .collection('shops')
            .doc(childShop.parentShop)
            .get();

        if (!parentDoc.exists) {
          return false;
        }

        Shop parentShop = Shop.fromFirestore(parentDoc);
        //calculate the closing balance of parent shop using the current net total
        //since there will be no payments, we dont have to consider collected amount
        var closingBal = ((order.netTotal ?? 0) + parentShop.closingBalance);
        order.closingBalance = closingBal.round();

        batch.update(
          parentDoc.reference,
          {'closingBalance': order.closingBalance!.round()},
        );

        //update box count to child shop
        batch.update(
            FirebaseFirestore.instance.collection('shops').doc(childShop.docID),
            {
              'boxesInShop': childShop.boxesInShop,
            });
      } else {
        var closingBal =
            ((order.netTotal ?? 0) + shop.closingBalance) - payment.totalAmount;
        order.closingBalance = closingBal.round();
        payment.closingBalance = closingBal.round();

        batch.update(
            FirebaseFirestore.instance.collection('shops').doc(order.shopID), {
          'boxesInShop': shop.boxesInShop,
          'closingBalance': order.closingBalance
        });
      }

      //adding payment history only if there was a payment made, for child this conditions will never pass
      if (payment.totalAmount > 0) {
        //uploading cheque
        var paymentRef = FirebaseFirestore.instance
            .collection('shops')
            .doc(order.shopID)
            .collection('payments')
            .doc();

        if (chequePhoto != null) {
          payment.chequeImage = (await storage.uploadFile(
              chequePhoto, 'order/payments/', '${paymentRef.id}-cheque'))!;
        }

        batch.set(paymentRef, payment.toMap());

        //attaching payment info to the sales order
        order.paymentID = paymentRef.id;
        order.paymentInfo = payment;
      }

      batch.set(FirebaseFirestore.instance.collection('direct_sales').doc(),
          order.toMap());

      await batch.commit();
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> updateSaleOrder({required DirectSale data}) async {
    try {
      await FirebaseFirestore.instance
          .collection('direct_sales')
          .doc(data.docID)
          .update(data.toMap());
      return true;
    } catch (err) {
      print(err);
      return false;
    }
  }

  Future<bool> deleteSaleOrder({required DirectSale data}) async {
    try {
      await FirebaseFirestore.instance
          .collection('direct_sales')
          .doc(data.docID)
          .delete();
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<List<DirectSale>> getSaleOrdersForTrip(String tripID) async {
    List<DirectSale> list = [];
    try {
      var snap = await FirebaseFirestore.instance
          .collection('direct_sales')
          .where('tripID', isEqualTo: tripID)
          .get();
      snap.docs.forEach((doc) {
        list.add(DirectSale.fromFirestore(doc));
      });
      return list;
    } catch (err) {
      print(err);
      return list;
    }
  }

  Future<List> getShopOrdersPaymentsDiscounts(
      {required Shop shop, DateTime? startDate, DateTime? endDate}) async {
    // try {

    Query dSaleQuery = FirebaseFirestore.instance
        .collection('direct_sales')
        .where('shopID', isEqualTo: shop.docID);

    Query saleOrderQuery = FirebaseFirestore.instance
        .collection('sale_orders')
        .where('shopID', isEqualTo: shop.docID)
        .where('orderStatus', isEqualTo: OrderStatus.COMPLETED.index);

    Query paymentQuery = FirebaseFirestore.instance
        .collection('shops')
        .doc(shop.docID)
        .collection('payments');

    Query discountQuery = FirebaseFirestore.instance
        .collection('shops')
        .doc(shop.docID)
        .collection('discounts');

    Query extraAmtQuery = FirebaseFirestore.instance
        .collection('shops')
        .doc(shop.docID)
        .collection('additionalBills');

    if (startDate != null && endDate != null) {
      //direct sales
      dSaleQuery = dSaleQuery.where('createdTime',
          isGreaterThanOrEqualTo: startDate, isLessThan: endDate);

      //sale orders
      saleOrderQuery = saleOrderQuery.where('completedTime',
          isGreaterThanOrEqualTo: startDate, isLessThan: endDate);

      //payment
      paymentQuery = paymentQuery.where('paymentTime',
          isGreaterThanOrEqualTo: startDate, isLessThan: endDate);

      //discount
      discountQuery = discountQuery.where('addedTime',
          isGreaterThanOrEqualTo: startDate, isLessThan: endDate);

      //extra amt
      extraAmtQuery = extraAmtQuery.where('addedTime',
          isGreaterThanOrEqualTo: startDate, isLessThan: endDate);
    }

    //applicable only for parent shop
    List<ShopPayment> paymentsList = [];
    var paymentSnap = await paymentQuery.get();
    paymentSnap.docs.forEach((doc) {
      var p = ShopPayment.fromFirestore(doc);
      //only add the payments that are not linked with the sale order
      if (p.saleOrderID == null) {
        paymentsList.add(p);
      }
    });

    List<DirectSale> directSalesList = [];
    var dSaleSnap = await dSaleQuery.get();
    dSaleSnap.docs.forEach((doc) {
      directSalesList.add(DirectSale.fromFirestore(doc));
    });

    List<SaleOrder> saleOrderList = [];
    var slaeOrderSnap = await saleOrderQuery.get();
    slaeOrderSnap.docs.forEach((doc) {
      saleOrderList.add(SaleOrder.fromFirestore(doc));
    });

    List<Discount> discountList = [];
    var discountSnap = await discountQuery.get();
    discountSnap.docs.forEach((doc) {
      discountList.add(Discount.fromFirestore(doc));
    });

    List<AdditionalAmount> extraAmtList = [];
    var extraAmtSnap = await extraAmtQuery.get();
    extraAmtSnap.docs.forEach((doc) {
      extraAmtList.add(AdditionalAmount.fromFirestore(doc));
    });

    bool isParent = shop.shopType == ShopType.PARENT;
    if (isParent && shop.childShops != null && shop.childShops!.isNotEmpty) {
      //fetching the child shops's direct sales
      List<Future<QuerySnapshot<Object?>>> directSaleFutureList = [];
      shop.childShops!.forEach((docID) {
        Query dSaleQuery = FirebaseFirestore.instance
            .collection('direct_sales')
            .where('shopID', isEqualTo: docID);
        if (startDate != null && endDate != null) {
          //direct sales
          dSaleQuery = dSaleQuery.where('createdTime',
              isGreaterThanOrEqualTo: startDate, isLessThan: endDate);
        }
        directSaleFutureList.add(dSaleQuery.get());
      });
      var dSaleResults = await Future.wait(directSaleFutureList);

      //filing the child shops's direct sales
      dSaleResults.forEach((snapshop) {
        snapshop.docs.forEach((doc) {
          directSalesList.add(DirectSale.fromFirestore(doc));
        });
      });

      //fetching the child shops's delivery sales
      List<Future<QuerySnapshot<Object?>>> deliveryFutureList = [];
      shop.childShops!.forEach((docID) {
        Query deliverySaleQuery = FirebaseFirestore.instance
            .collection('sale_orders')
            .where('shopID', isEqualTo: docID)
            .where('orderStatus', isEqualTo: OrderStatus.COMPLETED.index);

        if (startDate != null && endDate != null) {
          deliverySaleQuery = deliverySaleQuery.where('completedTime',
              isGreaterThanOrEqualTo: startDate, isLessThan: endDate);
        }
        deliveryFutureList.add(deliverySaleQuery.get());
      });
      var deliverySaleResults = await Future.wait(deliveryFutureList);

      //filing the child shops's direct sales
      deliverySaleResults.forEach((snapshop) {
        snapshop.docs.forEach((doc) {
          saleOrderList.add(SaleOrder.fromFirestore(doc));
        });
      });
    }

    List<List<dynamic>> twoDList = [];

    //filing direct sales
    for (int i = 0; i < directSalesList.length; i++) {
      var order = directSalesList[i];
      List row = [];

      row.add('Store Sales');
      row.add((order.createdTime));

      String items = '';
      order.deliveryDetails.forEach((key, value) {
        if (value['kg'] > 0 || value['count'] > 0)
          items +=
              '$key - ${(value['kg']).toStringAsFixed(2)} KG x ${(value['rate']).toStringAsFixed(2)}\n';
      });
      row.add(items.trim());
      row.add('${order.netTotal!.toStringAsFixed(2)} Rs.');
      row.add(order.paymentInfo != null
          ? '${order.paymentInfo!.totalAmount.toStringAsFixed(2)} Rs.'
          : '-');
      row.add('${order.closingBalance!.toStringAsFixed(2)} Rs.');
      row.add(order);

      twoDList.add(row);
    }

    //filling sales order
    for (int i = 0; i < saleOrderList.length; i++) {
      var order = saleOrderList[i];
      List row = [];

      row.add('Delivery');

      row.add((order.completedTime));

      String items = '';
      String billed = '';
      if (order.deliveredRegularInKG! > 0) {
        if (order.paperRate != null && order.regularDiscountPerKG != null) {
          billed =
              ' x ${((order.paperRate! - order.regularDiscountPerKG!).toStringAsFixed(2))}';
        }
        items +=
            'Regular - ${order.deliveredRegularInKG!.toStringAsFixed(2)} KG ${billed}\n';
      }

      billed = '';
      if (order.deliveredSmallInKG! > 0) {
        if (order.paperRate != null && order.smallDiscountPerKG != null) {
          billed =
              ' x ${((order.paperRate! - order.smallDiscountPerKG!).toStringAsFixed(2))}';
        }
        items +=
            'Small - ${order.deliveredSmallInKG!.toStringAsFixed(2)} KG ${billed}';
      }

      row.add(items);
      row.add('${order.netTotal!.toStringAsFixed(2)} Rs.');
      row.add(order.paymentInfo != null
          ? '${order.paymentInfo!.totalAmount.toStringAsFixed(2)} Rs.'
          : '-');
      row.add('${order.closingBalance!.toStringAsFixed(2)} Rs.');
      row.add(order);

      twoDList.add(row);
    }

    //filling payments
    for (int i = 0; i < paymentsList.length; i++) {
      List row = [];

      var payment = paymentsList[i];
      row.add('Payment');
      row.add((payment.paymentTime));
      row.add('-');
      row.add('-');
      row.add('${payment.totalAmount.toStringAsFixed(2)} Rs.');
      row.add('${payment.closingBalance!.toStringAsFixed(2)} Rs.');
      row.add(payment);

      twoDList.add(row);
    }

    //filling discounts
    for (int i = 0; i < discountList.length; i++) {
      List row = [];

      var discount = discountList[i];
      row.add('Discount');
      row.add((discount.addedTime));
      row.add(discount.description);
      row.add('-');
      row.add('${discount.discount.toStringAsFixed(2)} Rs.');
      row.add('${discount.closingBalance!.toStringAsFixed(2)} Rs.');
      row.add(discount);
      twoDList.add(row);
    }

    //filling extra amt
    for (int i = 0; i < extraAmtList.length; i++) {
      List row = [];

      var amt = extraAmtList[i];
      row.add('Additional Bills/Amount');
      row.add((amt.addedTime));
      row.add(amt.description);
      if (amt.amount > 0) {
        //add to billed
        row.add('${amt.amount.toStringAsFixed(2)} Rs.');
        row.add('-');
      } else {
        //add to discount/paid
        row.add('-');
        row.add('${amt.amount.abs().toStringAsFixed(2)} Rs.');
      }
      row.add('${amt.closingBalance!.toStringAsFixed(2)} Rs.');
      row.add(amt);
      twoDList.add(row);
    }

    int comparisonIndex = 1;

    List<List<dynamic>> sortedList = twoDList
      ..sort((x, y) => (x[comparisonIndex] as dynamic)
          .compareTo((y[comparisonIndex] as dynamic)));

    sortedList.forEach((row) {
      print(
          '${row[comparisonIndex]}  *** ${getFormattedDateTime(row[comparisonIndex], 'dd-MM-yyyy')} *** ${row[3]} *** ${row[4]} *** ${row[5]} ');
      row[comparisonIndex] =
          getFormattedDateTime(row[comparisonIndex], 'dd-MM-yyyy\n(EEEE)');
    });

    for (var row in sortedList) {
      if (row.last is SaleOrder) {
        DateTime tempDate = new DateFormat("dd-MM-yyyy")
            .parse((row.last as SaleOrder).orderDate);
        row[comparisonIndex] =
            getFormattedDateTime(tempDate, 'dd-MM-yyyy\n(EEEE)');
      }
    }

    return sortedList;
    // } catch (err) {
    //   print(err);
    //   return [[]];
    // }
  }

  Stream<QuerySnapshot> listenSaleOrdersForRoute(Shop shop) {
    return FirebaseFirestore.instance
        .collection('direct_sales')
        .where('shopID', isEqualTo: shop.docID)
        .snapshots();
  }

  Future<List<DirectSale>> getSaleOrdersForRoute(
      String date, TripRoute route) async {
    List<DirectSale> list = [];
    try {
      var snap = await FirebaseFirestore.instance
          .collection('direct_sales')
          .where('routeID', isEqualTo: route.docID)
          .where('orderDate', isEqualTo: date)
          .get();

      snap.docs.forEach((doc) {
        DirectSale sale = DirectSale.fromFirestore(doc);
        list.add(sale);
      });
      return list;
    } catch (e) {
      return list;
    }
  }

  Future<Map<String, dynamic>> getChickenTypes() async {
    try {
      var doc = await FirebaseFirestore.instance
          .collection('app_data')
          .doc('chickenTypes')
          .get();
      if (doc.exists) {
        return doc.data()!['chickenTypes'];
      }

      return {};
    } catch (e) {
      print(e);
      return {};
    }
  }
}
