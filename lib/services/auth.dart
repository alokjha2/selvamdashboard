import 'package:firebase_auth/firebase_auth.dart';
import 'package:selvam_broilers/models/collection_agent.dart';
import 'package:selvam_broilers/models/driver.dart';
import 'package:selvam_broilers/models/shop.dart';
import 'package:selvam_broilers/services/collection_agent_db.dart';
import 'package:selvam_broilers/services/shops_db.dart';
import 'driver_db.dart';

class FirebaseAuthService {
  FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseAuthService _firebaseAuthServiceInstance =
      FirebaseAuthService._();

  factory FirebaseAuthService() {
    return _firebaseAuthServiceInstance;
  }
  FirebaseAuthService._();

  Future<User?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      if (result.user != null) {
        return result.user;
      } else {
        return null;
      }
    } catch (e) {
      throw e;
    }
  }

  Future<dynamic> checkAccountExist(String phone) async {
    try {
      CollectionAgent? agent =
          await CollectionAgentDatabase().getAgentByPhone(phone);
      if (agent != null) {
        return agent;
      }
      Shop? shop = await ShopDatabase().getShopByPhone(phone);
      if (shop != null) {
        return shop;
      }
      Driver? driver = await DriverDatabase().getDriverByPhone(phone);
      if (driver != null) {
        return driver;
      }
    } catch (e) {}
  }

  Future<bool> signOut() async {
    try {
      await _auth.signOut();
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }
}
