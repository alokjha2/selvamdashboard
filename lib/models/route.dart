import 'package:cloud_firestore/cloud_firestore.dart';

class TripRoute {
  final String routeName;
  final String routeNumber;
  final DateTime addedTime;

  List<dynamic>? shopOrder;
  String? docID;
  int slNo = 0;

  TripRoute(
      {required this.routeName,
      required this.routeNumber,
      required this.addedTime,
      this.docID,
      this.shopOrder});

  factory TripRoute.fromFirestore(DocumentSnapshot doc) {
    Map? data = doc.data() as Map?;
    return TripRoute(
      routeName: data!['routeName'],
      routeNumber: data['routeNumber'],
      shopOrder: data['shopOrder'],
      addedTime: DateTime.parse(data['addedTime'].toDate().toString()),
      docID: doc.id,
    );
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> data = {
      'routeName': this.routeName,
      'routeNumber': this.routeNumber,
      'addedTime': this.addedTime,
      'shopOrder': this.shopOrder,
    };
    return data;
  }
}
