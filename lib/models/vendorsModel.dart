import 'package:cloud_firestore/cloud_firestore.dart';

class VendorsModel {
  final String vendorsId;
  final String vendorMediaUrl;

  VendorsModel({
    this.vendorsId,
    this.vendorMediaUrl,
  });

  factory VendorsModel.fromDocument(DocumentSnapshot doc) {
    return VendorsModel(
      vendorsId: doc.data()['vendorsId'],
      vendorMediaUrl: doc.data()['vendorMediaUrl'],
    );
  }
}
