import 'package:bot_toast/bot_toast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:kannapy/adminScreens/commentsNChat.dart';
import 'package:kannapy/tools/progress.dart';
import 'package:kannapy/tools/uiFunctions.dart';
import 'package:kannapy/userScreens/home.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:kannapy/models/users.dart';
import 'package:kannapy/tools/notificationHandler.dart';

int quantitySelected = 1;
var _varRef;

class ProductItems extends StatefulWidget {
  final String productId;
  final String ownerId;
  final String userName;
  final List mediaUrl;
  final String productName;
  final String description;
  final String subName;
  final bids;
  final String price;
  final String quantity;
  final String rating;
  final favourites;
  final carts;
  final ratingIds;
  final String deliveryTime;
  final String type;
  final Timestamp auctionEndTime;
  final List allBuyers;
  final String ownerMediaUrl;
  final Timestamp liveSaleDate;
  final String reservePrice;
  final String sex;
  final String videoUrl;
  final bool setOnLiveNotification;
  final Map userLiveNotification;
  final bool hasSentWinnerNotification;
  final String bonusQuantity;
  final String bonus;
  ProductItems({
    this.deliveryTime,
    this.productId,
    this.ownerId,
    this.userName,
    this.mediaUrl,
    this.productName,
    this.description,
    this.subName,
    this.price,
    this.quantity,
    this.rating,
    this.favourites,
    this.carts,
    this.type,
    this.bids,
    this.ratingIds,
    this.auctionEndTime,
    this.allBuyers,
    this.ownerMediaUrl,
    this.liveSaleDate,
    this.reservePrice,
    this.sex,
    this.videoUrl,
    this.setOnLiveNotification,
    this.userLiveNotification,
    this.hasSentWinnerNotification,
    this.bonus,
    this.bonusQuantity,
  });
  factory ProductItems.fromDocument(DocumentSnapshot doc) {
    return ProductItems(
      productId: doc.data()["productId"],
      ownerId: doc.data()["ownerId"],
      userName: doc.data()["userName"],
      description: doc.data()["description"],
      productName: doc.data()["productName"],
      mediaUrl: doc.data()["mediaUrl"],
      carts: doc.data()['carts'],
      favourites: doc.data()["favourites"],
      price: doc.data()['price'],
      quantity: doc.data()["quantity"],
      rating: doc.data()['rating'],
      subName: doc.data()["subName"],
      deliveryTime: doc.data()['deliveryTime'],
      type: doc.data()['type'],
      bids: doc.data()['bids'],
      ratingIds: doc.data()['ratingIds'],
      auctionEndTime: doc.data()['auctionEndTime'],
      allBuyers: doc.data()['allBuyers'],
      ownerMediaUrl: doc.data()['ownerMediaUrl'],
      liveSaleDate: doc.data()['liveSaleDate'],
      reservePrice: doc.data()['reservePrice'],
      sex: doc.data()['sex'],
      videoUrl: doc.data()['videoUrl'],
      setOnLiveNotification: doc.data()['setOnLiveNotification'],
      userLiveNotification: doc.data()['userLiveNotification'],
      hasSentWinnerNotification: doc.data()["hasSentWinnerNotification"],
      bonus: doc.data()["bonus"],
      bonusQuantity: doc.data()["bonusQuantity"],
    );
  }
  @override
  _ProductItemsState createState() => _ProductItemsState(
        productId: this.productId,
        ownerId: this.ownerId,
        userName: this.userName,
        description: this.description,
        productName: this.productName,
        mediaUrl: this.mediaUrl,
        carts: this.carts,
        favourites: this.favourites,
        price: this.price,
        quantity: this.quantity,
        subName: this.subName,
        deliveryTime: this.deliveryTime,
        type: this.type,
        bids: this.bids,
        ratingIds: this.ratingIds,
        auctionEndTime: this.auctionEndTime,
        ownerMediaUrl: this.ownerMediaUrl,
        liveSaleDate: this.liveSaleDate,
        reservePrice: this.reservePrice,
        sex: this.sex,
        videoUrl: this.videoUrl,
        bonus: this.bonus,
        hasSentWinnerNotification: this.hasSentWinnerNotification,
        bonusQuantity: this.bonusQuantity,
      );
}

