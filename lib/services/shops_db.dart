import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:selvam_broilers/models/additional_amount.dart';
import 'package:selvam_broilers/models/collection_agent.dart';
import 'package:selvam_broilers/models/discount.dart';
import 'package:selvam_broilers/models/driver.dart';
import 'package:selvam_broilers/models/line.dart';
import 'package:selvam_broilers/models/shop.dart';
import 'package:selvam_broilers/models/shop_payment.dart';
import 'package:selvam_broilers/services/auth.dart';
import 'package:selvam_broilers/services/network.dart';
import 'package:selvam_broilers/services/routes_db.dart';
import 'package:selvam_broilers/services/storage.dart';
import 'package:selvam_broilers/utils/flags.dart';
import 'package:http/http.dart' as http;
import 'package:selvam_broilers/utils/utils.dart';

class ShopDatabase {
  Storage storage = Storage();
  static final ShopDatabase _databaseInstance = ShopDatabase._();

  factory ShopDatabase() {
    return _databaseInstance;
  }

  ShopDatabase._();

  Future<bool> createShop({
    required Shop shop,
    PlatformFile? ownerPhoto,
    PlatformFile? shopPhoto,
  }) async {
    try {
      //no need to create a child shop user in auth, we just need to create the field
      if (shop.shopType == ShopType.CHILD) {
        shop.docID = FirebaseFirestore.instance.collection('shops').doc().id;
      } else {
        var account =
            await FirebaseAuthService().checkAccountExist(shop.phoneNumber);
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
          'fullName': shop.shopName,
          'phoneNumber': shop.phoneNumber,
          'role': 'SHOP'
        });
        if (response.statusCode == 200) {
          shop.docID = response.body;
        }
      }

      if (shop.docID == null || shop.docID!.isEmpty) {
        return false;
      }

      // uploading image to sotrage
      if (ownerPhoto != null) {
        shop.ownerPhoto = (await storage.uploadFile(
            ownerPhoto, 'shops/${shop.docID}/', 'ownerPhoto'))!;
      }

      if (shopPhoto != null) {
        shop.shopPhoto = (await storage.uploadFile(
            shopPhoto, 'shops/${shop.docID}/', 'shopPhoto'))!;
      }

      WriteBatch batch = FirebaseFirestore.instance.batch();
      if (shop.shopType == ShopType.PARENT) {
        //add child to all parent
        shop.childShops?.forEach((shopID) {
          batch.update(
              FirebaseFirestore.instance.collection('shops').doc(shopID),
              {'shopType': ShopType.CHILD.index, 'parentShop': shop.docID!});
        });
      } else if (shop.shopType == ShopType.CHILD) {
        if (shop.parentShop != null && shop.parentShop!.isNotEmpty) {
          batch.update(
              FirebaseFirestore.instance
                  .collection('shops')
                  .doc(shop.parentShop),
              {
                'shopType': ShopType.PARENT.index,
                'childShops': FieldValue.arrayUnion([shop.docID!])
              });
        }
      }

      batch.set(FirebaseFirestore.instance.collection('shops').doc(shop.docID),
          shop.toMap());

