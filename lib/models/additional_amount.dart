import 'package:cloud_firestore/cloud_firestore.dart';

class AdditionalAmount {
  final DateTime addedTime;
  final num amount;
  num? closingBalance;
  final String description;
  final String shopID;
  String? docID;
  String? orderId;
  String? type;
  num? oldPaperRate;
  num? newPaperRate;
  num? newTotal;
  num? oldTotal;

  AdditionalAmount(
      {required this.addedTime,
      required this.amount,
      required this.description,
      this.closingBalance,
      required this.shopID,
      this.orderId,
      this.type,
      this.oldPaperRate,
      this.newPaperRate,
      this.newTotal,
      this.oldTotal,
      this.docID});

  factory AdditionalAmount.fromFirestore(DocumentSnapshot doc) {
    Map? data = doc.data() as Map?;
    return AdditionalAmount(
        addedTime: DateTime.parse(data!['addedTime'].toDate().toString()),
        amount: data['amount'],
        closingBalance: data['closingBalance'],
        description: data['description'],
        shopID: data['shopID'],
        docID: doc.id);
  }

  factory AdditionalAmount.fromMap(Map? data, String docID) {
    return AdditionalAmount(
        addedTime: DateTime.parse(data!['addedTime'].toDate().toString()),
        amount: data['amount'],
        closingBalance: data['closingBalance'],
        description: data['description'],
        shopID: data['shopID'],
        docID: docID);
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> data = {
      'addedTime': this.addedTime,
      'amount': this.amount,
      'closingBalance': this.closingBalance,
      'description': this.description,
      'shopID': this.shopID,
      'orderId': this.orderId,
      'type': this.type,
      'oldPaperRate': this.oldPaperRate,
      'newPaperRate': this.newPaperRate,
      'newTotal': this.newTotal,
      'oldTotal': this.oldTotal,
    };
    return data;
  }
}
