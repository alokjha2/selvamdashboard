import 'package:cloud_firestore/cloud_firestore.dart';

class Farm {
  final String companyName;
  final String farmName;
  final String address;
  final DateTime addedTime;

  int slNo = 0;
  String? docID;
  Farm(
      {required this.companyName,
      required this.farmName,
      required this.address,
      required this.addedTime,
      this.docID});

  factory Farm.fromFirestore(DocumentSnapshot doc) {
    Map? data = doc.data() as Map?;
    return Farm(
        companyName: data!['companyName'],
        farmName: data['farmName'],
        address: data['address'],
        addedTime: DateTime.parse(data['addedTime'].toDate().toString()),
        docID: doc.id);
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> data = {
      'companyName': this.companyName,
      'farmName': this.farmName,
      'address': this.address,
      'addedTime': this.addedTime,
    };
    return data;
  }
}
