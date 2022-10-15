import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:selvam_broilers/models/shop.dart';

import 'discount.dart';

class ReturnModel {
  String? orderID;
  DateTime createdTime;
  String orderDeliveryDate;
  num? closingBalance;
  String shopID;
  num pickupRegularInKG;
  num pickupRegularInCount;
  num pickupSmallInKG;
  num pickupSmallInCount;
  num countTotal;
  num kgTotal;
  num boxesTaken;
  num boxesGiven;
  num grossTotal;
  num netTotal;
  num smallDiscountPerKG;
  num regularDiscountPerKG;
  num smallRatePerKG;
  num regularRatePerKG;
  num paperRate;
  String? routeID;
  String? tripID;
  String? driverID;
  String? vehicleID;
  String? discountID;
  Discount? discountInfo;
  Map inputValues;
  List<dynamic>? loadManIDs;

  String? docID;
  Shop? shopInfo;
  int slNo = 0;

  ReturnModel({
    this.orderID,
    required this.createdTime,
    required this.orderDeliveryDate,
    this.closingBalance,
    required this.shopID,
    this.routeID,
    required this.pickupRegularInKG,
    required this.pickupRegularInCount,
    required this.pickupSmallInKG,
    required this.pickupSmallInCount,
    required this.countTotal,
    required this.kgTotal,
    required this.boxesTaken,
    required this.boxesGiven,
    required this.grossTotal,
    required this.netTotal,
    required this.smallDiscountPerKG,
    required this.regularDiscountPerKG,
    required this.smallRatePerKG,
    required this.regularRatePerKG,
    required this.paperRate,
    this.tripID,
    this.driverID,
    this.vehicleID,
    this.loadManIDs,
    required this.inputValues,
    this.discountID,
    this.discountInfo,
    this.docID,
  });

  factory ReturnModel.fromFirestore(DocumentSnapshot doc) {
    Map? data = doc.data() as Map?;
    return ReturnModel(
        orderID: data!['orderID'],
        createdTime: DateTime.parse(data['createdTime'].toDate().toString()),
        orderDeliveryDate: data['orderDeliveryDate'],
        closingBalance: data['closingBalance'] ?? 0,
        shopID: data['shopID'],
        routeID: data['routeID'],
        pickupRegularInKG: data['pickupRegularInKG'] ?? 0,
        pickupSmallInKG: data['pickupSmallInKG'] ?? 0,
        pickupRegularInCount: data['pickupRegularInCount'],
        pickupSmallInCount: data['pickupSmallInCount'],
        smallDiscountPerKG: data['smallDiscountPerKG'] ?? 0,
        regularDiscountPerKG: data['regularDiscountPerKG'] ?? 0,
        smallRatePerKG: data['smallRatePerKG'] ?? 0,
        regularRatePerKG: data['regularRatePerKG'] ?? 0,
        paperRate: data['paperRate'] ?? 0,
        countTotal: data['countTotal'] ?? 0,
        kgTotal: data['kgTotal'] ?? 0,
        boxesTaken: data['boxesTaken'] ?? 0,
        boxesGiven: data['boxesGiven'] ?? 0,
        grossTotal: data['grossTotal'] ?? 0,
        netTotal: data['netTotal'] ?? 0,
        docID: doc.id,
        driverID: data['driverID'],
        vehicleID: data['vehicleID'],
        loadManIDs: data['loadManIDs'],
        inputValues: data['inputValues'],
        discountID: data['discountID'],
        discountInfo:
            Discount.fromMap(data['discountInfo'], data['discountID']),
        tripID: data['tripID']);
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> data = {
      'orderID': this.orderID,
      'createdTime': this.createdTime,
      'orderDeliveryDate': this.orderDeliveryDate,
      'closingBalance': this.closingBalance,
      'shopID': this.shopID,
      'routeID': this.routeID,
      'pickupRegularInKG': this.pickupRegularInKG,
      'pickupRegularInCount': this.pickupRegularInCount,
      'pickupSmallInKG': this.pickupSmallInKG,
      'pickupSmallInCount': this.pickupSmallInCount,
      'countTotal': this.countTotal,
      'kgTotal': this.kgTotal,
      'boxesTaken': this.boxesTaken,
      'boxesGiven': this.boxesGiven,
      'grossTotal': this.grossTotal,
      'netTotal': this.netTotal,
      'smallDiscountPerKG': this.smallDiscountPerKG,
      'regularDiscountPerKG': this.regularDiscountPerKG,
      'smallRatePerKG': this.smallRatePerKG,
      'regularRatePerKG': this.regularRatePerKG,
      'paperRate': this.paperRate,
      'tripID': this.tripID,
      'driverID': this.driverID,
      'vehicleID': this.vehicleID,
      'loadManIDs': this.loadManIDs,
      'inputValues': this.inputValues,
      'discountID': this.discountID,
      'discountInfo': this.discountInfo!.toMap(),
    };
    return data;
  }
}
