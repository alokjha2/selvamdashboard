import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:selvam_broilers/models/loadman.dart';
import 'package:selvam_broilers/services/storage.dart';
import 'package:selvam_broilers/utils/flags.dart';

class LoadManDatabase {
  Storage storage = Storage();
  static final LoadManDatabase _databaseInstance = LoadManDatabase._();

  factory LoadManDatabase() {
    return _databaseInstance;
  }

  LoadManDatabase._();

  Future<bool> addLoadMan(
      {required LoadMan data,
      PlatformFile? adhar,
      PlatformFile? drivingLicense,
      PlatformFile? photo}) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('loadman')
          .add(data.toMap());
      //uploading image to storage
      if (adhar != null) {
        data.adharImage =
            (await storage.uploadFile(adhar, 'loadman/${doc.id}/', 'adhaar'))!;
      }
      if (drivingLicense != null) {
        data.drivingLicenseImage = (await storage.uploadFile(
            drivingLicense, 'loadman/${doc.id}/', 'driving_license'))!;
      }
      if (photo != null) {
        data.loadManPhoto =
            (await storage.uploadFile(photo, 'loadman/${doc.id}/', 'photo'))!;
      }
      await FirebaseFirestore.instance
          .collection('loadman')
          .doc(doc.id)
          .update(data.toMap());
      return true;
    } catch (err) {
      print(err);
      return false;
    }
  }

  Future<bool> updateLoadManAccountActive(LoadMan loadMan) async {
    try {
      if (loadMan.onlineStatus == OnlineStatus.ONLINE) {
        return false;
      }
      int status = -1;
      if (loadMan.accountActive == AccountStatus.ACTIVE) {
        status = AccountStatus.INACTIVE.index;
      } else {
        status = AccountStatus.ACTIVE.index;
      }
      await FirebaseFirestore.instance
          .collection('loadman')
          .doc(loadMan.docID)
          .update({'accountActive': status});
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> updateLoadMan(
      {required LoadMan data,
      PlatformFile? adhar,
      PlatformFile? drivingLicense,
      PlatformFile? photo}) async {
    try {
      if (adhar == null) {
        //have to delete
        data.adharImage = null;
      }
      if (drivingLicense == null) {
        //have to delete
        data.drivingLicenseImage = null;
      }
      if (photo == null) {
        data.loadManPhoto = null;
      }

      //uploading image to sotrage
      if (adhar != null && adhar.bytes != null) {
        data.adharImage = (await storage.uploadFile(
            adhar, 'loadman/${data.docID}/', 'adhaar'))!;
      }

      if (drivingLicense != null && drivingLicense.bytes != null) {
        data.drivingLicenseImage = (await storage.uploadFile(
            drivingLicense, 'loadman/${data.docID}/', 'driving_license'))!;
      }
      if (photo != null && photo.bytes != null) {
        data.loadManPhoto = (await storage.uploadFile(
            photo, 'loadman/${data.docID}/', 'photo'))!;
      }

      await FirebaseFirestore.instance
          .collection('loadman')
          .doc(data.docID)
          .update(data.toMap());
      return true;
    } catch (err) {
      print(err);
      return false;
    }
  }

  Future<bool> deleteLoadManAccount(LoadMan loadMan) async {
    try {
      if (loadMan.onlineStatus == OnlineStatus.ONLINE) {
        return false;
      }
      await FirebaseFirestore.instance
          .collection('loadman')
          .doc(loadMan.docID)
          .delete();
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<List<LoadMan>?> getAllLoadMan() async {
    List<LoadMan> loadManList = [];
    try {
      var snap = await FirebaseFirestore.instance
          .collection('loadman')
          .orderBy('fullName', descending: false)
          .get();
      snap.docs.forEach((doc) {
        loadManList.add(LoadMan.fromFirestore(doc));
      });
      return loadManList;
    } catch (err) {
      print(err);
      return loadManList;
    }
  }

  Stream<QuerySnapshot> listenLoadMan() {
    return FirebaseFirestore.instance
        .collection('loadman')
        .orderBy('joinedTime', descending: true)
        .snapshots();
  }
}