class _ProductItemsState extends State<ProductItems> {
  final String currentUserId = currentUser?.id;
  final String productId;
  final String ownerId;
  final String userName;
  final List mediaUrl;
  final String productName;
  final String description;
  final String subName;
  final String deliveryTime;
  final auctionEndTime;
  final String type;
  final bids;
  final String price;
  final String quantity;
  final favourites;
  final carts;
  final ratingIds;
  final String videoUrl;
  final String ownerMediaUrl;
  final String bonus;
  List allBuyers;
  final Timestamp liveSaleDate;
  final String reservePrice;
  final String sex;
  final bool hasSentWinnerNotification;
  final String bonusQuantity;
  // Map ratingsMap = {};
  // double avgRating = 0;
  // double allRatings = 0;
  //
  // double ratings = 0;

  bool isUploading = false;
  _ProductItemsState({
    this.productId,
    this.ownerId,
    this.userName,
    this.description,
    this.productName,
    this.mediaUrl,
    this.carts,
    this.favourites,
    this.price,
    this.quantity,
    this.subName,
    this.type,
    this.deliveryTime,
    this.bids,
    this.ratingIds,
    this.auctionEndTime,
    this.allBuyers,
    this.ownerMediaUrl,
    this.liveSaleDate,
    this.reservePrice,
    this.sex,
    this.videoUrl,
    this.hasSentWinnerNotification,
    this.storeType,
    this.bonus,
    this.bonusQuantity,
  });
  YoutubePlayerController _ytController;
  @override
  initState() {
    _ytController = YoutubePlayerController(
      initialVideoId: videoUrl != null ? videoUrl : "",
      flags: YoutubePlayerFlags(
        autoPlay: false,
        hideThumbnail: false,
        controlsVisibleAtStart: true,
        mute: false,
      ),
    );
    super.initState();
  }

  @override
  dispose() {
    _ytController.dispose();
    super.dispose();
  }

  TextEditingController _reviewController = TextEditingController();
  String storeType;
  List<CommentsNMessages> allReviews = [];

