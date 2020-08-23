import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:kannapy/userScreens/cart.dart';

class FavCart {
  final String userId;
  final String productId;
  final String mediaUrl;
  final String productName;
  final productPrice;
  final quantity;

  FavCart(
      {this.productName,
      this.mediaUrl,
      this.productId,
      this.userId,
      this.productPrice,
      this.quantity});
  factory FavCart.fromDocument(DocumentSnapshot doc) {
    return FavCart(
      productName: doc['productName'],
      productId: doc['productId'],
      userId: doc['userId'],
      mediaUrl: doc['mediaUrl'],
      productPrice: doc['productPrice'],
      quantity: doc['quantityLeft'],
    );
  }
}
