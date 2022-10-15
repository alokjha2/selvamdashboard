import 'package:cloud_firestore/cloud_firestore.dart';

class Discount {
  final DateTime addedTime;
  final num discount;
  num? closingBalance;
  final String description;
  final String shopID;
  String? docID;

  Discount(
      {required this.addedTime,
      required this.discount,
      required this.description,
      this.closingBalance,
      required this.shopID,
      this.docID});

  factory Discount.fromFirestore(DocumentSnapshot doc) {
    Map? data = doc.data() as Map?;
    return Discount(
        addedTime: DateTime.parse(data!['addedTime'].toDate().toString()),
        discount: data['discount'],
        closingBalance: data['closingBalance'],
        description: data['description'],
        shopID: data['shopID'],
        docID: doc.id);
  }

  factory Discount.fromMap(Map? data, String docID) {
    return Discount(
        addedTime: DateTime.parse(data!['addedTime'].toDate().toString()),
        discount: data['discount'],
        closingBalance: data['closingBalance'],
        description: data['description'],
        shopID: data['shopID'],
        docID: docID);
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> data = {
      'addedTime': this.addedTime,
      'discount': this.discount,
      'closingBalance': this.closingBalance,
      'description': this.description,
      'shopID': this.shopID,
    };
    return data;
  }
}
