import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:selvam_broilers/models/purchase_order.dart';
import 'package:selvam_broilers/services/storage.dart';
import 'package:intl/intl.dart';
import 'package:selvam_broilers/utils/flags.dart';

class PurchaseOrderDatabase {
  Storage storage = Storage();
  static final PurchaseOrderDatabase _databaseInstance =
      PurchaseOrderDatabase._();

  factory PurchaseOrderDatabase() {
    return _databaseInstance;
  }

  PurchaseOrderDatabase._();

  Future<bool> addPurchaseOrder({required PurchaseOrder data}) async {
    try {
      data.orderID = await getPurchaseOrderID();
      data.orderPlacedBy = OrderBy.ADMIN;

      WriteBatch batch = FirebaseFirestore.instance.batch();
      batch.set(FirebaseFirestore.instance.collection('purchase_orders').doc(),
          data.toMap());

      await batch.commit();
      return true;
    } catch (err) {
      print(err);
      return false;
    }
  }

  Future<bool> updatePurchaseOrder({required PurchaseOrder data}) async {
    try {
      await FirebaseFirestore.instance
          .collection('purchase_orders')
          .doc(data.docID)
          .update(data.toMap());
      return true;
    } catch (err) {
      print(err);
      return false;
    }
  }

  Future<bool> deletePurchaseOrder({required PurchaseOrder data}) async {
    try {
      await FirebaseFirestore.instance
          .collection('purchase_orders')
          .doc(data.docID)
          .delete();
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<String> getPurchaseOrderID() async {
    try {
      var orerIDRef = FirebaseFirestore.instance
          .collection('app_data')
          .doc('purchase_orders');

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

  Future<List<PurchaseOrder>> getPurchaseOrdersForTrip(String tripID) async {
    List<PurchaseOrder> list = [];
    try {
      var snap = await FirebaseFirestore.instance
          .collection('purchase_orders')
          .where('tripID', isEqualTo: tripID)
          .get();
      snap.docs.forEach((doc) {
        list.add(PurchaseOrder.fromFirestore(doc));
      });
      return list;
    } catch (err) {
      print(err);
      return list;
    }
  }

  Stream<QuerySnapshot> listenPurchaseOrders(String date) {
    return FirebaseFirestore.instance
        .collection('purchase_orders')
        .where('orderDate', isEqualTo: date)
        .snapshots();
  }
}
