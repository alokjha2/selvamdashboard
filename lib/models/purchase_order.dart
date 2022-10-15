import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:selvam_broilers/models/farm.dart';
import 'package:selvam_broilers/utils/flags.dart';
import 'package:intl/intl.dart';

class PurchaseOrder {
  String orderID;
  String orderDate;
  DateTime createdTime;
  num regularInKG;
  num regularInCount;
  num smallInKG;
  num smallInCount;
  String supervisorName;
  String supervisorPhone;

  String farmID;
  String routeID;
  OrderStatus orderStatus;
  DateTime? completedTime;
  num? pickupRegularInKG;
  num? pickupRegularInCount;
  num? pickupSmallInKG;
  num? pickupSmallInCount;
  num? countTotal;
  num? kgTotal;
  num? totalBoxCount;
  num? purchasePrice;
  Farm? farmInfo;
  int slNo = 0;
  String? docID;
  String? tripID;
  String? driverID;
  String? vehicleID;
  List<dynamic>? loadManIDs;
  OrderBy orderPlacedBy;

  PurchaseOrder({
    required this.orderID,
    required this.orderDate,
    required this.createdTime,
    required this.regularInKG,
    required this.regularInCount,
    required this.smallInKG,
    required this.smallInCount,
    required this.farmID,
    required this.routeID,
    required this.orderStatus,
    required this.supervisorName,
    required this.supervisorPhone,
    this.completedTime,
    this.pickupRegularInKG,
    this.pickupRegularInCount,
    this.pickupSmallInKG,
    this.pickupSmallInCount,
    this.countTotal,
    this.kgTotal,
    this.totalBoxCount,
    this.purchasePrice,
    this.tripID,
    this.docID,
    this.driverID,
    this.vehicleID,
    this.loadManIDs,
    required this.orderPlacedBy,
  });

  factory PurchaseOrder.fromFirestore(DocumentSnapshot doc) {
    Map? data = doc.data() as Map?;
    return PurchaseOrder(
        orderID: data!['orderID'],
        farmID: data['farmID'],
        routeID: data['routeID'],
        orderStatus: OrderStatus.values[data['orderStatus'] ?? 0],
        orderPlacedBy: OrderBy.values[data['orderPlacedBy'] ?? 0],
        orderDate: data['orderDate'],
        createdTime: DateTime.parse(data['createdTime'].toDate().toString()),
        completedTime: data['completedTime'] != null
            ? DateTime.parse(data['completedTime'].toDate().toString())
            : null,
        regularInKG: data['regularInKG'],
        regularInCount: data['regularInCount'],
        smallInKG: data['smallInKG'],
        smallInCount: data['smallInCount'],
        pickupRegularInKG: data['pickupRegularInKG'] ?? 0,
        pickupRegularInCount: data['pickupRegularInCount'] ?? 0,
        pickupSmallInKG: data['pickupSmallInKG'] ?? 0,
        pickupSmallInCount: data['pickupSmallInCount'] ?? 0,
        countTotal: data['countTotal'] ?? 0,
        kgTotal: data['kgTotal'] ?? 0,
        totalBoxCount: data['totalBoxCount'] ?? 0,
        purchasePrice: data['purchasePrice'] ?? 0,
        tripID: data['tripID'],
        supervisorName: data['supervisorName'] ?? '',
        supervisorPhone: data['supervisorPhone'] ?? '',
        driverID: data['driverID'],
        loadManIDs: data['loadManIDs'],
        vehicleID: data['vehicleID'],
        docID: doc.id);
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> data = {
      'orderID': this.orderID,
      'orderDate': this.orderDate,
      'createdTime': this.createdTime,
      'regularInKG': this.regularInKG,
      'regularInCount': this.regularInCount,
      'smallInKG': this.smallInKG,
      'smallInCount': this.smallInCount,
      'farmID': this.farmID,
      'routeID': this.routeID,
      'orderStatus': this.orderStatus.index,
      'completedTime': this.completedTime,
      'pickupRegularInKG': this.pickupRegularInKG,
      'pickupRegularInCount': this.pickupRegularInCount,
      'pickupSmallInKG': this.pickupSmallInKG,
      'pickupSmallInCount': this.pickupSmallInCount,
      'kgTotal': this.kgTotal,
      'countTotal': this.countTotal,
      'totalBoxCount': this.totalBoxCount,
      'purchasePrice': this.purchasePrice,
      'supervisorName': this.supervisorName,
      'supervisorPhone': this.supervisorPhone,
      'tripID': this.tripID,
      'driverID': this.driverID,
      'vehicleID': this.vehicleID,
      'loadManIDs': this.loadManIDs,
      'orderPlacedBy': this.orderPlacedBy.index,
    };
    return data;
  }
}
