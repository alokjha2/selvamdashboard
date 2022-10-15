import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FuelExpense {
  final DateTime fillDateTime;
  final num fillKm;
  final num littersFilled;
  final num pricePerLitter;
  final num totalAmount;
  final String fillLocation;
  final String tripID;
  final String routeID;
  final String vehicleID;
  final String driverID;
  Reference? proofImage;

  int slNo = 0;
  String? docID;

  FuelExpense(
      {required this.fillDateTime,
      required this.fillKm,
      required this.littersFilled,
      required this.pricePerLitter,
      required this.totalAmount,
      required this.fillLocation,
      required this.tripID,
      required this.routeID,
      required this.vehicleID,
      required this.driverID,
      this.proofImage,
      this.docID});

  factory FuelExpense.fromFirestore(DocumentSnapshot doc) {
    Map? data = doc.data() as Map?;
    return FuelExpense(
        fillDateTime: DateTime.parse(data!['fillDateTime'].toDate().toString()),
        fillKm: data['fillKm'],
        littersFilled: data['littersFilled'],
        pricePerLitter: data['pricePerLitter'],
        totalAmount: data['totalAmount'],
        fillLocation: data['fillLocation'],
        tripID: data['tripID'],
        routeID: data['routeID'],
        vehicleID: data['vehicleID'],
        driverID: data['driverID'],
        proofImage: FirebaseStorage.instance.ref(data['proofImage']),
        docID: doc.id);
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> data = {
      'fillDateTime': this.fillDateTime,
      'fillKm': this.fillKm,
      'littersFilled': this.littersFilled,
      'pricePerLitter': this.pricePerLitter,
      'totalAmount': this.totalAmount,
      'fillLocation': this.fillLocation,
      'tripID': this.tripID,
      'routeID': this.routeID,
      'vehicleID': this.vehicleID,
      'driverID': this.driverID,
      'proofImage': this.proofImage == null ? '' : this.proofImage!.fullPath,
    };
    return data;
  }
}
