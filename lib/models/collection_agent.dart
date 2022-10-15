import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:selvam_broilers/utils/flags.dart';

class CollectionAgent {
  final String fullName;
  final String phoneNumber;
  final String address;
  final DateTime joinedTime;
  final AccountStatus accountActive;
  final OnlineStatus onlineStatus;
  Reference? adharImage;
  Reference? photo;
  int slNo = 0;
  String? docID;

  CollectionAgent(
      {required this.fullName,
      required this.phoneNumber,
      required this.address,
      required this.joinedTime,
      required this.accountActive,
      required this.onlineStatus,
      this.adharImage,
      this.photo,
      this.docID});
  factory CollectionAgent.fromFirestore(DocumentSnapshot doc) {
    Map? data = doc.data() as Map?;
    return CollectionAgent(
        fullName: data!['fullName'],
        phoneNumber: data['phoneNumber'],
        address: data['address'],
        joinedTime: DateTime.parse(data['joinedTime'].toDate().toString()),
        accountActive: AccountStatus.values[data['accountActive']],
        onlineStatus: OnlineStatus.values[data['onlineStatus']],
        adharImage: FirebaseStorage.instance.ref(data['adharImage']),
        photo: FirebaseStorage.instance.ref(data['photo']),
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
      'photo': this.photo == null ? '' : this.photo!.fullPath,
    };
    return data;
  }
}
