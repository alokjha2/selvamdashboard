import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:selvam_broilers/models/collection_agent.dart';
import 'package:selvam_broilers/models/driver.dart';
import 'package:selvam_broilers/models/shop.dart';
import 'package:selvam_broilers/services/network.dart';
import 'package:selvam_broilers/services/storage.dart';
import 'package:selvam_broilers/utils/flags.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker_web/image_picker_web.dart';
import 'package:selvam_broilers/utils/utils.dart';
import 'auth.dart';

class DriverDatabase {
  FirebaseAuthService _firebaseAuthService = FirebaseAuthService();
  Storage storage = Storage();
  static final DriverDatabase _databaseInstance = DriverDatabase._();

  factory DriverDatabase() {
    return _databaseInstance;
  }

  DriverDatabase._();

  Future<bool> addDriver(
      {required Driver data,
      PlatformFile? adhar,
      PlatformFile? drivingLicense,
      PlatformFile? photo}) async {
    try {
      var account =
          await FirebaseAuthService().checkAccountExist(data.phoneNumber);
      if (account != null) {
        if (account is Driver) {
          showToast(
              message:
                  'Already a Driver account exist with the same number. Try different number');
        } else if (account is Shop) {
          showToast(
              message:
                  'Already a Shop exist with the same number. Try different number');
        } else if (account is CollectionAgent) {
          showToast(
              message:
                  'Already a Collection agent account exist with the same number. Try different number');
        }
        return false;
      }
      var url = Uri.parse('${BASE_URL}createFirebaseUser');
      var response = await http.post(url, headers: {
        "Access-Control-Allow-Origin": "*"
      }, body: {
        'fullName': data.fullName,
        'phoneNumber': data.phoneNumber,
        'role': 'DRIVER'
      });
      if (response.statusCode == 200) {
        //uploading image to sotrage
        if (adhar != null) {
          data.adharImage = (await storage.uploadFile(
              adhar, 'drivers/${response.body}/', 'adhaar'))!;
        }
        if (drivingLicense != null) {
          data.drivingLicenseImage = (await storage.uploadFile(
              drivingLicense, 'drivers/${response.body}/', 'driving_license'))!;
        }
        if (photo != null) {
          data.driverPhoto = (await storage.uploadFile(
              photo, 'drivers/${response.body}/', 'photo'))!;
        }

        await FirebaseFirestore.instance
            .collection('drivers')
            .doc(response.body)
            .set(data.toMap());
        return true;
      } else if (response.statusCode == 500) {
        return false;
      } else {
        return false;
      }
    } catch (err) {
      print(err);
      return false;
    }
  }

  Future<bool> updateDriverAccountActive(Driver driver) async {
    try {
      if (driver.onlineStatus == OnlineStatus.ONLINE) {
        return false;
      }

      int status = -1;
      if (driver.accountActive == AccountStatus.ACTIVE) {
        status = AccountStatus.INACTIVE.index;
      } else {
        status = AccountStatus.ACTIVE.index;
      }
      await FirebaseFirestore.instance
          .collection('drivers')
          .doc(driver.docID)
          .update({'accountActive': status});
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> updateDriver(
      {required Driver data,
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
        data.driverPhoto = null;
      }

      //uploading image to sotrage
      if (adhar != null && adhar.bytes != null) {
        data.adharImage = (await storage.uploadFile(
            adhar, 'drivers/${data.docID}/', 'adhaar'))!;
      }

      if (drivingLicense != null && drivingLicense.bytes != null) {
        data.drivingLicenseImage = (await storage.uploadFile(
            drivingLicense, 'drivers/${data.docID}/', 'driving_license'))!;
      }
      if (photo != null && photo.bytes != null) {
        data.driverPhoto = (await storage.uploadFile(
            photo, 'drivers/${data.docID}/', 'photo'))!;
      }

      await FirebaseFirestore.instance
          .collection('drivers')
          .doc(data.docID)
          .update(data.toMap());
      return true;
    } catch (err) {
      print(err);
      return false;
    }
  }

  Future<bool> deleteDriverAccount(Driver driver) async {
    try {
      if (driver.onlineStatus == OnlineStatus.ONLINE) {
        return false;
      }
      await FirebaseFirestore.instance
          .collection('drivers')
          .doc(driver.docID)
          .delete();
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<Driver?> getDriverByPhone(String phone) async {
    try {
      var snap = await FirebaseFirestore.instance
          .collection('drivers')
          .where('phoneNumber', isEqualTo: phone)
          .get();
      if (snap.docs.isNotEmpty) {
        return Driver.fromFirestore(snap.docs.first);
      }
      return null;
    } catch (err) {
      print(err);
      return null;
    }
  }

  Future<Driver?> getDriver(String? id) async {
    if (id == null || id.isEmpty) return null;
    var doc =
        await FirebaseFirestore.instance.collection('drivers').doc(id).get();
    if (doc.exists) {
      return Driver.fromFirestore(doc);
    }
    return null;
  }

  Future<List<Driver>?> getAllDrivers() async {
    List<Driver> driverList = [];
    try {
      var snap = await FirebaseFirestore.instance
          .collection('drivers')
          .orderBy('fullName', descending: false)
          .get();
      snap.docs.forEach((doc) {
        driverList.add(Driver.fromFirestore(doc));
      });
      return driverList;
    } catch (err) {
      print(err);
      return driverList;
    }
  }

  Stream<QuerySnapshot> listenDrivers() {
    return FirebaseFirestore.instance
        .collection('drivers')
        .orderBy('joinedTime', descending: true)
        .snapshots();
  }
}
