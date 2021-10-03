import 'package:cloud_firestore/cloud_firestore.dart';

class FavCart {
  final String userId;
  final String productId;
  final String mediaUrl;
  final String productName;
  final String productSubHeading;
  final String productPrice;
  final String quantity;
  final String ownerId;
  final String type;
  final String deliveryTime;
  final String bonusQuantity;
  final String bonus;
  int quantitySelected = 1;
  FavCart(
      {this.productName,
      this.mediaUrl,
      this.productId,
      this.userId,
      this.productPrice,
      this.quantity,
      this.ownerId,
      this.deliveryTime,
      this.productSubHeading,
      this.quantitySelected,
      this.bonusQuantity,
      this.bonus,
      this.type});
  factory FavCart.fromDocument(DocumentSnapshot doc) {
    return FavCart(
        productName: doc.data()['productName'],
        productId: doc.data()['productId'],
        userId: doc.data()['userId'],
        mediaUrl: doc.data()['mediaUrl'],
        productPrice: doc.data()['productPrice'],
        quantity: doc.data()['quantityLeft'],
        ownerId: doc.data()["ownerId"],
        deliveryTime: doc.data()["deliveryTime"],
        quantitySelected: doc.data()["quantitySelected"],
        productSubHeading: doc.data()["productSubHeading"],
        type: doc.data()['type'],
        bonusQuantity: doc.data()['bonusQuantity'],
        bonus: doc.data()['bonus']);
  }
}
