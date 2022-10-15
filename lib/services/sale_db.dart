import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:selvam_broilers/models/return_model.dart';
import 'package:selvam_broilers/models/route.dart';
import 'package:selvam_broilers/models/shop.dart';
import 'package:selvam_broilers/models/shop_payment.dart';
import 'package:selvam_broilers/models/trip.dart';
import 'package:selvam_broilers/utils/flags.dart';
import '../models/discount.dart';
import '../models/sale_order.dart';
import 'package:selvam_broilers/services/storage.dart';
import 'package:intl/intl.dart';

import 'auth.dart';

class SaleOrderDatabase {
  Storage storage = Storage();
  static final SaleOrderDatabase _databaseInstance = SaleOrderDatabase._();

  factory SaleOrderDatabase() {
    return _databaseInstance;
  }

  SaleOrderDatabase._();

  Future<SaleOrder?> getSaleOrderForDate(String date, String shopID) async {
    try {
      var snap = await FirebaseFirestore.instance
          .collection('sale_orders')
          .where('orderDate', isEqualTo: date)
          .where('shopID', isEqualTo: shopID)
          .get();
      if (snap.size > 0) {
        return SaleOrder.fromFirestore(snap.docs.first);
      }
      return null;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<bool> submitChickenReturn({required ReturnModel returnOrder}) async {
    // try {
    var shopDoc = await FirebaseFirestore.instance
        .collection('shops')
        .doc(returnOrder.shopID)
        .get();
    if (!shopDoc.exists) {
      return false;
    }
    var shop = Shop.fromFirestore(shopDoc);

    //adding shop number of boxes given and taken & closing balance
    shop.boxesInShop = ((shop.boxesInShop ?? 0) + (returnOrder.boxesGiven)) -
        (returnOrder.boxesTaken);

    WriteBatch batch = FirebaseFirestore.instance.batch();

    if (shop.shopType == ShopType.CHILD) {
      //for child shop
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
      //calculate the closing balance of parent shop using the current returned net total
      //since there will be no payments, we don't have to consider collected amount
      var closingBal = parentShop.closingBalance - returnOrder.netTotal;
      returnOrder.closingBalance = closingBal.round();

      //updating the shop closing bal
      batch.update(
        parentDoc.reference,
        {'closingBalance': closingBal.round()},
      );

      //update box count to child shop
      batch.update(
          FirebaseFirestore.instance.collection('shops').doc(childShop.docID), {
        'boxesInShop': childShop.boxesInShop,
      });

      //add discount to the parent shop
      Discount discount = Discount(
        addedTime: DateTime.now(),
        description:
            'Discount against return order of ${returnOrder.kgTotal} Kgs.',
        discount: returnOrder.netTotal,
        shopID: parentShop.docID!,
        closingBalance: closingBal,
      );
      var discountRef = FirebaseFirestore.instance
          .collection('shops')
          .doc(parentShop.docID)
          .collection('discounts')
          .doc();
      returnOrder.discountID = discountRef.id;
      returnOrder.discountInfo = discount;
      batch.set(discountRef, discount.toMap());
    } else {
      //for parent shop
      var closingBal = shop.closingBalance - returnOrder.netTotal;
      returnOrder.closingBalance = closingBal.round();

      batch.update(
          FirebaseFirestore.instance.collection('shops').doc(shop.docID), {
        'boxesInShop': shop.boxesInShop,
        'closingBalance': closingBal.round()
      });

      //add discount to the shop
      Discount discount = Discount(
        addedTime: DateTime.now(),
        description:
            'Discount against return order of ${returnOrder.kgTotal} Kgs.',
        discount: returnOrder.netTotal,
        shopID: shop.docID!,
        closingBalance: closingBal.round(),
      );
      returnOrder.discountInfo = discount;
      batch.set(
          FirebaseFirestore.instance
              .collection('shops')
              .doc(shop.docID)
              .collection('discounts')
              .doc(),
          discount.toMap());
    }

    //fetch return order id
    returnOrder.orderID = await getReturnOrderID();

    //add return record
    batch.set(FirebaseFirestore.instance.collection('chicken_returns').doc(),
        returnOrder.toMap());

    // //update boxes in hand for the current trip
    // batch.update(
    //     FirebaseFirestore.instance.collection('trips').doc(returnOrder.tripID),
    //     {
    //       'boxesInHand': FieldValue.increment(
    //           returnOrder.boxesTaken - returnOrder.boxesGiven)
    //     });

    //to update return order counter
    batch.update(
        FirebaseFirestore.instance.collection('app_data').doc('chicken_return'),
        {'orderCounter': FieldValue.increment(1)});
    await batch.commit();

    print('Added!');
    return true;
    // } catch (err) {
    //   print(err);
    //   return false;
    // }
  }

  Future<String> getReturnOrderID() async {
    try {
      var doc = await FirebaseFirestore.instance
          .collection('app_data')
          .doc('chicken_return')
          .get();
      int count = 0;
      if (doc.exists) {
        count = doc.data()!['orderCounter'];
      }
      var date = DateFormat('ddMMyy').format(DateTime.now());
      return NumberFormat("000").format(count) + date;
    } catch (err) {
      print(err);
      return '';
    }
  }

  Future<bool> addSaleOrder({required SaleOrder data}) async {
    try {
      data.orderID = await getSaleOrderID();
      data.orderPlacedBy = OrderBy.ADMIN;

      WriteBatch batch = FirebaseFirestore.instance.batch();
      batch.set(FirebaseFirestore.instance.collection('sale_orders').doc(),
          data.toMap());

      await batch.commit();

      return true;
    } catch (err) {
      print(err);
      return false;
    }
  }

  Future<bool> updateSaleOrder({required SaleOrder data}) async {
    try {
      await FirebaseFirestore.instance
          .collection('sale_orders')
          .doc(data.docID)
          .update(data.toMap());
      return true;
    } catch (err) {
      print(err);
      return false;
    }
  }

  Future<bool> deleteSaleOrder({required SaleOrder data}) async {
    try {
      await FirebaseFirestore.instance
          .collection('sale_orders')
          .doc(data.docID)
          .delete();
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> submitSaleOrder({
    required SaleOrder order,
    required ShopPayment payment,
    required Trip trip,
    PlatformFile? chequePhoto,
    PlatformFile? proofPhoto,
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
          {'closingBalance': order.closingBalance},
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

      //uploading proof photo
      if (proofPhoto != null) {
        order.proofImage = (await storage.uploadFile(
            proofPhoto, 'order/sales/', '${order.orderID}-proof_photo'))!;
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

      batch.update(
          FirebaseFirestore.instance.collection('sale_orders').doc(order.docID),
          order.toMap());

      //update boxes in vehicle
      batch.update(
          FirebaseFirestore.instance.collection('trips').doc(trip.docID), {
        'boxesInHand':
            FieldValue.increment(order.boxesTaken! - order.boxesGiven!)
      });

      await batch.commit();
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> submitPayment({
    required ShopPayment payment,
    PlatformFile? chequePhoto,
  }) async {
    try {
      var shopDoc = await FirebaseFirestore.instance
          .collection('shops')
          .doc(payment.shopID)
          .get();
      if (!shopDoc.exists) {
        return false;
      }
      var shop = Shop.fromFirestore(shopDoc);

      WriteBatch batch = FirebaseFirestore.instance.batch();

      //adding payment history only if there was a payment made
      //uploading cheque
      var paymentRef = FirebaseFirestore.instance
          .collection('shops')
          .doc(payment.shopID)
          .collection('payments')
          .doc();

      if (chequePhoto != null) {
        payment.chequeImage = (await storage.uploadFile(
            chequePhoto, 'order/payments/', '${paymentRef.id}-cheque'))!;
      }

      shop.closingBalance -= payment.totalAmount;
      payment.closingBalance = shop.closingBalance.round();
      batch.set(paymentRef, payment.toMap());

      //updating closing balance for shop
      batch.update(
          FirebaseFirestore.instance.collection('shops').doc(payment.shopID),
          {'closingBalance': shop.closingBalance.round()});
      await batch.commit();

      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<String> getSaleOrderID() async {
    try {
      var orerIDRef =
          FirebaseFirestore.instance.collection('app_data').doc('sale_orders');

      return await FirebaseFirestore.instance
          .runTransaction((transaction) async {
        // Get the document
        DocumentSnapshot<Map<String, dynamic>> doc =
            await transaction.get(orerIDRef);
        if (!doc.exists) {
          throw Exception("doc not exist!");
        }

        int count = 0;
        String? transactionID;
        count = doc.data()!['orderCounter'];
        var date = DateFormat('ddMMyy').format(DateTime.now());
        transactionID = NumberFormat("000").format(count) + date;

        await transaction.update(orerIDRef, {'orderCounter': (count + 1)});
        return transactionID;
      });
    } catch (err) {
      print(err);
      return 'null';
    }
  }

  Stream<QuerySnapshot> listenSaleOrdersForRoute(String date, TripRoute route) {
    return FirebaseFirestore.instance
        .collection('sale_orders')
        .where('routeID', isEqualTo: route.docID)
        .where('orderDate', isEqualTo: date)
        .snapshots();
  }

  Stream<QuerySnapshot> listenSaleOrdersForUnassigned(String date) {
    return FirebaseFirestore.instance
        .collection('sale_orders')
        .where('orderDate', isEqualTo: date)
        .where('routeID', isEqualTo: '')
        .snapshots();
  }

  Future<List<SaleOrder>> getSaleOrdersForRoute(
      String date, TripRoute route) async {
    List<SaleOrder> list = [];
    try {
      var snap = await FirebaseFirestore.instance
          .collection('sale_orders')
          .where('routeID', isEqualTo: route.docID)
          .where('orderDate', isEqualTo: date)
          .get();

      snap.docs.forEach((doc) {
        SaleOrder sale = SaleOrder.fromFirestore(doc);
        list.add(sale);
      });
      return list;
    } catch (e) {
      return list;
    }
  }

  Future<List<ReturnModel>> getReturnOrdersForTrip(Trip trip) async {
    List<ReturnModel> list = [];
    try {
      var snap = await FirebaseFirestore.instance
          .collection('chicken_returns')
          .where('tripID', isEqualTo: trip.docID)
          .get();

      snap.docs.forEach((doc) {
        ReturnModel sale = ReturnModel.fromFirestore(doc);
        list.add(sale);
      });
      return list;
    } catch (e) {
      return list;
    }
  }

  Future<List<SaleOrder>> getSaleOrdersForTrip(String tripID) async {
    List<SaleOrder> list = [];
    try {
      var snap = await FirebaseFirestore.instance
          .collection('sale_orders')
          .where('tripID', isEqualTo: tripID)
          .where('orderStatus', isEqualTo: OrderStatus.COMPLETED.index)
          .orderBy('completedTime', descending: true)
          .get();

      snap.docs.forEach((doc) {
        list.add(SaleOrder.fromFirestore(doc));
      });
      return list;
    } catch (err) {
      print(err);
      return list;
    }
  }
}
