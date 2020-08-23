import 'dart:async';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:kannapy/tools/productItems.dart';
import 'package:kannapy/tools/progress.dart';
import 'package:kannapy/userScreens/buyingPage.dart';
import 'package:kannapy/userScreens/cart.dart';
import 'package:kannapy/userScreens/favourites.dart';
import 'package:kannapy/userScreens/home.dart';
import 'package:kannapy/userScreens/kannapyStore.dart';

class ProductScreen extends StatelessWidget {
  // final List<dynamic> productMediaUrl;
  final String productId;
  // final ProductItems productItems;

  ProductScreen({
    //this.productMediaUrl,
    this.productId,
    //  this.productItems
  });
  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return FutureBuilder(
        future: storeTimelineRef.document(productId).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return bouncingGridProgress();
          }
          ProductItems productItems = ProductItems.fromDocument(snapshot.data);
          return Center(
            child: Scaffold(
              appBar: AppBar(
                title: Text(productItems.productName),
              ),
              body: ListView(
                children: <Widget>[
                  Container(
                    child: productItems,
                  ),
                ],
              ),
              floatingActionButton: Stack(
                alignment: Alignment.topLeft,
                children: <Widget>[
                  FloatingActionButton(
                    onPressed: () {
                      cartRef
                          .document(currentUser.id)
                          .collection("cartItems")
                          .document(productItems.productId)
                          .setData({
                        "mediaUrl": productItems.mediaUrl[0],
                        "productId": productItems.productId,
                        "userId": currentUser.id,
                        "productName": productItems.productName,
                        "productPrice": productItems.price,
                        "quantitySelected": "1",
                      });
                      BotToast.showText(
                        text: "Added To Your Cart",
                      );
                    },
                    child: Icon(Icons.shopping_cart),
                  ),
                  CircleAvatar(
                    radius: 10.0,
                    backgroundColor: Colors.red,
                    child: Text(
                      "$cartCount",
                      style: TextStyle(color: Colors.white, fontSize: 12.0),
                    ),
                  ),
                ],
              ),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerDocked,
              bottomNavigationBar: BottomAppBar(
                color: Theme.of(context).primaryColor,
                shape: CircularNotchedRectangle(),
                notchMargin: 5.0,
                elevation: 0.0,
                child: Container(
                  height: 50.0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      GestureDetector(
                        onTap: () {
                          favouritesRef
                              .document(currentUser.id)
                              .collection("favouriteProducts")
                              .document(productItems.productId)
                              .setData({
                            "mediaUrl": productItems.mediaUrl[0],
                            "productId": productItems.productId,
                            "userId": currentUser.id,
                            "productName": productItems.productName,
                            "productPrice": productItems.price,
                            "quantitySelected": productItems.quantity,
                          });
                          BotToast.showText(
                            text: 'Added To Favourites',
                          );
                        },
                        child: Container(
                          width: (screenSize.width - 20) / 2,
                          child: Text(
                            "ADD TO FAVORITES",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => BuyingPage(
                                    userId: currentUser.id,
                                    quantitySelected: quantitySelected,
                                    productItems: productItems,
                                  )));
                        },
                        child: Container(
                          width: (screenSize.width - 20) / 2,
                          child: Text(
                            "ORDER NOW",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }
}
