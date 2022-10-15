import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:selvam_broilers/models/loadman.dart';
import 'package:selvam_broilers/models/route.dart';
import 'package:selvam_broilers/models/vehicle.dart';
import 'package:selvam_broilers/utils/flags.dart';

import 'driver.dart';
import 'package:intl/intl.dart';

class Trip {
  final String tripDate;
  final DateTime createdTime;
  final DateTime? startedTime;
  final DateTime? endTime;
  final TripStatus tripStatus;
  final String driverID;
  final String routeID;
  final String vehicleID;
  final List<dynamic>? loadManIDs;
  final num? startKM;
  final num? endKM;
  final num? boxesTaken;
  final num? boxesReturned;
  final num? boxesInHand;
  final num? mortalityKG;
  final num? mortalityCount;
  final num? amoutTaken;
  final num? amoutReturned;
  final String? remarks;
  String? scaleNumber;
  Map<dynamic, dynamic>? expenseRemainingCashDenomination;

  String? docID;
  int slNo = 0;
  Driver? driverInfo;
  TripRoute? routeInfo;
  Vehicle? vehicleInfo;
  List<LoadMan>? loadManInfos;
  Reference? feedProofImage;
  Reference? mortalityProofImage;
  Reference? loadingAreaCleanImage;

  Trip(
      {required this.tripDate,
      required this.createdTime,
      required this.driverID,
      required this.routeID,
      required this.vehicleID,
      required this.tripStatus,
      this.boxesTaken,
      this.boxesInHand,
      this.boxesReturned,
      this.loadManIDs,
      this.endTime,
      this.startedTime,
      this.startKM,
      this.mortalityKG,
      this.mortalityCount,
      this.endKM,
      this.feedProofImage,
      this.mortalityProofImage,
      this.loadingAreaCleanImage,
      this.amoutTaken,
      this.amoutReturned,
      this.remarks,
      this.scaleNumber,
      this.expenseRemainingCashDenomination,
      this.docID});

  factory Trip.fromFirestore(DocumentSnapshot doc) {
    Map? data = doc.data() as Map?;
    return Trip(
        tripDate: data!['tripDate'],
        createdTime: DateTime.parse(data['createdTime'].toDate().toString()),
        startedTime: data['startedTime'] == null
            ? null
            : DateTime.parse(data['startedTime'].toDate().toString()),
        endTime: data['endTime'] == null
            ? null
            : DateTime.parse(data['endTime'].toDate().toString()),
        tripStatus: TripStatus.values[data['tripStatus']],
        driverID: data['driverID'],
        routeID: data['routeID'],
        boxesInHand: data['boxesInHand'],
        vehicleID: data['vehicleID'],
        loadManIDs: data['loadManIDs'] ?? [],
        startKM: data['startKM'] ?? 0,
        endKM: data['endKM'] ?? 0,
        boxesTaken: data['boxesTaken'] ?? 0,
        boxesReturned: data['boxesReturned'] ?? 0,
        amoutTaken: data['amoutTaken'] ?? 0,
        mortalityKG: data['mortalityKG'] ?? 0,
        mortalityCount: data['mortalityCount'] ?? 0,
        amoutReturned: data['amoutReturned'] ?? 0,
        remarks: data['remarks'],
        scaleNumber: data['scaleNumber'],
        expenseRemainingCashDenomination:
            data['expenseRemainingCashDenomination'],
        feedProofImage: FirebaseStorage.instance.ref(data['feedProofImage']),
        mortalityProofImage:
            FirebaseStorage.instance.ref(data['mortalityProofImage']),
        loadingAreaCleanImage:
            FirebaseStorage.instance.ref(data['loadingAreaCleanImage']),
        docID: doc.id);
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> data = {
      'tripDate': this.tripDate,
      'createdTime': this.createdTime,
      'startedTime': this.startedTime,
      'endTime': this.endTime,
      'tripStatus': this.tripStatus.index,
      'driverID': this.driverID,
      'routeID': this.routeID,
      'vehicleID': this.vehicleID,
      'loadManIDs': this.loadManIDs,
      'startKM': this.startKM,
      'endKM': this.endKM,
      'boxesTaken': this.boxesTaken,
      'boxesReturned': this.boxesReturned,
      'boxesInHand': this.boxesInHand,
      'amoutTaken': this.amoutTaken,
      'mortalityKG': this.mortalityKG,
      'mortalityCount': this.mortalityCount,
      'amoutReturned': this.amoutReturned,
      'remarks': this.remarks,
      'scaleNumber': this.scaleNumber,
      'expenseRemainingCashDenomination': this.expenseRemainingCashDenomination,
      'feedProofImage':
          this.feedProofImage == null ? '' : this.feedProofImage!.fullPath,
      'mortalityProofImage': this.mortalityProofImage == null
          ? ''
          : this.mortalityProofImage!.fullPath,
      'loadingAreaCleanImage': this.loadingAreaCleanImage == null
          ? ''
          : this.loadingAreaCleanImage!.fullPath,
    };
    return data;
  }
}
