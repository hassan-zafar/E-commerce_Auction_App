import 'package:auto_size_text/auto_size_text.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:kannapy/adminScreens/adminHome.dart';
import 'package:kannapy/models/addressModel.dart';
import 'package:kannapy/models/fav_cart.dart';
import 'package:kannapy/tools/productItems.dart';
import 'package:kannapy/tools/progress.dart';
import 'package:kannapy/userScreens/checkOut.dart';
import 'package:kannapy/userScreens/home.dart';
import 'package:kannapy/userScreens/productScreens/kannapyStore.dart';
import 'package:kannapy/userScreens/productScreens/productScreen.dart';
import 'package:kannapy/tools/CommonFunctions.dart';
import 'profileScreens/dashBoard.dart';

double totalPriceInCart = 0;
List<String> totalProductIds = [];
List<double> totalPricePerItem = [];
double totalBuyingPrice = 0;

class KannapyCart extends StatefulWidget {
  final String userId;
  KannapyCart({this.userId});
  @override
  _KannapyCartState createState() => _KannapyCartState();
}

class _KannapyCartState extends State<KannapyCart> {
  List<FavCart> cartList = [];
  List<Address> allAddresses = [];
  List<ProductItems> productItems = [];
  double finalPayment = 0;

  bool buildCheckout = false;
  bool _isLoading = false;

  String walletId;
  @override
  void initState() {
    super.initState();

    getCartItems();
  }

