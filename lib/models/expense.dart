import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Expense {
  final DateTime dateTime;
  final num expenseAmount;
  final String description;
  final String tripID;
  final String routeID;
  final String vehicleID;
  final String driverID;
  String? vehicleExpenseID;
  int slNo = 0;
  String? docID;

  Expense(
      {required this.dateTime,
      required this.expenseAmount,
      required this.description,
      required this.tripID,
      required this.routeID,
      required this.vehicleID,
      required this.driverID,
      this.vehicleExpenseID,
      this.docID});

  factory Expense.fromFirestore(DocumentSnapshot doc) {
    Map? data = doc.data() as Map?;
    return Expense(
        dateTime: DateTime.parse(data!['dateTime'].toDate().toString()),
        expenseAmount: data['expenseAmount'],
        description: data['description'],
        tripID: data['tripID'],
        routeID: data['routeID'],
        vehicleID: data['vehicleID'],
        driverID: data['driverID'],
        vehicleExpenseID: data['vehicleExpenseID'],
        docID: doc.id);
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> data = {
      'dateTime': this.dateTime,
      'expenseAmount': this.expenseAmount,
      'description': this.description,
      'tripID': this.tripID,
      'routeID': this.routeID,
      'vehicleID': this.vehicleID,
      'driverID': this.driverID,
      'vehicleExpenseID': this.vehicleExpenseID,
    };
    return data;
  }
}
