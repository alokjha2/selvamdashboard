import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:selvam_broilers/models/farm.dart';
import 'package:selvam_broilers/services/storage.dart';

class FarmDatabase {
  Storage storage = Storage();
  static final FarmDatabase _databaseInstance = FarmDatabase._();

  factory FarmDatabase() {
    return _databaseInstance;
  }

  FarmDatabase._();

  Future<bool> addFarm({required Farm data}) async {
    try {
      await FirebaseFirestore.instance.collection('farms').add(data.toMap());
      return true;
    } catch (err) {
      print(err);
      return false;
    }
  }

  Future<bool> updateFarm({required Farm data}) async {
    try {
      await FirebaseFirestore.instance
          .collection('farms')
          .doc(data.docID)
          .update(data.toMap());
      return true;
    } catch (err) {
      print(err);
      return false;
    }
  }

  Future<bool> deleteFarm({required Farm data}) async {
    try {
      await FirebaseFirestore.instance
          .collection('farms')
          .doc(data.docID)
          .delete();
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<List<Farm>> getAllFarms() async {
    List<Farm> list = [];
    try {
      var snap = await FirebaseFirestore.instance
          .collection('farms')
          // .orderBy('addedTime', descending: true)
          .orderBy('companyName', descending: false)
          .get();
      snap.docs.forEach((doc) {
        list.add(Farm.fromFirestore(doc));
      });
      return list;
    } catch (err) {
      print(err);
      return list;
    }
  }

  Future<Farm?> getFarm(String docID) async {
    try {
      var doc =
          await FirebaseFirestore.instance.collection('farms').doc(docID).get();
      if (doc.exists) {
        return Farm.fromFirestore(doc);
      }
      return null;
    } catch (err) {
      print(err);
      return null;
    }
  }

  Stream<QuerySnapshot> listenFarms() {
    return FirebaseFirestore.instance
        .collection('farms')
        .orderBy('addedTime', descending: true)
        .snapshots();
  }
}
