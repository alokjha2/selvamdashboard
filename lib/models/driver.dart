import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:selvam_broilers/utils/flags.dart';

class Driver {
  final String fullName;
  final String phoneNumber;
  final String address;
  final DateTime joinedTime;
  final AccountStatus accountActive;
  final OnlineStatus onlineStatus;
  Reference? adharImage;
  Reference? drivingLicenseImage;
  Reference? driverPhoto;
  int slNo = 0;
  String? docID;
  num? salaryPerKG;

  Driver(
      {required this.fullName,
      required this.phoneNumber,
      required this.address,
      required this.joinedTime,
      required this.accountActive,
      required this.onlineStatus,
      this.adharImage,
      this.drivingLicenseImage,
      this.driverPhoto,
      this.salaryPerKG,
      this.docID});
  factory Driver.fromFirestore(DocumentSnapshot doc) {
    Map? data = doc.data() as Map?;
    return Driver(
        fullName: data!['fullName'],
        phoneNumber: data['phoneNumber'],
        address: data['address'],
        salaryPerKG: data['salaryPerKG'],
        joinedTime: DateTime.parse(data['joinedTime'].toDate().toString()),
        accountActive: AccountStatus.values[data['accountActive']],
        onlineStatus: OnlineStatus.values[data['onlineStatus']],
        drivingLicenseImage:
            FirebaseStorage.instance.ref(data['drivingLicenseImage']),
        adharImage: FirebaseStorage.instance.ref(data['adharImage']),
        driverPhoto: FirebaseStorage.instance.ref(data['driverPhoto']),
        docID: doc.id);
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> data = {
      'fullName': this.fullName,
      'phoneNumber': this.phoneNumber,
      'address': this.address,
      'joinedTime': this.joinedTime,
      'salaryPerKG': this.salaryPerKG,
      'accountActive': this.accountActive.index,
      'onlineStatus': this.onlineStatus.index,
      'adharImage': this.adharImage == null ? '' : this.adharImage!.fullPath,
      'drivingLicenseImage': this.drivingLicenseImage == null
          ? ''
          : this.drivingLicenseImage!.fullPath,
      'driverPhoto': this.driverPhoto == null ? '' : this.driverPhoto!.fullPath,
    };
    return data;
  }
}
