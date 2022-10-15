import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:selvam_broilers/models/route.dart';
import 'package:selvam_broilers/models/trip.dart';
import 'package:selvam_broilers/services/storage.dart';
import 'package:selvam_broilers/utils/flags.dart';

class TripDatabase {
  Storage storage = Storage();
  static final TripDatabase _databaseInstance = TripDatabase._();

  factory TripDatabase() {
    return _databaseInstance;
  }

  TripDatabase._();

  Future<bool> addTrip(Trip data) async {
    try {
      await FirebaseFirestore.instance.collection('trips').add(data.toMap());
      return true;
    } catch (err) {
      print(err);
      return false;
    }
  }

  Future<List<Trip>> getTripList(String date) async {
    List<Trip> tripList = [];
    try {
      final snap = await FirebaseFirestore.instance
          .collection('trips')
          .where('tripDate', isEqualTo: date)
          .get();
      snap.docs.forEach((doc) {
        Trip t = Trip.fromFirestore(doc);
        tripList.add(t);
      });
      return tripList;
    } catch (err) {
      print(err);
      return tripList;
    }
  }

  Future<List<Trip>> getTodaysInCompleteTrip(String date) async {
    List<Trip> tripList = [];
    try {
      final snap = await FirebaseFirestore.instance
          .collection('trips')
          .where('tripStatus', isNotEqualTo: TripStatus.COMPLETED.index)
          .where('tripDate', isEqualTo: date)
          .get();

      snap.docs.forEach((doc) {
        Trip t = Trip.fromFirestore(doc);
        tripList.add(t);
      });

      tripList.sort((b, a) => a.createdTime.compareTo(b.createdTime));

      return tripList;
    } catch (err) {
      print(err);
      return tripList;
    }
  }

  Stream<QuerySnapshot> listenTrips(String date) {
    return FirebaseFirestore.instance
        .collection('trips')
        .where('tripDate', isEqualTo: date)
        .snapshots();
  }

  Future<bool> deleteTrip(Trip data) async {
    try {
      await FirebaseFirestore.instance
          .collection('trips')
          .doc(data.docID)
          .delete();
      return true;
    } catch (err) {
      print(err);
      return false;
    }
  }

  Future<bool> endTrip({
    required Trip trip,
    required num endKM,
    required num boxes,
    required num mortalityKg,
    required num mortalityCount,
    required num amoutReturned,
    String? remarks,
    PlatformFile? proofPhoto,
    PlatformFile? mortalityPhoto,
    PlatformFile? loadingAreaCleanImage,
  }) async {
    try {
      WriteBatch batch = FirebaseFirestore.instance.batch();

      //uploading proof photo
      if (proofPhoto != null) {
        trip.feedProofImage = (await storage.uploadFile(
            proofPhoto, 'trips/${trip.docID}/', 'feed_proof_photo'))!;
      }

      //uploading proof photo
      if (mortalityPhoto != null) {
        trip.mortalityProofImage = (await storage.uploadFile(
            mortalityPhoto, 'trips/${trip.docID}/', 'mortality_proof_photo'))!;
      }

      //uploading clean proof photo
      if (loadingAreaCleanImage != null) {
        trip.loadingAreaCleanImage = (await storage.uploadFile(
            loadingAreaCleanImage,
            'trips/${trip.docID}/',
            'loadingarea_clean_proof_photo'))!;
      }

      batch.update(
          FirebaseFirestore.instance.collection('trips').doc(trip.docID), {
        'tripStatus': TripStatus.COMPLETED.index,
        'endKM': endKM,
        'boxesReturned': boxes,
        'endTime': DateTime.now(),
        'mortalityKG': mortalityKg,
        'mortalityCount': mortalityCount,
        'amoutReturned': amoutReturned,
        'remarks': remarks,
        'feedProofImage': trip.feedProofImage?.fullPath,
        'mortalityProofImage': trip.mortalityProofImage?.fullPath,
        'loadingAreaCleanImage': trip.loadingAreaCleanImage?.fullPath,
      });

      batch.update(
          FirebaseFirestore.instance.collection('drivers').doc(trip.driverID),
          {'onlineStatus': OnlineStatus.OFFLINE.index});

      for (String id in trip.loadManIDs!) {
        batch.update(FirebaseFirestore.instance.collection('loadman').doc(id),
            {'onlineStatus': OnlineStatus.OFFLINE.index});
      }

      batch.update(
          FirebaseFirestore.instance.collection('vehicles').doc(trip.vehicleID),
          {'runningKM': endKM, 'vehicleStatus': VehicleStatus.AVAILABLE.index});

      await batch.commit();
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }
}
