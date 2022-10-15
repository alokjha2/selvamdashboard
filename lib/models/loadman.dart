import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:selvam_broilers/utils/flags.dart';

class LoadMan {
  final String fullName;
  final String phoneNumber;
  final String address;
  final DateTime joinedTime;
  final AccountStatus accountActive;
  final OnlineStatus onlineStatus;
  Reference? adharImage;
  Reference? drivingLicenseImage;
  Reference? loadManPhoto;
  int slNo = 0;
  String? docID;

  LoadMan(
      {required this.fullName,
      required this.phoneNumber,
      required this.address,
      required this.joinedTime,
      required this.accountActive,
      required this.onlineStatus,
      this.adharImage,
      this.drivingLicenseImage,
      this.loadManPhoto,
      this.docID});
  factory LoadMan.fromFirestore(DocumentSnapshot doc) {
    Map? data = doc.data() as Map?;
    return LoadMan(
        fullName: data!['fullName'],
        phoneNumber: data['phoneNumber'],
        address: data['address'],
        joinedTime: DateTime.parse(data['joinedTime'].toDate().toString()),
        accountActive: AccountStatus.values[data['accountActive']],
        onlineStatus: OnlineStatus.values[data['onlineStatus']],
        drivingLicenseImage:
            FirebaseStorage.instance.ref(data['drivingLicenseImage']),
        adharImage: FirebaseStorage.instance.ref(data['adharImage']),
        loadManPhoto: FirebaseStorage.instance.ref(data['loadManPhoto']),
        docID: doc.id);
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> data = {
      'fullName': this.fullName,
      'phoneNumber': this.phoneNumber,
      'address': this.address,
      'joinedTime': this.joinedTime,
      'accountActive': this.accountActive.index,
      'onlineStatus': this.onlineStatus.index,
      'adharImage': this.adharImage == null ? '' : this.adharImage!.fullPath,
      'drivingLicenseImage': this.drivingLicenseImage == null
          ? ''
          : this.drivingLicenseImage!.fullPath,
      'loadManPhoto':
          this.loadManPhoto == null ? '' : this.loadManPhoto!.fullPath,
    };
    return data;
  }
}
