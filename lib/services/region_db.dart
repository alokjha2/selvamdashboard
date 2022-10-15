import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:selvam_broilers/models/region.dart';
import 'package:selvam_broilers/models/route.dart';
import 'package:selvam_broilers/models/shop.dart';
import 'package:selvam_broilers/services/storage.dart';
import 'package:selvam_broilers/utils/flags.dart';

class RegionDatabase {
  Storage storage = Storage();
  static final RegionDatabase _databaseInstance = RegionDatabase._();

  factory RegionDatabase() {
    return _databaseInstance;
  }

  RegionDatabase._();

  // Future<List<TripRoute>> getAllRoutes() async {
  //   List<TripRoute> routeList = [];
  //   try {
  //     var snap = await FirebaseFirestore.instance
  //         .collection('routes')
  //         .orderBy('addedTime', descending: true)
  //         .get();
  //     snap.docs.forEach((doc) {
  //       routeList.add(TripRoute.fromFirestore(doc));
  //     });
  //     return routeList;
  //   } catch (err) {
  //     print(err);
  //     return routeList;
  //   }
  // }

  Future<bool> addRegion(Region data) async {
    try {
      var snaps = await FirebaseFirestore.instance
          .collection('regions')
          .where('regionName', isEqualTo: data.regionName)
          .get();
      if (snaps.size > 0) {
        return false;
      }
      await FirebaseFirestore.instance.collection('regions').add(data.toMap());
      return true;
    } catch (err) {
      print(err);
      return false;
    }
  }

  Future<bool> updateRegion(Region data) async {
    try {
      var snaps = await FirebaseFirestore.instance
          .collection('regions')
          .where('regionName', isEqualTo: data.regionName)
          .get();
      if (snaps.size > 0) {
        return false;
      }

      await FirebaseFirestore.instance
          .collection('regions')
          .doc(data.docID)
          .update(data.toMap());
      return true;
    } catch (err) {
      print(err);
      return false;
    }
  }

  Future<bool> deleteRegion(Region data) async {
    try {
      await FirebaseFirestore.instance
          .collection('regions')
          .doc(data.docID)
          .delete();
      return true;
    } catch (err) {
      print(err);
      return false;
    }
  }

  Stream<QuerySnapshot> listenRegions() {
    return FirebaseFirestore.instance
        .collection('regions')
        .orderBy('addedTime', descending: true)
        .snapshots();
  }

  Future<List<Region>> getAllReagion() async {
    List<Region> list = [];
    try {
      QuerySnapshot snap = await FirebaseFirestore.instance
          .collection('regions')
          .orderBy('regionName')
          .get();
      for (var doc in snap.docs) {
        list.add(Region.fromFirestore(doc));
      }
      return list;
    } catch (e) {
      print(e);
    }
    return list;
  }
}
