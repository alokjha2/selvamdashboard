import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:selvam_broilers/models/fuel_expense.dart';
import 'package:selvam_broilers/models/vehicle.dart';
import 'package:selvam_broilers/models/vehicle_service.dart';
import 'package:selvam_broilers/services/storage.dart';
import 'auth.dart';

class VehicleDatabase {
  FirebaseAuthService _firebaseAuthService = FirebaseAuthService();
  Storage storage = Storage();
  static final VehicleDatabase _databaseInstance = VehicleDatabase._();

  factory VehicleDatabase() {
    return _databaseInstance;
  }

  VehicleDatabase._();

  Future<List<Vehicle>> getAllVehicles() async {
    List<Vehicle> vehicleList = [];
    try {
      var snap = await FirebaseFirestore.instance.collection('vehicles').get();
      snap.docs.forEach((doc) {
        vehicleList.add(Vehicle.fromFirestore(doc));
      });
      return vehicleList;
    } catch (err) {
      print(err);
      return vehicleList;
    }
  }

  Future<bool> addVehicle(Vehicle data) async {
    try {
      await FirebaseFirestore.instance.collection('vehicles').add(data.toMap());
      return true;
    } catch (err) {
      print(err);
      return false;
    }
  }

  Future<bool> deleteVehicleAccount(Vehicle v) async {
    try {
      await FirebaseFirestore.instance
          .collection('vehicles')
          .doc(v.docID)
          .delete();
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<Vehicle?> getVehicles(String docID) async {
    try {
      var doc = await FirebaseFirestore.instance
          .collection('vehicles')
          .doc(docID)
          .get();

      return Vehicle.fromFirestore(doc);
    } catch (err) {
      print(err);
      return null;
    }
  }

  Stream<QuerySnapshot> listenVehicles() {
    return FirebaseFirestore.instance.collection('vehicles').snapshots();
  }

  Stream<QuerySnapshot> listenServiceDue(Vehicle v) {
    return FirebaseFirestore.instance
        .collection('vehicles')
        .doc(v.docID)
        .collection('service_history')
        .orderBy('serviceDate', descending: true)
        .snapshots();
  }

  Future<bool> addServiceHistory(
      Vehicle vehicle, VehicleService service) async {
    try {
      await FirebaseFirestore.instance
          .collection('vehicles')
          .doc(vehicle.docID)
          .collection('service_history')
          .add(service.toMap());
      await updateServiceDueKm(vehicle, service.nextDueKM);
      return true;
    } catch (err) {
      print(err);
      return false;
    }
  }

  Future<bool> deleteServiceHistory(Vehicle v, VehicleService service) async {
    try {
      await FirebaseFirestore.instance
          .collection('vehicles')
          .doc(v.docID)
          .collection('service_history')
          .doc(service.docID)
          .delete();
      await updateServiceDueKm(v, service.nextDueKM);
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> updateServiceHistory(
      Vehicle vehicle, VehicleService service) async {
    try {
      await FirebaseFirestore.instance
          .collection('vehicles')
          .doc(vehicle.docID)
          .collection('service_history')
          .doc(service.docID)
          .update(service.toMap());

      await updateServiceDueKm(vehicle, service.nextDueKM);
      return true;
    } catch (err) {
      print(err);
      return false;
    }
  }

  Future<bool> updateServiceDueKm(Vehicle v, num km) async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('vehicles')
          .doc(v.docID)
          .collection('service_history')
          .orderBy('nextDueKM', descending: true)
          .get();

      VehicleService vs = VehicleService.fromFirestore(snap.docs.first);
      //
      // if (vs.nextDueKM <= 0) {
      //   return true;
      // }

      await FirebaseFirestore.instance
          .collection('vehicles')
          .doc(v.docID)
          .update({'serviceDueKM': vs.nextDueKM});
      return true;
    } catch (err) {
      print(err);
      return false;
    }
  }

  Future<List<FuelExpense>> getFuelExpense(Vehicle v) async {
    List<FuelExpense> list = [];
    try {
      var snap = await FirebaseFirestore.instance
          .collection('fuel_expenses')
          .where('vehicleID', isEqualTo: v.docID)
          .orderBy('fillDateTime', descending: true)
          .get();
      snap.docs.forEach((doc) {
        list.add(FuelExpense.fromFirestore(doc));
      });
      return list;
    } catch (err) {
      print(err);
      return list;
    }
  }
}
