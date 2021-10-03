import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String id;
  final String userName;
  final String email;
  final String photoUrl;
  final String displayName;
  final String bio;
  final String type;
  final List address;
  final bool hasMadePurchase;
  final String androidNotificationToken;
  AppUser({
    this.id,
    this.userName,
    this.email,
    this.photoUrl,
    this.displayName,
    this.bio,
    this.type,
    this.address,
    this.hasMadePurchase,
    this.androidNotificationToken,
  });

  factory AppUser.fromDocument(DocumentSnapshot doc) {
    return AppUser(
      id: doc.data()['id'],
      email: doc.data()['email'],
      userName: doc.data()['userName'],
      photoUrl: doc.data()['photoUrl'],
      displayName: doc.data()['displayName'],
      bio: doc.data()['bio'],
      type: doc.data()['type'],
      address: doc.data()['address'],
      hasMadePurchase: doc.data()['hasMadePurchase'],
      androidNotificationToken: doc.data()["androidNotificationToken"],
    );
  }
}
