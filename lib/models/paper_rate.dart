import 'package:cloud_firestore/cloud_firestore.dart';

class PaperRate {
  final String date;
  final DateTime addedTime;
  final Map<String, dynamic> paperRates;

  String? docID;
  int slNo = 0;

  PaperRate(
      {required this.date,
      required this.addedTime,
      required this.paperRates,
      this.docID});

  factory PaperRate.fromFirestore(DocumentSnapshot doc) {
    Map? data = doc.data() as Map?;
    return PaperRate(
      date: data!['date'],
      paperRates: data['paperRates'],
      addedTime: DateTime.parse(data['addedTime'].toDate().toString()),
      docID: doc.id,
    );
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> data = {
      'date': this.date,
      'addedTime': this.addedTime,
      'paperRates': this.paperRates,
    };
    return data;
  }
}
