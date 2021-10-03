import 'package:cloud_firestore/cloud_firestore.dart';

class Address {
  final String userId;
  final String userName;
  final String address;
  final timestamp;
  final String email;
  final String areaCode;
  final String phone;
  final String city;
  final String country;
  final String name;
  Address({
    this.userId,
    this.userName,
    this.address,
    this.timestamp,
    this.email,
    this.phone,
    this.areaCode,
    this.city,
    this.country,
    this.name,
  });

  factory Address.fromDocument(DocumentSnapshot doc) {
    return Address(
      userId: doc.data()["userId"],
      address: doc.data()["address"],
      timestamp: doc.data()["timestamp"],
      userName: doc.data()['userName'],
      phone: doc.data()['phone'],
      areaCode: doc.data()['areaCode'],
      city: doc.data()['city'],
      country: doc.data()['country'],
      name: doc.data()['name'],
      email: doc.data()['email'],
    );
  }
}
