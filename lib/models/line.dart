import 'package:cloud_firestore/cloud_firestore.dart';

class Line {
  final String lineName;
  final DateTime addedTime;
  final String agentID;
  final List<dynamic> shopIDs;
  int slNo = 0;
  String? docID;

  Line(
      {required this.lineName,
      required this.addedTime,
      required this.agentID,
      required this.shopIDs,
      this.docID});

  factory Line.fromFirestore(DocumentSnapshot doc) {
    Map? data = doc.data() as Map?;
    return Line(
        lineName: data!['lineName'],
        agentID: data['agentID'],
        shopIDs: data['shopIDs'],
        addedTime: DateTime.parse(data['addedTime'].toDate().toString()),
        docID: doc.id);
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> data = {
      'lineName': this.lineName,
      'addedTime': this.addedTime,
      'agentID': this.agentID,
      'shopIDs': this.shopIDs,
    };
    return data;
  }
}
