import 'package:bot_toast/bot_toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:kannapy/adminScreens/commentsNChat.dart';
import 'package:kannapy/tools/CommonFunctions.dart';
import 'package:kannapy/tools/productItems.dart';
import 'package:kannapy/tools/progress.dart';
import 'package:kannapy/tools/uiFunctions.dart';
import 'package:kannapy/userScreens/cart.dart';
import 'package:kannapy/userScreens/home.dart';
import 'package:kannapy/userScreens/productScreens/kannapyStore.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:kannapy/tools/notificationHandler.dart';
import 'package:kannapy/models/users.dart';
import 'package:kannapy/adminScreens/addEditProducts.dart';

class ProductScreen extends StatefulWidget {
  // final List<dynamic> productMediaUrl;
  final String productId;
  final ProductItems productItems;
  final bool hasAllData;
  ProductScreen({
    //this.productMediaUrl,
    @required this.productId,
    this.productItems,
    @required this.hasAllData,
  });

  @override
  _ProductScreenState createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  bool isInCart = false;
  ProductItems productItems;
  bool isUploading = false;
  TextEditingController _reviewController = TextEditingController();
  YoutubePlayerController _ytController;

  bool notificationSetBool = false;
  bool orderNow = false;

  List allReviews = [];
  getProductItems() async {
    DocumentSnapshot snapshot = isStoreItem
        ? await storeTimelineRef.doc(widget.productId).get()
        : await seedVaultTimelineRef.doc(widget.productId).get();
    setState(() {
      productItems = ProductItems.fromDocument(snapshot);
    });
  }

  @override
  initState() {
    _ytController = YoutubePlayerController(
      initialVideoId:
          widget.productItems != null && widget.productItems.videoUrl != null
              ? widget.productItems.videoUrl
              : "",
      flags: YoutubePlayerFlags(
        autoPlay: false,
        hideThumbnail: false,
        controlsVisibleAtStart: true,
        mute: false,
      ),
    );
    super.initState();
  }

  buildVideoPlayer() {
    return YoutubePlayer(
      controller: _ytController,
      showVideoProgressIndicator: true,
      aspectRatio: 1,
    );
  }

