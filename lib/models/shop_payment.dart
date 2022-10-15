import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:selvam_broilers/utils/flags.dart';

class ShopPayment {
  final String shopID;
  final DateTime paymentTime;
  final num totalAmount;
  final num cashAmount;
  final num chequeAmount;
  final num gpayAmount;
  final List<PaymentMode> paymentModes;
  final PaidTo paidTo;
  num? closingBalance;
  String? saleOrderID;
  int slNo = 0;
  String? docID;
  String? driverID;
  String? agentID;
  Reference? chequeImage;
  String? chequeNumber;
  Map<dynamic, dynamic>? denominations;

  ShopPayment(
      {required this.shopID,
      required this.paymentTime,
      required this.totalAmount,
      required this.cashAmount,
      required this.chequeAmount,
      required this.gpayAmount,
      required this.paymentModes,
      required this.paidTo,
      this.closingBalance,
      this.chequeImage,
      this.saleOrderID,
      this.driverID,
      this.agentID,
      this.chequeNumber,
      this.denominations,
      this.docID});

  factory ShopPayment.fromFirestore(DocumentSnapshot doc) {
    Map? data = doc.data() as Map?;
    List<PaymentMode> paymentModeList = [];
    for (var e in data!['paymentModes']) {
      paymentModeList.add(PaymentMode.values[e]);
    }

    return ShopPayment(
        shopID: data['shopID'],
        paymentTime: DateTime.parse(data['paymentTime'].toDate().toString()),
        totalAmount: data['totalAmount'],
        cashAmount: data['cashAmount'],
        chequeAmount: data['chequeAmount'],
        gpayAmount: data['gpayAmount'],
        closingBalance: data['closingBalance'] ?? 0,
        paymentModes: paymentModeList,
        paidTo: PaidTo.values[data['paidTo']],
        chequeImage: FirebaseStorage.instance.ref(data['chequeImage']),
        saleOrderID: data['saleOrderID'],
        driverID: data['driverID'],
        agentID: data['agentID'],
        chequeNumber: data['chequeNumber'],
        denominations: data['denominations'],
        docID: doc.id);
  }

  factory ShopPayment.fromMap(Map? data) {
    List<PaymentMode> paymentModeList = [];
    for (var e in data!['paymentModes']) {
      paymentModeList.add(PaymentMode.values[e]);
    }
    return ShopPayment(
      shopID: data['shopID'],
      paymentTime: DateTime.parse(data['paymentTime'].toDate().toString()),
      totalAmount: data['totalAmount'],
      cashAmount: data['cashAmount'],
      chequeAmount: data['chequeAmount'],
      gpayAmount: data['gpayAmount'],
      closingBalance: data['closingBalance'] ?? 0,
      paymentModes: paymentModeList,
      paidTo: PaidTo.values[data['paidTo']],
      chequeImage: FirebaseStorage.instance.ref(data['chequeImage']),
      saleOrderID: data['saleOrderID'],
      driverID: data['driverID'],
      agentID: data['agentID'],
      chequeNumber: data['chequeNumber'],
      denominations: data['denominations'],
    );
  }

  Map<String, dynamic> toMap() {
    List paymentModelist = [];
    this.paymentModes.forEach((element) {
      paymentModelist.add(element.index);
    });

    Map<String, dynamic> data = {
      'shopID': this.shopID,
      'paymentTime': this.paymentTime,
      'totalAmount': this.totalAmount,
      'cashAmount': this.cashAmount,
      'chequeAmount': this.chequeAmount,
      'gpayAmount': this.gpayAmount,
      'closingBalance': this.closingBalance,
      'paymentModes': paymentModelist,
      'paidTo': this.paidTo.index,
      'chequeImage': this.chequeImage == null ? '' : this.chequeImage!.fullPath,
      'saleOrderID': this.saleOrderID,
      'driverID': this.driverID,
      'agentID': this.agentID,
      'chequeNumber': this.chequeNumber,
      'denominations': this.denominations,
    };
    return data;
  }
}
