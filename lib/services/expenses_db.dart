import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:selvam_broilers/models/expense.dart';
import 'package:selvam_broilers/models/fuel_expense.dart';
import 'package:selvam_broilers/models/fuel_expense.dart';
import 'package:selvam_broilers/models/fuel_expense.dart';
import 'package:selvam_broilers/models/fuel_expense.dart';
import 'package:selvam_broilers/models/trip.dart';
import 'package:selvam_broilers/services/storage.dart';
import 'package:selvam_broilers/utils/utils.dart';

class ExpensesDatabase {
  Storage storage = Storage();
  static final ExpensesDatabase _databaseInstance = ExpensesDatabase._();

  factory ExpensesDatabase() {
    return _databaseInstance;
  }

  ExpensesDatabase._();

  Future<List<FuelExpense>> getFuelExpenses(Trip trip) async {
    List<FuelExpense> list = [];
    try {
      final snap = await FirebaseFirestore.instance
          .collection('fuel_expenses')
          .where('tripID', isEqualTo: trip.docID)
          .get();
      snap.docs.forEach((doc) {
        FuelExpense t = FuelExpense.fromFirestore(doc);
        list.add(t);
      });
      return list;
    } catch (err) {
      print(err);
      return list;
    }
  }

  Future<List<Expense>> getExpenses(Trip trip) async {
    List<Expense> list = [];
    try {
      final snap = await FirebaseFirestore.instance
          .collection('expenses')
          .where('tripID', isEqualTo: trip.docID)
          .get();
      snap.docs.forEach((doc) {
        Expense t = Expense.fromFirestore(doc);
        list.add(t);
      });
      return list;
    } catch (err) {
      print(err);
      return list;
    }
  }

  Stream<DocumentSnapshot> listenExpenseListItems() {
    return FirebaseFirestore.instance
        .collection('app_data')
        .doc('expenses')
        .snapshots();
  }

  Future<bool> updateExpenseItemList(List<String> items) async {
    try {
      await FirebaseFirestore.instance
          .collection('app_data')
          .doc('expenses')
          .update({'expense_items': items});
      return true;
    } catch (err) {
      print(err);
      return false;
    }
  }

  Stream<QuerySnapshot> listenExpenses(Trip trip) {
    return FirebaseFirestore.instance
        .collection('expenses')
        .where('tripID', isEqualTo: trip.docID)
        .snapshots();
  }
}