  handleCart({bool orderNow = false}) async {
    bool _isInCart = productItems.carts[currentUser.id] == true;
    print(_isInCart);
    if (_isInCart) {
      cartCount -= 1;
      cartRef
          .doc(currentUser.id)
          .collection("cartItems")
          .doc(productItems.productId)
          .delete();
      isStoreItem
          ? storeTimelineRef
              .doc(productItems.productId)
              .update({"carts.${currentUser.id}": false})
          : seedVaultTimelineRef
              .doc(productItems.productId)
              .update({"carts.${currentUser.id}": false});
      setState(() {
        productItems.carts[currentUser.id] = false;
        isInCart = false;
      });
      // ignore: unnecessary_statements
      orderNow ? null : BotToast.showText(text: "Removed From Cart");
    } else if (!_isInCart) {
      cartCount += 1;
      cartRef
          .doc(currentUser.id)
          .collection("cartItems")
          .doc(productItems.productId)
          .set({
        "mediaUrl": productItems.mediaUrl[0],
        "productId": productItems.productId,
        "userId": currentUser.id,
        "productName": productItems.productName,
        "productPrice": productItems.price,
        'productSubHeading': productItems.subName,
        "quantityLeft": productItems.quantity,
        'quantitySelected': quantitySelected,
        'type': productItems.type,
      }).then(
        (value) => orderNow
            ? Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => KannapyCart(
                    userId: currentUser.id,
                  ),
                ),
              )
            : null,
      );
      isStoreItem
          ? storeTimelineRef
              .doc(widget.productId)
              .update({"carts.${currentUser.id}": true})
          : seedVaultTimelineRef
              .doc(widget.productId)
              .update({"carts.${currentUser.id}": true});
      // ignore: unnecessary_statements
      orderNow ? null : BotToast.showText(text: "Added To Carts");
      setState(() {
        isInCart = true;
        productItems.carts[currentUser.id] = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.hasAllData
        ? buildProductScreen()
        : buildProductScreenFuture();
  }

  buildProductScreenFuture() {
    return FutureBuilder(
        future: isStoreItem
            ? storeTimelineRef.doc(widget.productId).get()
            : seedVaultTimelineRef.doc(widget.productId).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return bouncingGridProgress();
          }
          productItems = ProductItems.fromDocument(snapshot.data);
          bool isProductOwner = currentUser.id == productItems.ownerId;
          isInCart = productItems.carts[currentUser.id] == true;

          return Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: Text(
                productItems.productName,
                style: TextStyle(
                    color: Theme.of(context)
                        .appBarTheme
                        .textTheme
                        .headline1
                        .color),
              ),
              actions: [
                isProductOwner || isAdmin
                    ? IconButton(
                        icon: Icon(Icons.more_vert),
                        onPressed: () => handleOptionProduct(
                            context, productItems.mediaUrl, productItems))
                    : Text(""),
              ],
            ),
            body: ListView(
              children: <Widget>[
                Container(
                  child: productItems,
                ),
              ],
            ),
            //TODO:Implement notification reminder functionality i.e send notification when the product will go live
            floatingActionButton: int.parse(productItems.quantity) > 0
                ? FloatingActionButton(
                    elevation: 5,
                    backgroundColor: Colors.black,
                    onPressed: handleCart,
                    child: Icon(
                      isInCart ? Icons.shopping_cart : Icons.add_shopping_cart,
                      color: Colors.white,
                    ),
                  )
                : null,
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            bottomNavigationBar: int.parse(productItems.quantity) > 0
                ? BottomAppBar(
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
                                  .doc(currentUser.id)
                                  .collection("favouriteProducts")
                                  .doc(productItems.productId)
                                  .set({
                                "mediaUrl": productItems.mediaUrl[0],
                                "productId": productItems.productId,
                                "userId": currentUser.id,
                                'productSubHeading': productItems.subName,
                                "productName": productItems.productName,
                                "productPrice": productItems.price,
                                "quantityLeft": productItems.quantity,
                              });
                              BotToast.showText(
                                text: 'Added To Wish list',
                              );
                            },
                            child: Container(
                              width:
                                  (MediaQuery.of(context).size.width - 20) / 2,
                              child: Text(
                                "ADD TO WISH LIST",
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
                                  builder: (context) => KannapyCart(
                                        userId: currentUser.id,
                                        // productItems: productItems,
                                      )));
                            },
                            child: Container(
                              width:
                                  (MediaQuery.of(context).size.width - 20) / 2,
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
                  )
                : null,
          );
        });
  }

  buildProductScreen() {
    String type;
    setState(() {
      productItems = widget.productItems;
    });
    print(productItems);
    //TODO:May be bottom button functions like cart and buy are not properly implemented in database(I think every item is being set to merchandise)

    bool isLive = productItems.liveSaleDate != null &&
        productItems.liveSaleDate.toDate().isBefore(DateTime.now());
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Hero(
          tag: widget.productItems.productName,
          child: Text(
            productItems.productName,
            style: TextStyle(
                color: Theme.of(context).appBarTheme.textTheme.headline1.color),
          ),
        ),
        actions: [
          isAdmin
              ? IconButton(
                  icon: Icon(Icons.more_vert),
                  onPressed: () => handleOptionProduct(
                      context, productItems.mediaUrl, productItems))
              : Text(""),
        ],
      ),
      body: ListView(
        children: <Widget>[
          Container(
            child: widget.hasAllData
                ? buildProductDetails(
                    type: type,
                    context: context,
                    productItems: widget.productItems,
                    quantityCard: quantityCard(widget.productItems.quantity),
                    reviews: reviews(productItems: widget.productItems),
                    buildVideoPlayer: buildVideoPlayer(),
                    isLive: isLive,
                    setReminder: setReminder(widget.productItems))
                : productItems,
          ),
        ],
      ),
      floatingActionButton: int.parse(productItems.quantity) > 0
          ? FloatingActionButton(
              elevation: 5,
              backgroundColor: Colors.black,
              onPressed: handleCart,
              child: Icon(
                isInCart ? Icons.shopping_cart : Icons.add_shopping_cart,
                color: Colors.white,
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: int.parse(productItems.quantity) > 0
          ? BottomAppBar(
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
                            .doc(currentUser.id)
                            .collection("favouriteProducts")
                            .doc(productItems.productId)
                            .set({
                          "mediaUrl": productItems.mediaUrl[0],
                          "productId": productItems.productId,
                          "userId": currentUser.id,
                          'productSubHeading': productItems.subName,
                          "productName": productItems.productName,
                          "productPrice": productItems.price,
                          "quantityLeft": productItems.quantity,
                        });
                        BotToast.showText(
                          text: 'Added To Wish list',
                        );
                      },
                      child: Container(
                        width: (MediaQuery.of(context).size.width - 20) / 2,
                        child: Text(
                          "ADD TO WISH LIST",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          orderNow = true;
                        });
                        handleCart(orderNow: orderNow);
                        // Navigator.of(context).push(MaterialPageRoute(
                        //   builder: (context) => KannapyCart(
                        //     userId: currentUser.id,
                        //   ),
                        //
                        //   // CheckOutPage(
                        //   //   userId: currentUser.id,
                        //   //   quantitySelected: quantitySelected,
                        //   //   productItems: productItems,
                        //   // ),
                        // ));
                      },
                      child: Container(
                        width: (MediaQuery.of(context).size.width - 20) / 2,
                        child: Text(
                          "ORDER NOW",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }

  setReminder(ProductItems productItems) {
    notificationSetBool = widget.productItems.setOnLiveNotification != null
        ? widget.productItems.setOnLiveNotification
        : false;
    return neumorphicTile(
        anyWidget: Container(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Column(
                children: [
                  Text("Product will get Live on:"),
                  Text(productItems.liveSaleDate.toString()),
                ],
              ),
            ),
          ),
          Center(
            child: neumorphicTile(
              anyWidget: IconButton(
                icon: Icon(notificationSetBool
                    ? Icons.notifications
                    : Icons.notifications_none),
                onPressed: () {
                  setState(() {
                    if (notificationSetBool) {
                      notificationSetBool = false;
                      BotToast.showText(
                          text: "Product Notification Reminder Deleted");
                    } else {
                      notificationSetBool = true;
                      BotToast.showText(
                          text:
                              "You will be notified when the product will go live");
                    }
                  });

                  isStoreItem
                      ? storeTimelineRef.doc(productItems.productId).update({
                          "setOnLiveNotification": notificationSetBool,
                          "userLiveNotification.${currentUser.id}":
                              notificationSetBool,
                        })
                      : seedVaultTimelineRef
                          .doc(productItems.productId)
                          .update({
                          "userLiveNotification.${currentUser.id}":
                              notificationSetBool,
                          "setOnLiveNotification": notificationSetBool,
                        });
                },
              ),
            ),
          ),
        ],
      ),
    ));
  }

  Widget quantityCard(var quantity) {
    return quantity != null && int.parse(quantity) > 0
        ? Neumorphic(
            style: NeumorphicStyle(
                shape: NeumorphicShape.concave,
                boxShape:
                    NeumorphicBoxShape.roundRect(BorderRadius.circular(20)),
                depth: 4,
                intensity: 1,
                surfaceIntensity: 0.2,
                lightSource: LightSource.topLeft,
                color: int.parse(quantity) > 0 ? Colors.white : Colors.black),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              margin: EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Available in Stock",
                    style:
                        TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  int.parse(quantity) > 0
                      ? Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                GestureDetector(
                                  child: CircleAvatar(
                                    backgroundColor: Colors.black,
                                    child: Icon(
                                      Icons.remove,
                                    ),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      if (quantitySelected > 1) {
                                        quantitySelected = quantitySelected - 1;
                                      } else {
                                        BotToast.showText(
                                            text: "Minimum Quantity reached");
                                      }
                                    });
                                  },
                                ),
                                Text("$quantitySelected"),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      if (quantitySelected <
                                          int.parse(quantity)) {
                                        quantitySelected = quantitySelected + 1;
                                      } else {
                                        BotToast.showText(
                                            text: "Maximum Quantity reached");
                                      }
                                    });
                                  },
                                  child: CircleAvatar(
                                    backgroundColor: Colors.black,
                                    child: Icon(Icons.add),
                                  ),
                                ),
                              ],
                            ),
                            Text('Select Quantity'),
                          ],
                        )
                      : Text(''),
                ],
              ),
            ),
          )
        : Container(
            width: MediaQuery.of(context).size.width * 0.8,
            height: 50.0,
            margin: EdgeInsets.only(left: 20.0, right: 20.0),
            child: Center(
              child: Text(
                'Out Of Stock',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                ),
              ),
            ),
          );
  }

  reviews({ProductItems productItems}) {
    return neumorphicTile(
      padding: 1,
      anyWidget: Container(
        width: MediaQuery.of(context).size.width * 0.87,
        margin: EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Comments",
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
            ),
            writeReviews(),
            Column(
              children: <Widget>[
                GestureDetector(
                  child: buildReviews(),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => CommentsNChat(
                            isProductComment: true,
                            isPostComment: false,
                            postOwnerId: widget.productItems.ownerId,
                            postMediaUrl: widget.productItems.mediaUrl[0],
                            postId: widget.productItems.productId,
                          ))),
                ),
              ],
            ),
            SizedBox(
              height: 20.0,
            ),
          ],
        ),
      ),
    );
  }

  writeReviews() {
    return Column(
      children: [
        // Row(
        //   children: [
        //     SmoothStarRating(
        //       color: Colors.amberAccent,
        //       allowHalfRating: false,
        //       size: 20.0,
        //       isReadOnly: false,
        //       borderColor: Colors.white70,
        //       onRated: (rate) {
        //         int totalRatingNumbers = 0;
        //
        //         ratingsMap == null
        //             ? totalRatingNumbers = 0
        //             : totalRatingNumbers = ratingsMap.length;
        //         setState(() {
        //           avgRating =
        //               ((double.parse(rating.toString()) * totalRatingNumbers) +
        //                       rate) /
        //                   (totalRatingNumbers + 1);
        //           ratings = rate;
        //         });
        //       },
        //       defaultIconData: Icons.star_border,
        //       filledIconData: Icons.star,
        //       halfFilledIconData: Icons.star_half,
        //     ),
        //     SizedBox(
        //       width: 8.0,
        //     ),
        //   ],
        // ),
        ListTile(
          title: TextFormField(
            controller: _reviewController,
            decoration: InputDecoration(
              hintText: "Comment",
            ),
          ),
          trailing: IconButton(
            onPressed: addReview,
            icon: isUploading
                ? Text('')
                : Icon(
                    Icons.send,
                    size: 40.0,
                    color: Colors.black,
                  ),
          ),
        ),
      ],
    );
  }

  buildReviews() {
    return StreamBuilder(
      stream: commentsRef
          .doc(widget.productId)
          .collection("comments")
          .orderBy("timestamp", descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return bouncingGridProgress();
        }
        snapshot.data.documents.forEach((doc) {
          allReviews.add(CommentsNMessages.fromDocument(doc));
        });
        return allReviews.isEmpty
            ? Center(child: Text("Currently No comment"))
            : Center(
                child: Column(
                  children: [
                    Container(
                      child: allReviews.last,
                    ),
                    GestureDetector(
                        onTap: () =>
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => CommentsNChat(
                                      postId: widget.productId,
                                      postMediaUrl:
                                          widget.productItems.mediaUrl[0],
                                      postOwnerId: widget.productItems.ownerId,
                                      isPostComment: false,
                                      isProductComment: true,
                                    ))),
                        child: Text(
                          'View All Comments',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        )),
                  ],
                ),
              );
      },
    );
  }

  addReview() async {
    List allAdmins = [];
    QuerySnapshot snapshots =
        await userRef.where('type', isEqualTo: 'admin').get();
    snapshots.docs.forEach((e) {
      allAdmins.add(AppUser.fromDocument(e));
    });

    String commentId = Uuid().v4();
    setState(() {
      isUploading = true;
    });
    if (_reviewController.text.trim().length > 0) {
      await commentsRef
          .doc(widget.productItems.productId)
          .collection("comments")
          .add({
        "userName": currentUser.userName,
        "userId": currentUser.id,
        "androidNotificationToken": currentUser.androidNotificationToken,
        "comment": _reviewController.text,
        "timestamp": timestamp,
        "avatarUrl": currentUser.photoUrl,
        "isComment": false,
        "isProductComment": true,
        "postId": widget.productItems.productId,
        "commentId": commentId,
        "likesMap": {},
        "likes": 0,
      });
      bool isNotProductOwner = widget.productItems.ownerId != currentUser.id;
      if (isNotProductOwner) {
        allAdmins.forEach((element) {
          activityFeedRef.doc(element.id).collection('feedItems').add({
            "type": "comment",
            "commentData": _reviewController.text,
            "userName": currentUser.userName,
            "userId": currentUser.id,
            "userProfileImg": currentUser.photoUrl,
            "postId": widget.productItems.productId,
            "mediaUrl": widget.productItems.mediaUrl[0],
            "timestamp": timestamp,
          });
          sendAndRetrieveMessage(
              token: element.androidNotificationToken,
              message: _reviewController.text,
              title: "Product Comment");
        });
      }
      BotToast.showText(text: 'Comment added');

      _reviewController.clear();
      setState(() {
        isUploading = false;
      });
    } else {
      BotToast.showText(text: "Field shouldn't be left empty");
    }
    setState(() {
      isUploading = false;
    });
  }

  handleOptionProduct(
      BuildContext parentContext, List mediaUrl, ProductItems productItems) {
    return showDialog(
        context: parentContext,
        builder: (context) {
          return SimpleDialog(
            children: <Widget>[
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => AddEditProducts(
                            currentUser: currentUser,
                            productItems: productItems,
                            isEdit: true,
                          )));
                },
                child: Text(
                  'Edit',
                ),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context);
                  deleteProduct(mediaUrl);
                },
                child: Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
              SimpleDialogOption(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              )
            ],
          );
        });
  }

  void deleteProduct(List mediaUrl) async {
    await productRef
        .doc(currentUser.id)
        .collection("productItems")
        .doc(widget.productId)
        .get()
        .then((doc) {
      if (doc.exists) {}
      doc.reference.delete();
      storeTimelineRef.doc(widget.productId).get().then((doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      });
      auctionTimelineRef.doc(widget.productId).get().then((doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      });
      seedVaultTimelineRef.doc(widget.productId).get().then((doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      });
    });
    for (int i = 0; i < mediaUrl.length; i++) {
      await storageRef
          .child(
              "products_${widget.productItems.type}/$i-${widget.productItems}.jpg")
          .delete();
    }
    (await commentsRef.doc(widget.productId).collection('reviews').get())
        .docs
        .forEach((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    BotToast.showText(text: "Product Deleted Please Refresh");
  }
}
