import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:selvam_broilers/models/change_rate_model.dart';
import 'package:selvam_broilers/models/direct_sale.dart';
import 'package:selvam_broilers/models/paper_rate.dart';
import 'package:selvam_broilers/models/sale_order.dart';
import 'package:selvam_broilers/services/shops_db.dart';
import 'package:selvam_broilers/services/storage.dart';
import 'package:selvam_broilers/utils/flags.dart';
import 'package:selvam_broilers/utils/utils.dart';
import '../models/shop_payment.dart';
import '../models/trip.dart';
import 'auth.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';

class Database {
  Storage storage = Storage();
  static final Database _databaseInstance = Database._();

  factory Database() {
    return _databaseInstance;
  }

  Database._();

  Future<PaperRate?> getTodayPaperRate() async {
    var doc = await FirebaseFirestore.instance
        .collection('app_data')
        .doc('paper_rate')
        .get();
    if (doc.exists) {
      return PaperRate.fromFirestore(doc);
    }
    return null;
  }

  Future<PaperRate?> getPaperRateForDate(DateTime date) async {
    final formatedDate = getFormattedDate(date);
    var doc = await FirebaseFirestore.instance
        .collection('paper_rates_history')
        .doc(formatedDate)
        .get();
    if (doc.exists) {
      return PaperRate.fromFirestore(doc);
    }
    return null;
  }

  Future<List<ChangeRateModel>> getOrderToUpdatePrice(
      PaperRate localPaperRate) async {
    List<ChangeRateModel> orderList = [];
    try {
      String date = getFormattedDate(DateTime.now());
      var doc = await FirebaseFirestore.instance
          .collection('app_data')
          .doc('paper_rate')
          .get();

      PaperRate? dbPaperRate;

      if (doc.exists) {
        dbPaperRate = PaperRate.fromFirestore(doc);
      }

      if (dbPaperRate == null) {
        return [];
      }

      if (DeepCollectionEquality()
          .equals(localPaperRate.paperRates, dbPaperRate.paperRates)) {
        return [];
      }

      var saleOrderSnap = await FirebaseFirestore.instance
          .collection('sale_orders')
          .where('orderDate', isEqualTo: date)
          .where('orderStatus', isEqualTo: OrderStatus.COMPLETED.index)
          .get();

      // var directSaleSnap = await FirebaseFirestore.instance
      //     .collection('direct_sales')
      //     .where('orderDate', isEqualTo: date)
      //     .get();

      for (var doc in saleOrderSnap.docs) {
        var saleOrder = SaleOrder.fromFirestore(doc);
        var shop = await ShopDatabase().getShopByID(saleOrder.shopID);
        if (shop!.shopType == ShopType.CHILD && shop.parentShop != null) {
          shop = await ShopDatabase().getShopByID(shop.parentShop!);
        }

        saleOrder.shopInfo = shop;
        if (shop != null) {
          num diff = localPaperRate.paperRates[shop.regionName] -
              (saleOrder.paperRate ?? 0);

          if (diff != 0) {
            var change = ChangeRateModel(
                newPaperRate: localPaperRate.paperRates[shop.regionName],
                difference: diff,
                saleOrder: saleOrder);
            orderList.add(change);
          }
        }
      }

      return orderList;
    } catch (e) {
      print(e);
      throw e;
    }
  }

  Future<List<PaperRate>> getPaperRateHistory() async {
    List<PaperRate> list = [];
    var snap = await FirebaseFirestore.instance
        .collection('paper_rates_history')
        .get();

    snap.docs.forEach((doc) {
      list.add(PaperRate.fromFirestore(doc));
    });

    return list;
  }

  Future<bool> setTodayPaperRate(PaperRate paperRate) async {
    try {
      await FirebaseFirestore.instance
          .collection('paper_rates_history')
          .doc(paperRate.date)
          .set(paperRate.toMap());

      await FirebaseFirestore.instance
          .collection('app_data')
          .doc('paper_rate')
          .set(paperRate.toMap());
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Stream<QuerySnapshot> listenPaperRates() {
    return FirebaseFirestore.instance
        .collection('paper_rates_history')
        .orderBy('addedTime', descending: true)
        .snapshots();
  }

  Future<List<ShopPayment>> getShopPaymentsForTrip(Trip trip) async {
    try {
      List<ShopPayment> list = [];
      var snap = await FirebaseFirestore.instance
          .collectionGroup('payments')
          .where('tripID', isEqualTo: trip.docID)
          .orderBy('paymentTime', descending: false)
          .get();

      snap.docs.forEach((doc) {
        list.add(ShopPayment.fromFirestore(doc));
      });
      return list;
    } catch (e) {
      print(e);
      return [];
    }
  }
}