  buildProductDetailsFuture() {
    int idx = 0;
    if (isAuctionMercItem) {
      setState(() {
        _varRef = auctionTimelineRef;
        storeType = 'auctionMerc';
      });
    } else if (isStoreItem) {
      setState(() {
        _varRef = storeTimelineRef;
        storeType = 'store';
      });
    }
    // else if (isAuctionVaultItem) {
    //   setState(() {
    //     _varRef = auctionVaultTimelineRef;
    //     storeType = 'auctionVault';
    //   });
    // }
    else if (isVaultItem) {
      setState(() {
        _varRef = seedVaultTimelineRef;
        storeType = 'vault';
      });
    }
    return FutureBuilder(
        future: _varRef.document(productId).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return bouncingGridProgress();
          }

          ProductItems productItems = ProductItems.fromDocument(snapshot.data);
          print(productItems.allBuyers);
          // ratingsMap = productItems.ratingIds;
          // if (ratingsMap != null) {
          //   ratingsMap.forEach((key, value) {
          //     allRatings += value;
          //   });
          // }

          Size screenSize = MediaQuery.of(context).size;
          print(videoUrl);
          return Column(
            children: <Widget>[
              neumorphicTile(
                circular: false,
                padding: 2,
                anyWidget: videoUrl != null
                    ? buildVideoPlayer()
                    : Container(
                        height: 300.0,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(120),
                            bottomRight: Radius.circular(120),
                          ),
                        ),
                        child: CarouselSlider.builder(
                          itemCount: productItems.mediaUrl.length,
                          options: CarouselOptions(
                            height: 300.0,
                            autoPlay: true,
                            enableInfiniteScroll: false,
                            aspectRatio: 1,
                            initialPage: idx,
                          ),
                          itemBuilder: (context, int itemIndex) {
                            return Container(
                              width: MediaQuery.of(context).size.width,
                              margin: EdgeInsets.symmetric(horizontal: 5.0),
                              child: Image(
                                image: CachedNetworkImageProvider(
                                    productItems.mediaUrl[itemIndex]),
                                fit: BoxFit.fill,
                              ),
                            );
                          },
                        )),
              ),
              SizedBox(
                height: 15,
              ),
              imagesListCard(productItems: productItems),
              SizedBox(
                height: 15.0,
              ),
              neumorphicTile(
                padding: 1,
                anyWidget: Container(
                  width: screenSize.width * 0.8,
                  margin: EdgeInsets.only(left: 20.0, right: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        height: 15.0,
                      ),
                      Text(
                        productName,
                        style: TextStyle(
                            fontSize: 18.0, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                subName,
                                style: TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w400),
                              ),
                              SizedBox(
                                height: 10.0,
                              ),
                              Text(
                                isAuctionMercItem || isAuctionVaultItem
                                    ? "Initial Bidding: £$price"
                                    : "Price :£$price",
                                style: TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.w700),
                                overflow: TextOverflow.fade,
                              ),
                              SizedBox(
                                height: 20.0,
                              ),
                            ],
                          ),
                          CircleAvatar(
                            backgroundImage: ownerMediaUrl != null
                                ? CachedNetworkImageProvider(ownerMediaUrl)
                                : null,
                            backgroundColor: Colors.black,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 15,
              ),
              descriptionCard(),
              SizedBox(
                height: 15,
              ),
              bonus != null ? bonusCard() : Container(),
              SizedBox(
                height: 15,
              ),
              isAuctionMercItem ? SizedBox(height: 0.1) : quantityCard(),
              isAuctionMercItem
                  ? SizedBox(height: 0.1)
                  : SizedBox(
                      height: 15,
                    ),
              reviews(productItems: productItems),
              SizedBox(
                height: 30,
              ),
            ],
          );
        });
  }

  buildProductDetails() {
    int idx = 0;
    if (isAuctionMercItem) {
      setState(() {
        _varRef = auctionTimelineRef;
        storeType = 'auctionStore';
      });
    } else if (isStoreItem) {
      setState(() {
        _varRef = storeTimelineRef;
        storeType = 'store';
      });
    }
    // else if (isAuctionVaultItem) {
    //   setState(() {
    //     _varRef = auctionVaultTimelineRef;
    //     storeType = 'auctionVault';
    //   });
    // }
    else if (isVaultItem) {
      setState(() {
        _varRef = seedVaultTimelineRef;
        storeType = 'vault';
      });
    }
    Size screenSize = MediaQuery.of(context).size;
    return Column(
      children: <Widget>[
        neumorphicTile(
          circular: false,
          padding: 2,
          anyWidget: videoUrl != null
              ? buildVideoPlayer()
              : Container(
                  height: 300.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(120),
                      bottomRight: Radius.circular(120),
                    ),
                  ),
                  child: CarouselSlider.builder(
                    itemCount: mediaUrl.length,
                    options: CarouselOptions(
                      height: 400.0,
                      autoPlay: true,
                      enableInfiniteScroll: false,
                      aspectRatio: 1,
                      initialPage: idx,
                    ),
                    itemBuilder: (context, int itemIndex) {
                      return Container(
                        width: MediaQuery.of(context).size.width,
                        margin: EdgeInsets.symmetric(horizontal: 5.0),
                        child: Image(
                          image:
                              CachedNetworkImageProvider(mediaUrl[itemIndex]),
                          fit: BoxFit.fitHeight,
                        ),
                      );
                    },
                  )),
        ),
        SizedBox(
          height: 15,
        ),
        imagesListCard(),
        SizedBox(
          height: 15.0,
        ),
        neumorphicTile(
          padding: 1,
          anyWidget: Container(
            width: screenSize.width * 0.8,
            margin: EdgeInsets.only(left: 20.0, right: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  height: 15.0,
                ),
                Text(
                  productName,
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 10.0,
                ),
                Row(
                  children: [
                    Column(
                      children: [
                        Text(
                          subName,
                          style: TextStyle(
                              fontSize: 14.0, fontWeight: FontWeight.w400),
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        Text(
                          isAuctionMercItem
                              ? "Initial Bidding: £$price"
                              : "Price :£$price",
                          style: TextStyle(
                              fontSize: 18.0, fontWeight: FontWeight.w700),
                          overflow: TextOverflow.fade,
                        ),
                        SizedBox(
                          height: 20.0,
                        ),
                      ],
                    ),
                    CircleAvatar(
                      backgroundImage:
                          CachedNetworkImageProvider(ownerMediaUrl),
                      backgroundColor: Colors.white,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          height: 15,
        ),
        descriptionCard(),
        SizedBox(
          height: 15,
        ),
        bonus != null ? bonusCard() : Container(),
        SizedBox(
          height: 15,
        ),
        isAuctionMercItem ? SizedBox(height: 0.1) : quantityCard(),
        isAuctionMercItem
            ? SizedBox(height: 0.1)
            : SizedBox(
                height: 15,
              ),
        reviews(),
        SizedBox(
          height: 30,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: buildProductDetailsFuture());
  }

  descriptionCard() {
    return neumorphicTile(
      padding: 1,
      anyWidget: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        margin: EdgeInsets.only(left: 20.0, right: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 20.0,
            ),
            Text(
              "Description",
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w700),
            ),
            SizedBox(
              height: 20.0,
            ),
            Text(
              description,
              style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w400),
            ),
            SizedBox(
              height: 20.0,
            ),
          ],
        ),
      ),
    );
  }

  bonusCard() {
    return neumorphicTile(
      padding: 1,
      anyWidget: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        margin: EdgeInsets.only(left: 20.0, right: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 20.0,
            ),
            Text(
              "Bonus",
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w700),
            ),
            SizedBox(
              height: 20.0,
            ),
            Text(
              bonus,
              style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w400),
            ),
            SizedBox(
              height: 20.0,
            ),
          ],
        ),
      ),
    );
  }

  buildVideoPlayer() {
    return YoutubePlayer(
      controller: _ytController,
      showVideoProgressIndicator: true,
      aspectRatio: 1,
    );
  }

  imagesListCard({ProductItems productItems}) {
    return neumorphicTile(
      circular: false,
      padding: 2,
      anyWidget: Container(
        width: MediaQuery.of(context).size.width,
        height: 150.0,
        child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: productItems.mediaUrl.length,
            itemBuilder: (context, index) {
              print(index);
              return GestureDetector(
                onTap: () {
                  Navigator.of(context).push(new PageRouteBuilder(
                      opaque: false,
                      pageBuilder: (BuildContext context, _, __) {
                        return Material(
                          elevation: 20,
                          color: Colors.black87,
                          child: Container(
                            padding: EdgeInsets.all(20.0),
                            height: 400.0,
                            width: 400.0,
                            child: InkWell(
                              onTap: () {
                                Navigator.of(context).pop();
                              },
                              child: Hero(
                                tag: productItems.mediaUrl[index],
                                child: CarouselSlider.builder(
                                  itemCount: productItems.mediaUrl.length,
                                  options: CarouselOptions(
                                      height: 400.0, initialPage: index),
                                  itemBuilder: (context, int itemIndex) {
                                    return Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        margin: EdgeInsets.symmetric(
                                            horizontal: 5.0),
                                        child: Image(
                                          image: CachedNetworkImageProvider(
                                              productItems.mediaUrl[itemIndex]),
                                        ));
                                  },
                                ),
                              ),
                            ),
                          ),
                        );
                      }));
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(left: 5.0, right: 5.0),
                      height: 140.0,
                      width: 100.0,
                      child: Hero(
                        tag: productItems.mediaUrl[index],
                        child: Image(
                          image: CachedNetworkImageProvider(
                              productItems.mediaUrl[index]),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 5.0, right: 5.0),
                      height: 140.0,
                      width: 100.0,
                      // decoration:
                      //     BoxDecoration(color: Colors.grey.withAlpha(50)),
                    ),
                  ],
                ),
              );
            }),
      ),
    );
  }

  Widget quantityCard() {
    return int.parse(quantity) > 0
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
                            postOwnerId: ownerId,
                            postMediaUrl: mediaUrl[0],
                            postId: productId,
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
          .doc(productId)
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
                                      postId: productId,
                                      postMediaUrl: mediaUrl[0],
                                      postOwnerId: ownerId,
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
      await commentsRef.doc(productId).collection("comments").add({
        "userName": currentUser.userName,
        "userId": currentUser.id,
        "androidNotificationToken": currentUser.androidNotificationToken,
        "comment": _reviewController.text,
        "timestamp": timestamp,
        "avatarUrl": currentUser.photoUrl,
        "isComment": false,
        "isProductComment": true,
        "postId": productId,
        "commentId": commentId,
        "likesMap": {},
        "likes": 0,
      });
      bool isNotProductOwner = ownerId != currentUser.id;
      if (isNotProductOwner) {
        allAdmins.forEach((element) {
          activityFeedRef.doc(element.id).collection('feedItems').add({
            "type": "comment",
            "commentData": _reviewController.text,
            "userName": currentUser.userName,
            "userId": currentUser.id,
            "userProfileImg": currentUser.photoUrl,
            "postId": productId,
            "mediaUrl": mediaUrl,
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
}
