import 'package:cloud_firestore/cloud_firestore.dart';

class CardData {
  final String userId;
  final String productId;
  final int quantity;
  final String currency;
  final amount;
  final String address;
  final String productName;
  final timestamp;
  final String mediaUrl;
  CardData({
    this.userId,
    this.productId,
    this.quantity,
    this.currency,
    this.amount,
    this.address,
    this.productName,
    this.timestamp,
    this.mediaUrl,
  });

  factory CardData.fromDocument(DocumentSnapshot doc) {
    return CardData(
      userId: doc["userId"],
      productId: doc["productId"],
      quantity: doc["quantity"],
      currency: doc["currency"],
      amount: doc["amount"],
      address: doc["address"],
      productName: doc["productName"],
      timestamp: doc["timestamp"],
      mediaUrl: doc["mediaUrl"],
    );
  }
}
