import 'package:cloud_firestore/cloud_firestore.dart';

class CardDataNAdminOrderHistory {
  final String userId;
  final String userName;
  final String productId;
  final quantity;
  final String currency;
  final amount;
  final String deliveryTime;
  final String address;
  final String productName;
  final timestamp;
  final String mediaUrl;
  final String status;
  final String email;
  final String areaCode;
  final String phoneNo;
  final String city;
  final String country;
  final String enteredName;
  final String userOrderHistoryId;
  final String adminOrderHistoryId;
  final bool paymentReceived;
  final String paymentType;
  final String trackingToken;
  final String deliveryService;

  CardDataNAdminOrderHistory({
    this.userId,
    this.userName,
    this.productId,
    this.quantity,
    this.currency,
    this.amount,
    this.address,
    this.productName,
    this.timestamp,
    this.mediaUrl,
    this.deliveryTime,
    this.status,
    this.email,
    this.phoneNo,
    this.areaCode,
    this.city,
    this.country,
    this.enteredName,
    this.userOrderHistoryId,
    this.adminOrderHistoryId,
    this.paymentReceived,
    this.paymentType,
    this.trackingToken,
    this.deliveryService,
  });

  factory CardDataNAdminOrderHistory.fromDocument(DocumentSnapshot doc) {
    return CardDataNAdminOrderHistory(
      userId: doc.data()["userId"],
      productId: doc.data()["productId"],
      quantity: doc.data()["quantity"],
      currency: doc.data()["currency"],
      amount: doc.data()["amount"],
      address: doc.data()["address"],
      productName: doc.data()["productName"],
      timestamp: doc.data()["timestamp"],
      mediaUrl: doc.data()["mediaUrl"],
      userName: doc.data()['userName'],
      deliveryTime: doc.data()["deliveryTime"],
      status: doc.data()['status'],
      phoneNo: doc.data()['phoneNo'],
      areaCode: doc.data()['areaCode'],
      city: doc.data()['city'],
      country: doc.data()['country'],
      enteredName: doc.data()['enteredName'],
      email: doc.data()['email'],
      userOrderHistoryId: doc.data()['userOrderHistoryId'],
      adminOrderHistoryId: doc.data()['adminOrderHistoryId'],
      paymentReceived: doc.data()['paymentReceived'],
      paymentType: doc.data()['paymentType'],
      trackingToken: doc.data()['trackingToken'],
      deliveryService: doc.data()['deliveryService'],
    );
  }
}
