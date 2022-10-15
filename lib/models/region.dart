import 'package:cloud_firestore/cloud_firestore.dart';

class Region {
  final String regionName;
  final DateTime addedTime;

  String? docID;
  int slNo = 0;

  Region({required this.regionName, required this.addedTime, this.docID});

  factory Region.fromFirestore(DocumentSnapshot doc) {
    Map? data = doc.data() as Map?;
    return Region(
      regionName: data!['regionName'],
      addedTime: DateTime.parse(data['addedTime'].toDate().toString()),
      docID: doc.id,
    );
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> data = {
      'regionName': this.regionName,
      'addedTime': this.addedTime,
    };
    return data;
  }
}
