import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:selvam_broilers/utils/flags.dart';

class Shop {
  String shopName;
  String ownerName;
  String phoneNumber;
  String address;
  String regionName;
  DateTime addedTime;
  double regularDiscountPerKG;
  double smallDiscountPerKG;
  double shopRegularDiscountPerKG;
  double shopSmallDiscountPerKG;
  double? janadhaRate;
  double? maxAllowedCredit;
  List<dynamic> routeIDs;
  GeoPoint? location;
  ShopType shopType;
  String? parentShop;
  List<dynamic>? childShops;
  Reference? ownerPhoto;
  Reference? shopPhoto;
  DateTime? notesUpdatedTime;
  String? notes;

  num? boxesInShop;
  double closingBalance;
  String? docID;

  int slNo = 0;
  Shop({
    required this.shopName,
    required this.ownerName,
    required this.phoneNumber,
    required this.address,
    required this.addedTime,
    required this.smallDiscountPerKG,
    required this.regularDiscountPerKG,
    required this.shopRegularDiscountPerKG,
    required this.shopSmallDiscountPerKG,
    required this.closingBalance,
    required this.routeIDs,
    required this.regionName,
    this.ownerPhoto,
    this.shopPhoto,
    this.location,
    this.boxesInShop,
    this.notes,
    this.notesUpdatedTime,
    required this.shopType,
    this.parentShop,
    this.childShops,
    this.janadhaRate,
    this.maxAllowedCredit,
    this.docID,
  });

  Shop clone() {
    return Shop(
      shopName: this.shopName,
      ownerName: this.ownerName,
      phoneNumber: this.phoneNumber,
      address: this.address,
      addedTime: this.addedTime,
      smallDiscountPerKG: this.smallDiscountPerKG,
      regularDiscountPerKG: this.regularDiscountPerKG,
      shopRegularDiscountPerKG: this.shopRegularDiscountPerKG,
      shopSmallDiscountPerKG: this.shopSmallDiscountPerKG,
      closingBalance: this.closingBalance,
      routeIDs: this.routeIDs,
      regionName: this.regionName,
      ownerPhoto: this.ownerPhoto,
      shopPhoto: this.shopPhoto,
      location: this.location,
      boxesInShop: this.boxesInShop,
      notes: this.notes,
      notesUpdatedTime: this.notesUpdatedTime,
      shopType: this.shopType,
      parentShop: this.parentShop,
      childShops: this.childShops,
      maxAllowedCredit: this.maxAllowedCredit,
      docID: this.docID,
    );
  }

  factory Shop.fromFirestore(DocumentSnapshot doc) {
    Map? data = doc.data() as Map?;
    return Shop(
        shopName: data!['shopName'],
        ownerName: data['ownerName'],
        phoneNumber: data['phoneNumber'],
        address: data['address'],
        regionName: data['regionName'],
        shopType: ShopType.values[data['shopType'] ?? 0],
        parentShop: data['parentShop'],
        childShops: data['childShops'],
        janadhaRate: data['janadhaRate'],
        maxAllowedCredit: data['maxAllowedCredit'],
        addedTime: DateTime.parse(data['addedTime'].toDate().toString()),
        notesUpdatedTime: data['notesUpdatedTime'] == null
            ? null
            : DateTime.parse(data['notesUpdatedTime'].toDate().toString()),
        smallDiscountPerKG: data['smallDiscountPerKG'].toDouble(),
        regularDiscountPerKG: data['regularDiscountPerKG'].toDouble(),
        shopRegularDiscountPerKG:
            data['shopRegularDiscountPerKG']?.toDouble() ?? 0,
        shopSmallDiscountPerKG: data['shopSmallDiscountPerKG']?.toDouble() ?? 0,
        closingBalance: data['closingBalance'].toDouble(),
        routeIDs: data['routeIDs'],
        location: data['location'],
        notes: data['notes'],
        ownerPhoto: FirebaseStorage.instance.ref(data['ownerPhoto']),
        shopPhoto: FirebaseStorage.instance.ref(data['shopPhoto']),
        boxesInShop: data['boxesInShop'] ?? 0,
        docID: doc.id);
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> data = {
      'shopName': this.shopName,
      'ownerName': this.ownerName,
      'phoneNumber': this.phoneNumber,
      'address': this.address,
      'addedTime': this.addedTime,
      'smallDiscountPerKG': this.smallDiscountPerKG,
      'regularDiscountPerKG': this.regularDiscountPerKG,
      'shopRegularDiscountPerKG': this.shopRegularDiscountPerKG,
      'shopSmallDiscountPerKG': this.shopSmallDiscountPerKG,
      'closingBalance': this.closingBalance,
      'routeIDs': this.routeIDs,
      'location': this.location,
      'regionName': this.regionName,
      'notes': this.notes,
      'notesUpdatedTime': this.notesUpdatedTime,
      'shopPhoto': this.shopPhoto == null ? '' : this.shopPhoto!.fullPath,
      'ownerPhoto': this.ownerPhoto == null ? '' : this.ownerPhoto!.fullPath,
      'boxesInShop': this.boxesInShop ?? 0,
      'shopType': this.shopType.index,
      'parentShop': this.parentShop,
      'childShops': this.childShops,
      'janadhaRate': this.janadhaRate,
      'maxAllowedCredit': this.maxAllowedCredit,
    };
    return data;
  }
}
