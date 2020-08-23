import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String userName;
  final String email;
  final String photoUrl;
  final String displayName;
  final String bio;
  final String type;
  final List address;

  User({
    this.id,
    this.userName,
    this.email,
    this.photoUrl,
    this.displayName,
    this.bio,
    this.type,
    this.address,
  });

  factory User.fromDocument(DocumentSnapshot doc) {
    return User(
      id: doc['id'],
      email: doc['email'],
      userName: doc['userName'],
      photoUrl: doc['photoUrl'],
      displayName: doc['displayName'],
      bio: doc['bio'],
      type: doc['type'],
      address: doc['address'],
    );
  }
}