      await batch.commit();
      await RouteDatabase().updateShopOrderForRoute(shop);
      return true;
    } catch (err) {
      print(err);
      return false;
    }
  }

  Future<bool> updateShop({
    required Shop newShop,
    required Shop oldShop,
    PlatformFile? ownerPhoto,
    PlatformFile? shopPhoto,
  }) async {
    try {
      if (oldShop.phoneNumber != newShop.phoneNumber) {
        var account =
            await FirebaseAuthService().checkAccountExist(newShop.phoneNumber);
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

        var url = Uri.parse('${BASE_URL}updateFirebaseUserPhoneNumber');
        var response = await http.post(url, headers: {
          "Access-Control-Allow-Origin": "*"
        }, body: {
          'uid': newShop.docID,
          'phoneNumber': newShop.phoneNumber,
        });
        if (response.statusCode == 200) {
        } else {
          return false;
        }
      }

      //delete
      if (ownerPhoto == null) {
        newShop.ownerPhoto = null;
      }

      if (shopPhoto == null) {
        newShop.shopPhoto = null;
      }

      //uploading image to sotrage
      if (ownerPhoto != null && ownerPhoto.bytes != null) {
        newShop.ownerPhoto = (await storage.uploadFile(
            ownerPhoto, 'shops/${newShop.docID}/', 'ownerPhoto'))!;
      }

      if (shopPhoto != null && shopPhoto.bytes != null) {
        newShop.shopPhoto = (await storage.uploadFile(
            shopPhoto, 'shops/${newShop.docID}/', 'shopPhoto'))!;
      }

      WriteBatch batch = FirebaseFirestore.instance.batch();

      if (newShop.shopType == ShopType.PARENT) {
        //add child to all parent
        newShop.childShops?.forEach((shopID) {
          batch.update(
              FirebaseFirestore.instance.collection('shops').doc(shopID),
              {'parentShop': newShop.docID!});
        });

        if (oldShop.childShops != null) {
          oldShop.childShops!.forEach((shopID) {
            if (!newShop.childShops!.contains(shopID)) {
              //removed, go to its parent & mark it as null
              batch.update(
                  FirebaseFirestore.instance.collection('shops').doc(shopID),
                  {'parentShop': null});
            }
          });
        }
      } else if (newShop.shopType == ShopType.CHILD) {
        if (newShop.parentShop != null && newShop.parentShop!.isNotEmpty) {
          batch.update(
              FirebaseFirestore.instance
                  .collection('shops')
                  .doc(newShop.parentShop),
              {
                'childShops': FieldValue.arrayUnion([newShop.docID!])
              });
        }

        if (oldShop.parentShop != null && oldShop.parentShop!.isNotEmpty) {
          if (newShop.parentShop != oldShop.parentShop) {
            batch.update(
                FirebaseFirestore.instance
                    .collection('shops')
                    .doc(oldShop.parentShop),
                {
                  'childShops': FieldValue.arrayRemove([newShop.docID!])
                });
          }
        }
      }

      batch.update(
          FirebaseFirestore.instance.collection('shops').doc(newShop.docID),
          newShop.toMap());

      await batch.commit();
      await RouteDatabase().updateShopOrderForRoute(newShop);

      return true;
    } catch (err) {
      print(err);
      return false;
    }
  }

  Future<bool> deleteShop({required Shop shop}) async {
    try {
      WriteBatch batch = FirebaseFirestore.instance.batch();

      if (shop.shopType == ShopType.PARENT) {
        //add child to all parent

        if (shop.childShops != null) {
          shop.childShops!.forEach((shopID) {
            //removed, go to its parent & mark it as null
            batch.update(
                FirebaseFirestore.instance.collection('shops').doc(shopID),
                {'parentShop': null});
          });
        }
      } else if (shop.shopType == ShopType.CHILD) {
        if (shop.parentShop != null && shop.parentShop!.isNotEmpty) {
          batch.update(
              FirebaseFirestore.instance
                  .collection('shops')
                  .doc(shop.parentShop),
              {
                'childShops': FieldValue.arrayRemove([shop.docID!])
              });
        }
      }

      batch.delete(
          FirebaseFirestore.instance.collection('shops').doc(shop.docID));

      await batch.commit();
      await RouteDatabase().deleteShopOrderForRoute(shop);
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<List<Shop>> getAllShops() async {
    List<Shop> list = [];
    try {
      var snap = await FirebaseFirestore.instance
          .collection('shops')
          // .orderBy('addedTime', descending: true)
          .orderBy('shopName', descending: false)
          .get();
      snap.docs.forEach((doc) {
        list.add(Shop.fromFirestore(doc));
      });
      return list;
    } catch (err) {
      print(err);
      return list;
    }
  }

  //get shops that are not listed as child/parent
  Future<List<Shop>> getShopByType(ShopType type) async {
    List<Shop> list = [];
    try {
      var snap = await FirebaseFirestore.instance
          .collection('shops')
          .where('shopType', isEqualTo: type.index)
          .orderBy('addedTime', descending: true)
          .get();
      snap.docs.forEach((doc) {
        list.add(Shop.fromFirestore(doc));
      });
      return list;
    } catch (err) {
      print(err);
      return list;
    }
  }

  Future<List<Shop>> getAllShopsForRoute(String routeID) async {
    List<Shop> list = [];
    try {
      var snap = await FirebaseFirestore.instance
          .collection('shops')
          .where('routeIDs', arrayContains: routeID)
          .get();
      snap.docs.forEach((doc) {
        list.add(Shop.fromFirestore(doc));
      });
      return list;
    } catch (err) {
      print(err);
      return list;
    }
  }

  Future<List<Shop?>> getShopsForLine(Line line) async {
    List<Shop> list = [];
    try {
      List<Future<Shop?>> futures = [];
      line.shopIDs.forEach((element) {
        futures.add(getShopByID(element));
      });
      var res = await Future.wait(futures);
      return res;
    } catch (err) {
      print(err);
      return list;
    }
  }

  Future<Shop?> getShopByID(String docID) async {
    try {
      var doc =
          await FirebaseFirestore.instance.collection('shops').doc(docID).get();
      if (doc.exists) {
        return Shop.fromFirestore(doc);
      }
      return null;
    } catch (err) {
      print(err);
      return null;
    }
  }

  Future<Shop?> getShopByPhone(String phone) async {
    try {
      var snap = await FirebaseFirestore.instance
          .collection('shops')
          .where('phoneNumber', isEqualTo: phone)
          .get();
      if (snap.docs.isNotEmpty) {
        return Shop.fromFirestore(snap.docs.first);
      }
      return null;
    } catch (err) {
      print(err);
      return null;
    }
  }

  Stream<QuerySnapshot> listenPayments(Shop shop) {
    return FirebaseFirestore.instance
        .collection('shops')
        .doc(shop.docID)
        .collection('payments')
        .orderBy('paymentTime', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot> listenShops() {
    return FirebaseFirestore.instance
        .collection('shops')
        .orderBy('addedTime', descending: true)
        .snapshots();
  }

  Future<bool> updateShopNotes({
    required Shop shop,
  }) async {
    try {
      await FirebaseFirestore.instance
          .collection('shops')
          .doc(shop.docID)
          .update({'notes': shop.notes, 'notesUpdatedTime': DateTime.now()});
      await RouteDatabase().updateShopOrderForRoute(shop);
      return true;
    } catch (err) {
      print(err);
      return false;
    }
  }

  Future<bool> addDiscount({
    required String shopID,
    required Discount discount,
  }) async {
    try {
      var shopDoc = await FirebaseFirestore.instance
          .collection('shops')
          .doc(shopID)
          .get();
      if (!shopDoc.exists) {
        return false;
      }
      var shop = Shop.fromFirestore(shopDoc);

      WriteBatch batch = FirebaseFirestore.instance.batch();
      double closingBalance = shop.closingBalance - discount.discount;
      discount.closingBalance = closingBalance.round();

      batch.set(
          FirebaseFirestore.instance
              .collection('shops')
              .doc(shop.docID)
              .collection('discounts')
              .doc(),
          discount.toMap());

      batch.update(
          FirebaseFirestore.instance.collection('shops').doc(shop.docID),
          {'closingBalance': closingBalance.round()});

      await batch.commit();
      return true;
    } catch (err) {
      print(err);
      return false;
    }
  }

  Future<bool> addAdditionalAmount({
    required String shopID,
    required AdditionalAmount amount,
  }) async {
    // try {÷
    var shopDoc =
        await FirebaseFirestore.instance.collection('shops').doc(shopID).get();
    if (!shopDoc.exists) {
      return false;
    }

    var shop = Shop.fromFirestore(shopDoc);

    WriteBatch batch = FirebaseFirestore.instance.batch();
    double closingBalance = shop.closingBalance + amount.amount;
    amount.closingBalance = closingBalance.round();

    batch.set(
        FirebaseFirestore.instance
            .collection('shops')
            .doc(shop.docID)
            .collection('additionalBills')
            .doc(),
        amount.toMap());

    batch.update(FirebaseFirestore.instance.collection('shops').doc(shop.docID),
        {'closingBalance': closingBalance.round()});

    await batch.commit();
    return true;
    // } catch (err) {
    //   print(err);
    //   return false;
    // }
  }
}
