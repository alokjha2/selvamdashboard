import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:selvam_broilers/models/collection_agent.dart';
import 'package:selvam_broilers/models/driver.dart';
import 'package:selvam_broilers/models/line.dart';
import 'package:selvam_broilers/models/shop.dart';
import 'package:selvam_broilers/models/shop_payment.dart';
import 'package:selvam_broilers/services/network.dart';
import 'package:selvam_broilers/services/storage.dart';
import 'package:selvam_broilers/utils/flags.dart';
import 'package:http/http.dart' as http;
import 'package:selvam_broilers/utils/utils.dart';

import 'auth.dart';

class CollectionAgentDatabase {
  Storage storage = Storage();
  static final CollectionAgentDatabase _databaseInstance =
      CollectionAgentDatabase._();

  factory CollectionAgentDatabase() {
    return _databaseInstance;
  }

  CollectionAgentDatabase._();

  Future<bool> addCollectionAgent(
      {required CollectionAgent agent,
      PlatformFile? adhar,
      PlatformFile? photo}) async {
    try {
      var account =
          await FirebaseAuthService().checkAccountExist(agent.phoneNumber);
      if (account != null) {
        if (account is Driver) {
          showToast(
              message:
                  'Already a Driver account exist with the same number. Try different number');
        } else if (account is Shop) {
          showToast(
              message:
                  'Already a Shop exist with the same number. Try different number');
        } else if (account is CollectionAgent) {
          showToast(
              message:
                  'Already a Collection agent account exist with the same number. Try different number');
        }
        return false;
      }
      var url = Uri.parse('${BASE_URL}createFirebaseUser');
      var response = await http.post(url, headers: {
        "Access-Control-Allow-Origin": "*"
      }, body: {
        'fullName': agent.fullName,
        'phoneNumber': agent.phoneNumber,
        'role': 'COLLECTION_AGENT'
      });
      if (response.statusCode == 200) {
        //uploading image to sotrage
        if (adhar != null) {
          agent.adharImage = (await storage.uploadFile(
              adhar, 'collection_agents/${response.body}/', 'adhaar'))!;
        }

        if (photo != null) {
          agent.photo = (await storage.uploadFile(
              photo, 'collection_agents/${response.body}/', 'photo'))!;
        }

        await FirebaseFirestore.instance
            .collection('collection_agents')
            .doc(response.body)
            .set(agent.toMap());
        return true;
      } else if (response.statusCode == 500) {
        return false;
      } else {
        return false;
      }
    } catch (err) {
      print(err);
      return false;
    }
  }

  Future<bool> updateCollectionAgentAccountActive(CollectionAgent agent) async {
    try {
      if (agent.onlineStatus == OnlineStatus.ONLINE) {
        return false;
      }

      int status = -1;
      if (agent.accountActive == AccountStatus.ACTIVE) {
        status = AccountStatus.INACTIVE.index;
      } else {
        status = AccountStatus.ACTIVE.index;
      }
      await FirebaseFirestore.instance
          .collection('collection_agents')
          .doc(agent.docID)
          .update({'accountActive': status});
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> updateCollectionAgent(
      {required CollectionAgent agent,
      PlatformFile? adhar,
      PlatformFile? photo}) async {
    try {
      if (adhar == null) {
        //have to delete
        agent.adharImage = null;
      }

      if (photo == null) {
        agent.photo = null;
      }

      //uploading image to sotrage
      if (adhar != null && adhar.bytes != null) {
        agent.adharImage = (await storage.uploadFile(
            adhar, 'collection_agents/${agent.docID}/', 'adhaar'))!;
      }

      if (photo != null && photo.bytes != null) {
        agent.photo = (await storage.uploadFile(
            photo, 'collection_agents/${agent.docID}/', 'photo'))!;
      }

      await FirebaseFirestore.instance
          .collection('collection_agents')
          .doc(agent.docID)
          .update(agent.toMap());
      return true;
    } catch (err) {
      print(err);
      return false;
    }
  }

  Future<bool> deleteCollectionAgentAccount(CollectionAgent agent) async {
    try {
      if (agent.onlineStatus == OnlineStatus.ONLINE) {
        return false;
      }
      await FirebaseFirestore.instance
          .collection('collection_agents')
          .doc(agent.docID)
          .delete();
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<CollectionAgent?> getAgentByPhone(String phone) async {
    try {
      var snap = await FirebaseFirestore.instance
          .collection('collection_agent')
          .where('phoneNumber', isEqualTo: phone)
          .get();
      if (snap.docs.isNotEmpty) {
        return CollectionAgent.fromFirestore(snap.docs.first);
      }
      return null;
    } catch (err) {
      print(err);
      return null;
    }
  }

  Stream<QuerySnapshot> listenCollectionAgents() {
    return FirebaseFirestore.instance
        .collection('collection_agents')
        .orderBy('joinedTime', descending: true)
        .snapshots();
  }

  Future<List<CollectionAgent>> getAllCollectionAgents() async {
    List<CollectionAgent> list = [];
    try {
      var snapshot = await FirebaseFirestore.instance
          .collection('collection_agents')
          .orderBy('fullName', descending: false)
          .get();
      snapshot.docs.forEach((doc) {
        CollectionAgent agent = CollectionAgent.fromFirestore(doc);
        list.add(agent);
      });
      return list;
    } catch (e) {
      print(e);
      return list;
    }
  }

  Future<List<Line>> getAllLines(String agentID) async {
    List<Line> lineList = [];
    try {
      final snap = await FirebaseFirestore.instance
          .collection('collection_agents')
          .doc(agentID)
          .collection('lines')
          .get();
      snap.docs.forEach((doc) {
        lineList.add(Line.fromFirestore(doc));
      });
      return lineList;
    } catch (e) {
      print(e);
      return lineList;
    }
  }

  Future<CollectionAgent?> getAgent(String? id) async {
    print(id);
    if (id == null || id.isEmpty) return null;

    var doc = await FirebaseFirestore.instance
        .collection('collection_agents')
        .doc(id)
        .get();
    if (doc.exists) {
      return CollectionAgent.fromFirestore(doc);
    }
    return null;
  }

  Future<List<ShopPayment>> getAgentPayment(
      String agentID, DateTime time) async {
    List<ShopPayment> list = [];
    var startDate = DateTime(time.year, time.month, time.day, 0, 0);
    var endDate = DateTime(time.year, time.month, time.day, 23, 59, 59);
    var snaps = await FirebaseFirestore.instance
        .collectionGroup('payments')
        .where('agentID', isEqualTo: agentID)
        .where('paymentTime', isGreaterThan: startDate, isLessThan: endDate)
        .get();

    snaps.docs.forEach((doc) {
      list.add(ShopPayment.fromFirestore(doc));
    });
    return list;
  }
}
