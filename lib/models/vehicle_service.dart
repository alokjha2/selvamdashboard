import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class VehicleService {
  final String vehicleID;
  final String description;
  final num serviceKM;
  final num nextDueKM;
  final DateTime serviceDate;
  final num serviceAmount;
  Reference? proofImage;
  int slNo = 0;
  String? docID;

  VehicleService(
      {required this.vehicleID,
      required this.description,
      required this.serviceKM,
      required this.nextDueKM,
      required this.serviceDate,
      required this.serviceAmount,
      this.proofImage,
      this.docID});

  factory VehicleService.fromFirestore(DocumentSnapshot doc) {
    Map? data = doc.data() as Map?;
    return VehicleService(
        vehicleID: data!['vehicleID'],
        description: data['description'],
        serviceKM: data['serviceKM'],
        nextDueKM: data['nextDueKM'],
        serviceDate: DateTime.parse(data['serviceDate'].toDate().toString()),
        serviceAmount: data['serviceAmount'],
        proofImage: FirebaseStorage.instance.ref(data['proofImage']),
        docID: doc.id);
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> data = {
      'vehicleID': this.vehicleID,
      'description': this.description,
      'serviceKM': this.serviceKM,
      'nextDueKM': this.nextDueKM,
      'serviceDate': this.serviceDate,
      'serviceAmount': this.serviceAmount,
      'proofImage': this.proofImage == null ? '' : this.proofImage!.fullPath,
    };
    return data;
  }
}
