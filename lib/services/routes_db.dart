import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:selvam_broilers/models/route.dart';
import 'package:selvam_broilers/models/shop.dart';
import 'package:selvam_broilers/services/storage.dart';
import 'package:selvam_broilers/utils/flags.dart';

class RouteDatabase {
  Storage storage = Storage();
  static final RouteDatabase _databaseInstance = RouteDatabase._();

  factory RouteDatabase() {
    return _databaseInstance;
  }

  RouteDatabase._();

  Future<List<TripRoute>> getAllRoutes() async {
    List<TripRoute> routeList = [];
    try {
      var snap = await FirebaseFirestore.instance
          .collection('routes')
          .orderBy('addedTime', descending: true)
          .get();
      snap.docs.forEach((doc) {
        routeList.add(TripRoute.fromFirestore(doc));
      });
      return routeList;
    } catch (err) {
      print(err);
      return routeList;
    }
  }

  Future<bool> addRoute(TripRoute data) async {
    try {
      await FirebaseFirestore.instance.collection('routes').add(data.toMap());
      return true;
    } catch (err) {
      print(err);
      return false;
    }
  }

  Future<bool> updateRoute(TripRoute data) async {
    try {
      await FirebaseFirestore.instance
          .collection('routes')
          .doc(data.docID)
          .update(data.toMap());
      return true;
    } catch (err) {
      print(err);
      return false;
    }
  }

  Future<bool> deleteRoute(TripRoute data) async {
    try {
      await FirebaseFirestore.instance
          .collection('routes')
          .doc(data.docID)
          .delete();
      return true;
    } catch (err) {
      print(err);
      return false;
    }
  }

  Future<TripRoute?> getRoute(String docID) async {
    try {
      var doc = await FirebaseFirestore.instance
          .collection('routes')
          .doc(docID)
          .get();
      if (doc.exists) {
        return TripRoute.fromFirestore(doc);
      }
      return null;
    } catch (err) {
      print(err);
      return null;
    }
  }

  Future<bool> updateShopOrderForRoute(Shop shop) async {
    try {
      WriteBatch batch = FirebaseFirestore.instance.batch();
      var db = FirebaseFirestore.instance;
      var allRoutes = await getAllRoutes();

      for (TripRoute route in allRoutes) {
        if (shop.routeIDs.contains(route.docID)) {
          //adding shop to route id
          batch.update(db.collection('routes').doc(route.docID), {
            'shopOrder': FieldValue.arrayUnion([shop.docID])
          });
        } else {
          //remove shop to route id
          batch.update(db.collection('routes').doc(route.docID), {
            'shopOrder': FieldValue.arrayRemove([shop.docID])
          });
        }
      }

      await batch.commit();
      return true;
    } catch (err) {
      print(err);
      return false;
    }
  }

  Future<bool> deleteShopOrderForRoute(Shop shop) async {
    try {
      WriteBatch batch = FirebaseFirestore.instance.batch();
      var db = FirebaseFirestore.instance;

      for (String routeID in shop.routeIDs) {
        if (shop.routeIDs.contains(routeID)) {
          batch.update(db.collection('routes').doc(routeID), {
            'shopOrder': FieldValue.arrayRemove([shop.docID])
          });
        }
      }

      await batch.commit();
      return true;
    } catch (err) {
      print(err);
      return false;
    }
  }

  Future<bool> shiftShopPosition(
      TripRoute route, Shop shop, Direction dir) async {
    try {
      var db = FirebaseFirestore.instance;

      var shopOrder = route.shopOrder!.toList(growable: true);
      int index = shopOrder.indexOf(shop.docID);

      if (dir == Direction.UP) {
        if (index == 0) {
          //nothing to do, it is already in top
          return true;
        }

        var cache = shopOrder[index - 1];
        shopOrder[index - 1] = shopOrder[index]; //shift up the row
        shopOrder[index] = cache; //shift down the row
      } else {
        if (index == shopOrder.length - 1) {
          //nothing to do, it is already in bottom
          return true;
        }

        var cache = shopOrder[index + 1];
        shopOrder[index + 1] = shopOrder[index]; //shift up the row
        shopOrder[index] = cache; //shift down the row
      }

      await db
          .collection('routes')
          .doc(route.docID)
          .update({'shopOrder': shopOrder});

      return true;
    } catch (err) {
      print(err);
      return false;
    }
  }

  Future<TripRoute?> fetchRouteInfo(String docID) async {
    final route = await RouteDatabase().getRoute(docID);
    if (route != null) {
      return route;
    }
    return null;
  }

  Stream<QuerySnapshot> listenRoutes() {
    return FirebaseFirestore.instance
        .collection('routes')
        .orderBy('addedTime', descending: true)
        .snapshots();
  }
}
