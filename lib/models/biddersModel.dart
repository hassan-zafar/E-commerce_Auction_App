import 'package:cloud_firestore/cloud_firestore.dart';

class Bidders {
  final String bidderId;
  final String productId;
  final String biddersName;
  final String biddersDisplayName;
  final String bidPrice;
  final timestamp;
  final String photoUrl;
  final bool hasWon;
  final String androidNotificationToken;
  final String email;

  Bidders({
    this.bidderId,
    this.productId,
    this.biddersName,
    this.biddersDisplayName,
    this.bidPrice,
    this.timestamp,
    this.photoUrl,
    this.hasWon,
    this.androidNotificationToken,
    this.email,
  });

  factory Bidders.fromDocument(DocumentSnapshot doc) {
    return Bidders(
      bidderId: doc.data()['bidderId'],
      productId: doc.data()['productId'],
      biddersName: doc.data()['biddersName'],
      biddersDisplayName: doc.data()['biddersDisplayName'],
      photoUrl: doc.data()['photoUrl'],
      bidPrice: doc.data()['bidPrice'],
      timestamp: doc.data()['timestamp'],
      hasWon: doc.data()['hasWon'],
      androidNotificationToken: doc.data()["androidNotificationToken"],
      email: doc.data()["email"],
    );
  }
}
