import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:selvam_broilers/models/shop.dart';
import 'package:selvam_broilers/models/shop_payment.dart';
import 'package:selvam_broilers/utils/flags.dart';

class DirectSale {
  String orderID;
  DateTime createdTime;
  String orderDate;
  String shopID;
  OrderStatus orderStatus;
  num? boxesTaken;
  num? boxesGiven;
  num? grossTotal;
  num? netTotal;
  num? discount;
  num? closingBalance;
  num paperRate;
  String? paymentID;
  String? docID;
  String? routeID;
  String? discountDescription;
  OrderBy orderPlacedBy;
  OrderType orderType;
  Map<dynamic, dynamic> deliveryDetails;

  ShopPayment? paymentInfo;
  Shop? shopInfo;
  int slNo = 0;

  DirectSale({
    required this.orderID,
    required this.orderDate,
    required this.createdTime,
    required this.shopID,
    required this.orderStatus,
    required this.orderType,
    required this.orderPlacedBy,
    required this.routeID,
    this.closingBalance,
    this.paymentID,
    this.boxesTaken,
    this.boxesGiven,
    this.grossTotal,
    this.netTotal,
    this.discount,
    required this.paperRate,
    this.docID,
    this.paymentInfo,
    this.discountDescription,
    required this.deliveryDetails,
  });

  factory DirectSale.fromFirestore(DocumentSnapshot doc) {
    Map? data = doc.data() as Map?;
    return DirectSale(
      orderID: data!['orderID'],
      orderStatus: OrderStatus.values[data['orderStatus'] ?? 0],
      orderPlacedBy: OrderBy.values[data['orderPlacedBy'] ?? 0],
      orderType: OrderType.values[data['orderType'] ?? 0],
      createdTime: DateTime.parse(data['createdTime'].toDate().toString()),
      orderDate: data['orderDate'] ?? '',
      shopID: data['shopID'],
      routeID: data['routeID'],
      paymentID: data['paymentID'],
      boxesTaken: data['boxesTaken'] ?? 0,
      boxesGiven: data['boxesGiven'] ?? 0,
      grossTotal: data['grossTotal'] ?? 0,
      closingBalance: data['closingBalance'] ?? 0,
      netTotal: data['netTotal'] ?? 0,
      discount: data['discount'] ?? 0,
      paperRate: data['paperRate'] ?? 0,
      docID: doc.id,
      paymentInfo: data['paymentInfo'] != null
          ? ShopPayment.fromMap(data['paymentInfo'])
          : null,
      deliveryDetails: data['deliveryDetails'],
      discountDescription: data['discountDescription'],
    );
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> data = {
      'orderID': this.orderID,
      'createdTime': this.createdTime,
      'shopID': this.shopID,
      'orderDate': this.orderDate,
      'orderStatus': this.orderStatus.index,
      'paymentID': this.paymentID,
      'boxesTaken': this.boxesTaken,
      'boxesGiven': this.boxesGiven,
      'grossTotal': this.grossTotal,
      'paperRate': this.paperRate,
      'netTotal': this.netTotal,
      'closingBalance': this.closingBalance,
      'discount': this.discount,
      'routeID': this.routeID,
      'orderPlacedBy': this.orderPlacedBy.index,
      'orderType': this.orderType.index,
      'deliveryDetails': this.deliveryDetails,
      'discountDescription': this.discountDescription,
      'paymentInfo': this.paymentInfo?.toMap(),
    };
    return data;
  }
}