  getCartItems() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }
    QuerySnapshot cartSnapshot =
        await cartRef.doc(currentUser.id).collection("cartItems").get();
    List<FavCart> cartList =
        cartSnapshot.docs.map((doc) => FavCart.fromDocument(doc)).toList();
    if (mounted) {
      setState(() {
        this.cartList = cartList;
        _isLoading = false;
      });
    }
    cartList.forEach((e) async {
      seedVaultTimelineRef.doc(e.productId).get().then((value) {
        if (value.exists) {
          productItems.add(ProductItems.fromDocument(value));
        }
      });
      storeTimelineRef.doc(e.productId).get().then((value) {
        if (value.exists) {
          productItems.add(ProductItems.fromDocument(value));
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    //super.build(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: GestureDetector(
          onLongPress: isAdmin || isMerc
              ? () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) =>
                          AdminHome(currentUser: currentUser, isMerc: isMerc)));
                }
              : () {},
          child: Text(
            'MY CART',
            style: TextStyle(
                color: Theme.of(context).appBarTheme.textTheme.headline1.color),
          ),
        ),
        actions: [
          IconButton(
              icon: Icon(
                Icons.person_outline,
                color: Theme.of(context).appBarTheme.textTheme.headline1.color,
              ),
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => Profile(
                        profileId: currentUser?.id,
                      )))),
        ],
      ),
      body: buildCart(),
      // buildCart(),
      bottomSheet: buildCheckout
          ? Text('')
          : GestureDetector(
              onTap: () async {
                return Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CheckOut(
                      cartItems: cartList,
                    ),
                  ),
                );
                // cartList.forEach((element) async {
                //   double singleCartItemPrice =
                //       double.parse(element.productPrice) *
                //           element.quantitySelected;
                //   totalPriceInCart += singleCartItemPrice;
                // });
                // finalPayment = totalPriceInCart;
                // selectLocation(context);
              },
              child: Neumorphic(
                style: NeumorphicStyle(
                    shape: NeumorphicShape.concave,
                    boxShape: NeumorphicBoxShape.roundRect(BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20))),
                    depth: 7,
                    surfaceIntensity: 0.65,
                    lightSource: LightSource.bottom,
                    color: Colors.white),
                child: Container(
                  height: 80.0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.shopping_cart,
                          size: 35,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'CHECKOUT',
                          style: TextStyle(
                            fontSize: 35.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  buildStreamCart() {
    return StreamBuilder(
      stream: cartRef.doc(widget.userId).collection("cartItems").snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return bouncingGridProgress();
        }

        // cartList.add(cartItem);
        List<FavCart> cartList = [];
        snapshot.data.documents.forEach((doc) async {
          cartList.add(FavCart.fromDocument(doc));
          // setState(() {
          //   this.cartList = cartList;
          // });
        });
        if (cartList.isEmpty && snapshot.hasData) {
          buildCheckout = false;
          return Center(
            child: Text(
              "Your Cart is Currently Empty",
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
          );
        } else {
          buildCheckout = true;
        }
        return ListView(
          physics: BouncingScrollPhysics(),
          shrinkWrap: true,
          children: [
            ListView.separated(
                physics: BouncingScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (BuildContext context, index) {
                  return Dismissible(
                    child: GestureDetector(
                      onTap: () {
                        return showProduct(context, cartList[index]);
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 40.0, right: 20, top: 20, bottom: 20),
                        child: Stack(
                          overflow: Overflow.visible,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: bxShadow,
                                  color: Colors.white),
                              height: 100,
                              width: MediaQuery.of(context).size.width,
                              padding: EdgeInsets.only(
                                  left: 80, top: 8, bottom: 0, right: 18),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AutoSizeText(
                                    cartList[index].productName,
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                    maxLines: 1,
                                    minFontSize: 12,
                                    overflow: TextOverflow.ellipsis,
                                    maxFontSize: 18,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: AutoSizeText(
                                      cartList[index].productSubHeading,
                                      maxLines: 1,
                                      minFontSize: 6,
                                      maxFontSize: 12,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 4,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      AutoSizeText(
                                        "£${cartList[index].productPrice}",
                                        style: TextStyle(
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20),
                                        maxLines: 1,
                                        minFontSize: 18,
                                        maxFontSize: 20,
                                      ),
                                      Container(
                                        width: 90,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: <Widget>[
                                            GestureDetector(
                                              child: CircleAvatar(
                                                backgroundColor:
                                                    Theme.of(context)
                                                        .iconTheme
                                                        .color,
                                                radius: 12,
                                                child: Icon(
                                                  Icons.remove,
                                                  size: 10,
                                                ),
                                              ),
                                              onTap: () {
                                                setState(() {
                                                  if (cartList[index]
                                                          .quantitySelected >
                                                      1) {
                                                    cartList[index]
                                                            .quantitySelected =
                                                        cartList[index]
                                                                .quantitySelected -
                                                            1;
                                                  } else {
                                                    BotToast.showText(
                                                        text:
                                                            "Minimum Quantity reached");
                                                  }
                                                });
                                              },
                                            ),
                                            Text(
                                              "${cartList[index].quantitySelected}",
                                              style: TextStyle(fontSize: 15),
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  if (cartList[index]
                                                          .quantitySelected <
                                                      int.parse(cartList[index]
                                                          .quantity)) {
                                                    cartList[index]
                                                            .quantitySelected =
                                                        cartList[index]
                                                                .quantitySelected +
                                                            1;
                                                    print(
                                                        "${cartList[index].quantitySelected}");
                                                    cartRef
                                                        .doc(currentUser.id)
                                                        .collection("cartItems")
                                                        .doc(cartList[index]
                                                            .productId)
                                                        .update({
                                                      "quantitySelected": cartList[
                                                                  index]
                                                              .quantitySelected +
                                                          1
                                                    });
                                                  } else {
                                                    BotToast.showText(
                                                        text:
                                                            "Maximum Quantity reached");
                                                  }
                                                });
                                              },
                                              child: CircleAvatar(
                                                backgroundColor:
                                                    Theme.of(context)
                                                        .iconTheme
                                                        .color,
                                                radius: 12,
                                                child: Icon(
                                                  Icons.add,
                                                  size: 10,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                            Positioned(
                              right: 6,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: GestureDetector(
                                  onTap: () => deleteFromCart(index),
                                  child: Icon(
                                    Icons.delete_outline,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              top: -20,
                              left: -20,
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: Colors.white,
                                    image: DecorationImage(
                                        image: CachedNetworkImageProvider(
                                          cartList[index].mediaUrl,
                                        ),
                                        fit: BoxFit.fill),
                                    boxShadow: bxShadow),
                                height: 90,
                                width: 90,
                              ),
                            ),
                          ],
                        ),
                      ),
                   
                    ),
                    key: UniqueKey(),
                    onDismissed: (direction) {
                      BotToast.showText(text: "Deleted From Cart");
                      cartRef
                          .doc(currentUser.id)
                          .collection("cartItems")
                          .doc(cartList[index].productId)
                          .delete();
                      seedVaultTimelineRef
                          .doc(cartList[index].productId)
                          .get()
                          .then((value) {
                        if (value.exists) {
                          value.reference
                              .update({"carts.${currentUser.id}": false});
                        }
                      });
                      storeTimelineRef
                          .doc(cartList[index].productId)
                          .get()
                          .then((value) {
                        if (value.exists) {
                          value.reference
                              .update({"carts.${currentUser.id}": false});
                        }
                      });
                      setState(() {
                        cartList.removeAt(index);
                        cartCount = cartCount - 1;
                      });
                    },
                    background: Neumorphic(
                      style: NeumorphicStyle(
                        color: Colors.white,
                      ),
                      child: Container(
                        alignment: Alignment.centerRight,
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('DELETE'),
                        ),
                      ),
                    ),
                    direction: DismissDirection.horizontal,
                  );
                },
                separatorBuilder: (BuildContext context, index) {
                  return SizedBox(
                    height: 1,
                  );
                },
                itemCount: cartList.length),
            SizedBox(
              height: 90,
            ),
          ],
        );
      },
    );
  }

  addQuantity({@required String quantity, @required int quantitySelected}) {
    print("minus Pressed");
    if (mounted) {
      if (quantitySelected < int.parse(quantity)) {
        setState(() {
          quantitySelected = quantitySelected + 1;
        });
      } else {
        BotToast.showText(text: "Maximum Quantity reached");
      }
    }
  }

  minusQuantity({@required String quantity, @required int quantitySelected}) {
    print("min clicked");
    if (mounted) {
      if (quantitySelected > 1) {
        setState(() {
          quantitySelected = quantitySelected - 1;
        });
      } else {
        BotToast.showText(text: "Minimum Quantity reached");
      }
    }
  }

  buildCart() {
    if (_isLoading) {
      return bouncingGridProgress();
    }
    if (cartList.isEmpty && !_isLoading) {
      return Center(
        child: Text(
          "Your Cart is Currently Empty",
          style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
        ),
      );
    }
    return ListView(
      physics: BouncingScrollPhysics(),
      shrinkWrap: true,
      children: [
        SizedBox(
          height: 20,
        ),
        ListView.separated(
            physics: BouncingScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (BuildContext context, index) {
              return Dismissible(
                child: GestureDetector(
                  onTap: () {
                    return showProduct(context, cartList[index]);
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 40.0, right: 20, top: 20, bottom: 20),
                    child: Stack(
                      overflow: Overflow.visible,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: bxShadow,
                              color: Colors.white),
                          height: 100,
                          width: MediaQuery.of(context).size.width,
                          padding: EdgeInsets.only(
                              left: 80, top: 8, bottom: 0, right: 18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AutoSizeText(
                                cartList[index].productName,
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                                maxLines: 1,
                                minFontSize: 12,
                                overflow: TextOverflow.ellipsis,
                                maxFontSize: 18,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: AutoSizeText(
                                  cartList[index].productSubHeading,
                                  maxLines: 1,
                                  minFontSize: 6,
                                  maxFontSize: 12,
                                ),
                              ),
                              SizedBox(
                                height: 4,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  AutoSizeText(
                                    "£${cartList[index].productPrice}",
                                    style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20),
                                    maxLines: 1,
                                    minFontSize: 18,
                                    maxFontSize: 20,
                                  ),
                                  Container(
                                    width: 90,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: <Widget>[
                                        GestureDetector(
                                          child: CircleAvatar(
                                            backgroundColor: Theme.of(context)
                                                .iconTheme
                                                .color,
                                            radius: 12,
                                            child: Icon(
                                              Icons.remove,
                                              size: 10,
                                            ),
                                          ),
                                          onTap: () {
                                            setState(() {
                                              if (cartList[index]
                                                      .quantitySelected >
                                                  1) {
                                                cartList[index]
                                                        .quantitySelected =
                                                    cartList[index]
                                                            .quantitySelected -
                                                        1;
                                                cartRef
                                                    .doc(currentUser.id)
                                                    .collection("cartItems")
                                                    .doc(cartList[index]
                                                        .productId)
                                                    .update({
                                                  "quantitySelected":
                                                      cartList[index]
                                                          .quantitySelected
                                                });
                                              } else {
                                                BotToast.showText(
                                                    text:
                                                        "Minimum Quantity reached");
                                              }
                                            });
                                          },
                                        ),
                                        Text(
                                          "${cartList[index].quantitySelected}",
                                          style: TextStyle(fontSize: 15),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              if (cartList[index]
                                                      .quantitySelected <
                                                  int.parse(cartList[index]
                                                      .quantity)) {
                                                cartList[index]
                                                        .quantitySelected =
                                                    cartList[index]
                                                            .quantitySelected +
                                                        1;
                                                print(
                                                    "${cartList[index].quantitySelected}");
                                                cartRef
                                                    .doc(currentUser.id)
                                                    .collection("cartItems")
                                                    .doc(cartList[index]
                                                        .productId)
                                                    .update({
                                                  "quantitySelected": cartList[
                                                              index]
                                                          .quantitySelected +
                                                      1
                                                });
                                                cartRef
                                                    .doc(currentUser.id)
                                                    .collection("cartItems")
                                                    .doc(cartList[index]
                                                        .productId)
                                                    .update({
                                                  "quantitySelected":
                                                      cartList[index]
                                                          .quantitySelected
                                                });
                                              } else {
                                                BotToast.showText(
                                                    text:
                                                        "Maximum Quantity reached");
                                              }
                                            });
                                          },
                                          child: CircleAvatar(
                                            backgroundColor: Theme.of(context)
                                                .iconTheme
                                                .color,
                                            radius: 12,
                                            child: Icon(
                                              Icons.add,
                                              size: 10,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                        Positioned(
                          right: 6,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(
                              Icons.delete_outline,
                              size: 20,
                            ),
                          ),
                        ),
                        Positioned(
                          top: -20,
                          left: -20,
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.white,
                                image: DecorationImage(
                                    image: CachedNetworkImageProvider(
                                      cartList[index].mediaUrl,
                                    ),
                                    fit: BoxFit.fill),
                                boxShadow: bxShadow),
                            height: 90,
                            width: 90,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Padding(
                  //   padding: const EdgeInsets.all(8),
                  //   child: neumorphicTile(
                  //     padding: 2,
                  //     anyWidget: ListTile(
                  //       isThreeLine: true,
                  //       leading: Image(
                  //         image: CachedNetworkImageProvider(
                  //             cartList[index].mediaUrl),
                  //         fit: BoxFit.contain,
                  //       ),
                  //       title: Text(
                  //         cartList[index].productName,
                  //         style: TextStyle(
                  //             fontSize: 16.0, fontWeight: FontWeight.bold),
                  //       ),
                  //       trailing: Column(
                  //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //         children: [
                  //           Container(
                  //             width: 80,
                  //             child: Row(
                  //               mainAxisAlignment:
                  //                   MainAxisAlignment.spaceEvenly,
                  //               children: <Widget>[
                  //                 GestureDetector(
                  //                   child: CircleAvatar(
                  //                     backgroundColor:
                  //                         Theme.of(context).iconTheme.color,
                  //                     radius: 12,
                  //                     child: Icon(
                  //                       Icons.remove,
                  //                       size: 10,
                  //                     ),
                  //                   ),
                  //                   onTap: () {
                  //                     setState(() {
                  //                       if (cartList[index].quantitySelected >
                  //                           1) {
                  //                         cartList[index].quantitySelected =
                  //                             cartList[index].quantitySelected -
                  //                                 1;
                  //                       } else {
                  //                         BotToast.showText(
                  //                             text: "Minimum Quantity reached");
                  //                       }
                  //                     });
                  //                   },
                  //                 ),
                  //                 Text(
                  //                   "${cartList[index].quantitySelected}",
                  //                   style: TextStyle(fontSize: 15),
                  //                 ),
                  //                 GestureDetector(
                  //                   onTap: () {
                  //                     setState(() {
                  //                       if (cartList[index].quantitySelected <
                  //                           int.parse(
                  //                               cartList[index].quantity)) {
                  //                         cartList[index].quantitySelected =
                  //                             cartList[index].quantitySelected +
                  //                                 1;
                  //                       } else {
                  //                         BotToast.showText(
                  //                             text: "Maximum Quantity reached");
                  //                       }
                  //                     });
                  //                   },
                  //                   child: CircleAvatar(
                  //                     backgroundColor:
                  //                         Theme.of(context).iconTheme.color,
                  //                     radius: 12,
                  //                     child: Icon(
                  //                       Icons.add,
                  //                       size: 10,
                  //                     ),
                  //                   ),
                  //                 ),
                  //               ],
                  //             ),
                  //           ),
                  //           Text(
                  //             "Price: \$${double.parse(cartList[index].productPrice) * cartList[index].quantitySelected}",
                  //             softWrap: true,
                  //             overflow: TextOverflow.fade,
                  //             style: TextStyle(
                  //                 fontSize: 16.0,
                  //                 fontWeight: FontWeight.bold,
                  //                 color: Colors.deepOrange),
                  //           ),
                  //         ],
                  //       ),
                  //       subtitle: Text(
                  //         "${cartList[index].productSubHeading}",
                  //         style: TextStyle(fontWeight: FontWeight.bold),
                  //       ),
                  //     ),
                  //   ),
                  // ),
                ),
                key: UniqueKey(),
                onDismissed: (direction) {
                  deleteFromCart(index);
                },
                background: Neumorphic(
                  style: NeumorphicStyle(
                    color: Colors.white,
                    lightSource: LightSource.topLeft,
                    depth: -10, oppositeShadowLightSource: true,
                    surfaceIntensity: 1,
                    intensity: 1,
                    shape: NeumorphicShape.convex,
                    // boxShape:
                    //     NeumorphicBoxShape.roundRect(BorderRadius.circular(20)),
                  ),
                  child: Container(
                    alignment: Alignment.centerRight,
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('DELETE'),
                    ),
                  ),
                ),
                direction: DismissDirection.horizontal,
              );
            },
            separatorBuilder: (BuildContext context, index) {
              return SizedBox(
                height: 1,
              );
            },
            itemCount: cartList.length),
        SizedBox(
          height: 90,
        ),
      ],
    );
  }

  deleteFromCart(int index) {
    BotToast.showText(text: "Deleted From Cart");
    cartRef
        .doc(currentUser.id)
        .collection("cartItems")
        .doc(cartList[index].productId)
        .delete();
    seedVaultTimelineRef.doc(cartList[index].productId).get().then((value) {
      if (value.exists) {
        value.reference.update({"carts.${currentUser.id}": false});
      }
    });
    storeTimelineRef.doc(cartList[index].productId).get().then((value) {
      if (value.exists) {
        value.reference.update({"carts.${currentUser.id}": false});
      }
    });
    setState(() {
      cartList.removeAt(index);
      cartCount = cartCount - 1;
    });
  }

  // selectPaymentOption(BuildContext parentContext) {
  //   showDialog(
  //       context: parentContext,
  //       builder: (context) {
  //         return SimpleDialog(
  //           shape:
  //               RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
  //           titlePadding: EdgeInsets.all(8),
  //           contentPadding: EdgeInsets.all(8),
  //           elevation: 6,
  //           title: Center(
  //             child: Text("Select Payment Option"),
  //           ),
  //           children: <Widget>[
  //             Divider(),
  //             SimpleDialogOption(
  //               onPressed: () {
  //                 Navigator.pop(context);
  //                 startPaymentProcess();
  //               },
  //               child: neumorphicTile(
  //                 anyWidget: Row(
  //                   mainAxisAlignment: MainAxisAlignment.center,
  //                   children: [
  //                     Icon(Icons.credit_card),
  //                     Text(
  //                       'Card',
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             ),
  //             SimpleDialogOption(
  //               onPressed: () {
  //                 Navigator.pop(context);
  //                 enterCryptoWallet(context);
  //               },
  //               child: neumorphicTile(
  //                 padding: 8,
  //                 anyWidget: Row(
  //                   mainAxisAlignment: MainAxisAlignment.center,
  //                   children: [
  //                     FaIcon(FontAwesomeIcons.bitcoin),
  //                     Text('Crypto'),
  //                   ],
  //                 ),
  //               ),
  //             ),
  //             SimpleDialogOption(
  //               onPressed: () => Navigator.pop(context),
  //               child: neumorphicTile(
  //                 padding: 8,
  //                 anyWidget: Row(
  //                   mainAxisAlignment: MainAxisAlignment.center,
  //                   children: [
  //                     Icon(Icons.cancel),
  //                     Text('Cancel'),
  //                   ],
  //                 ),
  //               ),
  //             )
  //           ],
  //         );
  //       });
  // }
  //
  // updateProductBuyers(FavCart cart) async {
  //   auctionTimelineRef.doc(cart.productId).get().then((value) {
  //     if (value.exists) {
  //       value.reference.update({
  //         "allBuyers": FieldValue.arrayUnion([currentUser.id])
  //       });
  //     }
  //   });
  //   auctionVaultTimelineRef.doc(cart.productId).get().then((value) {
  //     if (value.exists) {
  //       value.reference.update({
  //         "allBuyers": FieldValue.arrayUnion([currentUser.id])
  //       });
  //     }
  //   });
  //   seedVaultTimelineRef.doc(cart.productId).get().then((value) {
  //     if (value.exists) {
  //       value.reference.update({
  //         "allBuyers": FieldValue.arrayUnion([currentUser.id])
  //       });
  //     }
  //   });
  //   storeTimelineRef.doc(cart.productId).get().then((value) {
  //     if (value.exists) {
  //       value.reference.update({
  //         "allBuyers": FieldValue.arrayUnion([currentUser.id])
  //       });
  //     }
  //   });
  // }
  //
  // updateProductQuantity(FavCart cart) async {
  //   int newQuantity = int.parse(cart.quantity) - cart.quantitySelected;
  //
  //   await storeTimelineRef.doc(cart.productId).get().then((value) {
  //     if (value.exists) {
  //       value.reference.update({"quantity": newQuantity.toString()});
  //     }
  //   });
  //   await seedVaultTimelineRef.doc(cart.productId).get().then((value) {
  //     if (value.exists) {
  //       value.reference.update({"quantity": newQuantity.toString()});
  //     }
  //   });
  // }

  // enterCryptoWallet(BuildContext parentContext) {
  //   final _textFormKey = GlobalKey<FormState>();
  //   return showDialog(
  //       context: parentContext,
  //       builder: (context) {
  //         return SimpleDialog(
  //           elevation: 6,
  //           title: Center(child: Text("Enter Your Crypto Wallet")),
  //           shape: RoundedRectangleBorder(
  //               borderRadius: BorderRadius.circular(15.0)),
  //           titlePadding: EdgeInsets.all(12.0),
  //           contentPadding: EdgeInsets.all(12.0),
  //           children: [
  //             Padding(
  //               padding: const EdgeInsets.all(8.0),
  //               child: Text(
  //                   "PLEASE PROCEED THROUGH CHECKOUT PROCESS TO CONFIRM ORDER AS USUAL.\nOUR SALES TEAM WILL EMAIL YOU A LINK TO MAKE PAYMENT FOR GOODS.UPON CONFIRMATION OF PAYMENT. WE WILL UPDATE THE STATUS OF THE ORDER TO REFLECT THIS AND DISPATCH ITEMS ACCORDINGLY.ALL PAYMENT MUST BE MADE ON RECEIPT OF CRYPTO INVOICE.ITEMS FOR WHICH PAYMENT IS NOT RECEIVED, WILL BE RE-ADVERTISED WITHIN 24 HOURS.\nWE RESERVE THE RIGHT TO CANCEL ANY ORDER IF WE DEEMED IN BREACH OF OUR TERMS AND CONDITIONS"),
  //             ),
  //             SizedBox(
  //               height: 10,
  //             ),
  //             Form(
  //               key: _textFormKey,
  //               child: TextFormField(
  //                 onSaved: (val) => _cryptoController.text = val,
  //                 validator: (val) =>
  //                     val.trim().length <= 4 ? "Enter Valid Wallet!" : null,
  //                 decoration: InputDecoration(
  //                   border: OutlineInputBorder(),
  //                   labelText: "Enter Contact E-mail address",
  //                   hintText: "Must be valid address for contact",
  //                 ),
  //                 controller: _cryptoController,
  //               ),
  //             ),
  //             RaisedButton.icon(
  //               elevation: 6,
  //               padding: EdgeInsets.all(6),
  //               onPressed: () {
  //                 final _form = _textFormKey.currentState;
  //                 if (_form.validate()) {
  //                   setState(() {
  //                     walletId = _cryptoController.text;
  //                   });
  //                   cartList.forEach((element) async {
  //                     await registerCryptoWallet(
  //                         cryptoEmail: walletId,
  //                         user: currentUser,
  //                         productPrice: element.productPrice,
  //                         address: deliveryAddress,
  //                         cart: element,
  //                         isCart: true);
  //                     updateProductQuantity(element);
  //                     updateProductBuyers(element);
  //                   });
  //                   _cryptoController.clear();
  //                   Navigator.of(context).pop();
  //                   BotToast.showText(text: "Wallet SuccessFully Added");
  //                 } else {
  //                   _cryptoController.clear();
  //                   BotToast.showText(text: "Invalid input");
  //                 }
  //               },
  //               icon: FaIcon(FontAwesomeIcons.bitcoin),
  //               label: Text("Crypto Wallet"),
  //             ),
  //           ],
  //         );
  //       });
  // }
  //
  // confirmDialog(String clientSecret, PaymentMethod paymentMethod,
  //     Address deliveryAddress) {
  //   double shipCost = 0;
  //   if (deliveryAddress.country == 'United Kingdom') {
  //     totalBuyingPrice >= 250 ? shipCost = 0 : shipCost = 6.36;
  //   } else {
  //     totalBuyingPrice >= 250 ? shipCost = 0 : shipCost = 12.73;
  //   }
  //   setState(() {
  //     finalPayment = totalPriceInCart + shipCost;
  //   });
  //   var confirm = AlertDialog(
  //     title: Text("Confirm Payment"),
  //     content: Container(
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.center,
  //         mainAxisSize: MainAxisSize.min,
  //         children: <Widget>[
  //           Text("Product price:£$totalPriceInCart"),
  //           deliveryAddress.country != "United Kingdom"
  //               ? Container(
  //                   child: totalBuyingPrice <= 250
  //                       ? Text("Shipping price: £12.73")
  //                       : Text("Shipping price: £0"),
  //                 )
  //               : Text(''),
  //           deliveryAddress.country == "United Kingdom"
  //               ? Container(
  //                   child: totalBuyingPrice <= 250
  //                       ? Text("Shipping price: £6.36")
  //                       : Text("Shipping price: £0"),
  //                 )
  //               : Text(''),
  //           Text("Total payment:£$finalPayment"),
  //         ],
  //       ),
  //     ),
  //     actions: <Widget>[
  //       new RaisedButton(
  //         child: new Text('CANCEL'),
  //         onPressed: () {
  //           Navigator.of(context).pop();
  //           BotToast.showText(text: "Payment Cancelled");
  //         },
  //       ),
  //       new RaisedButton(
  //         child: new Text('Confirm'),
  //         onPressed: () {
  //           Navigator.of(context).pop();
  //           confirmPayment(
  //               clientSecret, paymentMethod); // function to confirm Payment
  //         },
  //       ),
  //     ],
  //   );
  //   showDialog(
  //       context: context,
  //       barrierDismissible: false,
  //       builder: (BuildContext context) {
  //         return confirm;
  //       });
  // }
  //
  // confirmPayment(String sec, PaymentMethod paymentMethod) {
  //   StripePayment.confirmPaymentIntent(
  //     PaymentIntent(clientSecret: sec, paymentMethodId: paymentMethod.id),
  //   ).then((val) async {
  //     cartList.forEach((element) async {
  //       await addPaymentDetailsToFirestore(
  //           user: currentUser,
  //           address: deliveryAddress,
  //           productItems: null,
  //           cart: element,
  //           productPrice: element.productPrice,
  //           isCart: true); //Function to add Payment details to firestore
  //     });
  //
  //     Navigator.pop(context);
  //     setState(() {
  //       totalPriceInCart = 0;
  //     });
  //     BotToast.showText(text: "Payment Successful!");
  //   });
  // }
  //
  // final HttpsCallable intent = CloudFunctions.instance
  //     .getHttpsCallable(functionName: 'createPaymentIntent');
  //
  // startPaymentProcess() {
  //   StripePayment.paymentRequestWithCardForm(CardFormPaymentRequest())
  //       .then((paymentMethod) {
  //     BotToast.showText(text: "Wait for Confirmation Dialog!!");
  //     double ttlAmt = totalPriceInCart *
  //         100.0; // multipliying with 100 to change $ to cents
  //     double shipCost = 0;
  //     if (deliveryAddress.country == 'United Kingdom') {
  //       totalBuyingPrice >= 250 ? shipCost = 0 : shipCost = 6.36;
  //     } else {
  //       totalBuyingPrice >= 250 ? shipCost = 0 : shipCost = 12.73;
  //     }
  //     double amount = ttlAmt + shipCost;
  //     intent.call(<String, dynamic>{'amount': amount, 'currency': 'usd'}).then(
  //         (response) {
  //       confirmDialog(response.data["client_secret"], paymentMethod,
  //           deliveryAddress); //function for confirmation for payment
  //     });
  //   });
  // }
  //
  // selectLocation(BuildContext parentContext) async {
  //   BotToast.showText(text: "Select Delivery Address");
  //   return await Navigator.of(context)
  //       .push(MaterialPageRoute(
  //           builder: (context) => DeliveryAddress(justViewing: false)))
  //       .then((value) {
  //     if (deliveryAddress == null) {
  //       BotToast.showText(text: "Delivery Address Not Selected");
  //     } else {
  //       selectPaymentOption(parentContext);
  //     }
  //   });
  // }

  showProduct(BuildContext context, FavCart cartItem) {
    if (cartItem.type == 'vaultItem') {
      setState(() {
        isVaultItem = true;
        isStoreItem = false;
        isAuctionMercItem = false;
      });
    } else if (cartItem.type == 'storeItem') {
      setState(() {
        isVaultItem = false;
        isStoreItem = true;
        isAuctionMercItem = false;
      });
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductScreen(
          hasAllData: false,
          productId: cartItem.productId,
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
