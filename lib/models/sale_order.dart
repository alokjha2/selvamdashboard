import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:selvam_broilers/models/shop.dart';
import 'package:selvam_broilers/models/shop_payment.dart';
import 'package:selvam_broilers/utils/flags.dart';

class SaleOrder {
  String orderID;
  DateTime createdTime;
  String orderDate;
  num regularInKG;
  num regularInCount;
  num smallInKG;
  num smallWeightRef;
  num smallInCount;
  num? closingBalance;
  String shopID;
  String routeID;
  OrderStatus orderStatus;
  DateTime? completedTime;
  num? deliveredRegularInKG;
  num? deliveredRegularInCount;
  num? deliveredSmallInKG;
  num? deliveredSmallInCount;
  num? countTotal;
  num? kgTotal;
  num? boxesTaken;
  num? boxesGiven;
  num? grossTotal;
  num? netTotal;
  num? smallDiscountPerKG;
  num? regularDiscountPerKG;
  num? smallRatePerKG;
  num? regularRatePerKG;
  num? paperRate;
  Reference? proofImage;

  ShopPayment? paymentInfo;
  String? paymentID;
  String? docID;
  String? tripID;
  String? driverID;
  String? vehicleID;
  List<dynamic>? loadManIDs;
  Shop? shopInfo;
  OrderBy orderPlacedBy;
  OrderType orderType;
  Map? inputValues;
  int slNo = 0;

  SaleOrder({
    required this.orderID,
    required this.orderDate,
    required this.createdTime,
    required this.regularInKG,
    required this.regularInCount,
    required this.smallInKG,
    required this.smallWeightRef,
    required this.smallInCount,
    required this.shopID,
    required this.routeID,
    required this.orderStatus,
    required this.orderType,
    required this.orderPlacedBy,
    this.completedTime,
    this.closingBalance,
    this.paymentID,
    this.deliveredRegularInKG,
    this.deliveredRegularInCount,
    this.deliveredSmallInKG,
    this.deliveredSmallInCount,
    this.smallDiscountPerKG,
    this.regularDiscountPerKG,
    this.smallRatePerKG,
    this.regularRatePerKG,
    this.paperRate,
    this.countTotal,
    this.boxesTaken,
    this.boxesGiven,
    this.kgTotal,
    this.grossTotal,
    this.netTotal,
    this.tripID,
    this.driverID,
    this.loadManIDs,
    this.vehicleID,
    this.proofImage,
    this.inputValues,
    this.docID,
    this.paymentInfo,
  });

  factory SaleOrder.fromFirestore(DocumentSnapshot doc) {
    Map? data = doc.data() as Map?;
    return SaleOrder(
      orderID: data!['orderID'],
      orderStatus: OrderStatus.values[data['orderStatus'] ?? 0],
      orderPlacedBy: OrderBy.values[data['orderPlacedBy'] ?? 0],
      orderType: OrderType.values[data['orderType'] ?? 0],
      createdTime: DateTime.parse(data['createdTime'].toDate().toString()),
      orderDate: data['orderDate'],
      closingBalance: data['closingBalance'] ?? 0,
      completedTime: data['completedTime'] != null
          ? DateTime.parse(data['completedTime'].toDate().toString())
          : null,
      regularInKG: data['regularInKG'],
      regularInCount: data['regularInCount'],
      smallInKG: data['smallInKG'],
      smallWeightRef: data['smallWeightRef'] ?? 0,
      smallInCount: data['smallInCount'],
      shopID: data['shopID'],
      routeID: data['routeID'],
      paymentID: data['paymentID'],
      proofImage: FirebaseStorage.instance.ref(data['proofImage']),
      deliveredRegularInKG: data['deliveredRegularInKG'] ?? 0,
      deliveredRegularInCount: data['deliveredRegularInCount'] ?? 0,
      deliveredSmallInKG: data['deliveredSmallInKG'] ?? 0,
      deliveredSmallInCount: data['deliveredSmallInCount'] ?? 0,
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
      tripID: data['tripID'],
      driverID: data['driverID'],
      vehicleID: data['vehicleID'],
      loadManIDs: data['loadManIDs'],
      inputValues: data['inputValues'],
      paymentInfo: data['paymentInfo'] != null
          ? ShopPayment.fromMap(data['paymentInfo'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> data = {
      'orderID': this.orderID,
      'createdTime': this.createdTime,
      'regularInKG': this.regularInKG,
      'regularInCount': this.regularInCount,
      'smallInKG': this.smallInKG,
      'smallWeightRef': this.smallWeightRef,
      'smallInCount': this.smallInCount,
      'shopID': this.shopID,
      'routeID': this.routeID,
      'orderDate': this.orderDate,
      'closingBalance': this.closingBalance,
      'orderStatus': this.orderStatus.index,
      'completedTime': this.completedTime,
      'deliveredRegularInKG': this.deliveredRegularInKG,
      'deliveredRegularInCount': this.deliveredRegularInCount,
      'deliveredSmallInKG': this.deliveredSmallInKG,
      'deliveredSmallInCount': this.deliveredSmallInCount,
      'smallDiscountPerKG': this.smallDiscountPerKG,
      'paperRate': this.paperRate,
      'regularDiscountPerKG': this.regularDiscountPerKG,
      'smallRatePerKG': this.smallRatePerKG,
      'regularRatePerKG': this.regularRatePerKG,
      'kgTotal': this.kgTotal,
      'paymentID': this.paymentID,
      'countTotal': this.countTotal,
      'boxesTaken': this.boxesTaken,
      'boxesGiven': this.boxesGiven,
      'grossTotal': this.grossTotal,
      'netTotal': this.netTotal,
      'tripID': this.tripID,
      'proofImage': this.proofImage == null ? '' : this.proofImage!.fullPath,
      'driverID': this.driverID,
      'vehicleID': this.vehicleID,
      'loadManIDs': this.loadManIDs,
      'inputValues': this.inputValues,
      'orderPlacedBy': this.orderPlacedBy.index,
      'orderType': this.orderType.index,
      'paymentInfo': this.paymentInfo?.toMap(),
    };
    return data;
  }
}
