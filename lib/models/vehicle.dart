import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:selvam_broilers/utils/flags.dart';

class Vehicle {
  final String vehicleType;
  final String vehicleNumber;
  final DateTime addedTime;
  DateTime? lastAirCheckDate;
  final VehicleStatus vehicleStatus;
  num? mileage;
  num? runningKM;
  num? serviceDueKM;
  int slNo = 0;
  String? docID;

  Vehicle({
    required this.vehicleType,
    required this.vehicleNumber,
    required this.addedTime,
    required this.vehicleStatus,
    this.runningKM,
    this.lastAirCheckDate,
    this.serviceDueKM,
    this.mileage,
    this.docID,
  });

  factory Vehicle.fromFirestore(DocumentSnapshot doc) {
    Map? data = doc.data() as Map?;
    return Vehicle(
        vehicleType: data!['vehicleType'],
        vehicleNumber: data['vehicleNumber'],
        runningKM: data['runningKM'] ?? 0,
        mileage: data['mileage'] ?? 0,
        serviceDueKM: data['serviceDueKM'] ?? 0,
        addedTime: DateTime.parse(data['addedTime'].toDate().toString()),
        lastAirCheckDate: data['lastAirCheckDate'] == null
            ? null
            : DateTime.parse(data['lastAirCheckDate'].toDate().toString()),
        vehicleStatus: VehicleStatus.values[data['vehicleStatus']],
        docID: doc.id);
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> data = {
      'vehicleType': this.vehicleType,
      'vehicleNumber': this.vehicleNumber,
      'addedTime': this.addedTime,
      'lastAirCheckDate': this.lastAirCheckDate,
      'mileage': this.mileage ?? 0,
      'runningKM': this.runningKM ?? 0,
      'serviceDueKM': this.serviceDueKM ?? 0,
      'vehicleStatus': this.vehicleStatus.index,
    };
    return data;
  }
}
