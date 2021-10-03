import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:kannapy/adminScreens/adminHome.dart';
import 'package:kannapy/adminScreens/commentsNChat.dart';
import 'package:kannapy/tools/productItems.dart';
import 'package:kannapy/tools/uiFunctions.dart';
import 'package:kannapy/userScreens/auctionScreen.dart';
import 'package:kannapy/userScreens/checkOut.dart';
import 'package:kannapy/userScreens/productScreens/productScreen.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'home.dart';
import 'profileScreens/dashBoard.dart';

class KannapyNotifications extends StatefulWidget {
  @override
  _KannapyNotificationsState createState() => _KannapyNotificationsState();
}

class _KannapyNotificationsState extends State<KannapyNotifications> {
  bool feedEmpty = true;

  @override
  void initState() {
    delAuctionBidWin();
    getActivityFeed();
    super.initState();
  }

  delAuctionBidWin() async {
    DocumentSnapshot snapshot = await bidWinnersRef.doc(currentUser.id).get();
    if (snapshot.exists) {
      Timestamp timeToPay = snapshot.data()['timeToPay'];
      DocumentSnapshot productSnapshot =
          await auctionTimelineRef.doc(snapshot.data()["auctionItemId"]).get();
      ProductItems productItems = ProductItems.fromDocument(productSnapshot);
      if (timeToPay.toDate().isBefore(DateTime.now())) {
        activityFeedRef.doc(currentUser.id).collection('feedItems').add({
          "type": "bidWinFail",
          "commentData": "You failed To purchase item within Time",
          "userName": currentUser.displayName,
          "userId": currentUser.id,
          "userProfileImg": currentUser.photoUrl,
          "ownerId": productItems.ownerId,
          "mediaUrl": productItems.mediaUrl[0],
          "timestamp": timestamp,
          "productId": productItems.productId,
        });
        activityFeedRef
            .doc(currentUser.id)
            .collection('feedItems')
            .doc(productItems.productId)
            .get()
            .then((value) {
          if (value.exists) {
            value.reference.delete();
          }
        });
      }
    }
  }

  List<ActivityFeedItem> feedItems = [];
  getActivityFeed() async {
    QuerySnapshot snapshot = await activityFeedRef
        .doc(currentUser.id)
        .collection('feedItems')
        .orderBy(
          'timestamp',
          descending: true,
        )
        .limit(50)
        .get();
    snapshot.docs.forEach((doc) {
      feedItems.add(ActivityFeedItem.fromDocument(doc));
    });
    if (feedItems.isEmpty) {
      setState(() {
        feedEmpty = true;
      });
    } else {
      setState(() {
        this.feedItems = feedItems;
        feedEmpty = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            "NOTIFICATIONS",
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
      body: Container(
        // child: FutureBuilder(
        //   future: getActivityFeed(),
        //   builder: (context, snapshot) {
        //     if (!snapshot.hasData) {
        //       return bouncingGridProgress();
        //     }
        child: feedEmpty
            ? Center(
                child: Text(
                  'Currently No Notifications',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
                ),
              )
            : ListView(
                children: feedItems,
              ),
        //}),
      ),
    );
  }
}

Widget mediaPreview;
String activityItemText;

class ActivityFeedItem extends StatefulWidget {
  final String userName;
  final String type; //purchase, review, comment,mercReq,bidWin
  final String mediaUrl;
  final String postId;
  final String userProfileImg;
  final String commentData;
  final Timestamp timestamp;
  final String userId;
  final price;
  final String productId;
  final rating;
  final String storeType;
  ActivityFeedItem({
    this.userName,
    this.type, //purchase, review, comment,,mercReq,bidWin
    this.mediaUrl,
    this.postId,
    this.userProfileImg,
    this.commentData,
    this.timestamp,
    this.userId,
    this.price,
    this.productId,
    this.rating,
    this.storeType,
  });

  factory ActivityFeedItem.fromDocument(DocumentSnapshot doc) {
    return ActivityFeedItem(
      userName: doc.data()['userName'],
      userId: doc.data()['userId'],
      userProfileImg: doc.data()['userProfileImg'],
      postId: doc.data()['postId'],
      commentData: doc.data()['commentData'],
      mediaUrl: doc.data()['mediaUrl'],
      timestamp: doc.data()['timestamp'],
      type: doc.data()['type'],
      price: doc.data()['price'],
      productId: doc.data()['productId'],
      rating: doc.data()['rating'],
      storeType: doc.data()['storeType'],
    );
  }

  @override
  _ActivityFeedItemState createState() => _ActivityFeedItemState();
}

class _ActivityFeedItemState extends State<ActivityFeedItem> {
  showPostComment(context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => CommentsNChat(
                  postId: widget.postId,
                  isPostComment: true,
                  isProductComment: false,
                )));
  }

  showProductReview(context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => CommentsNChat(
                  postId: widget.productId,
                  isPostComment: false,
                  isProductComment: true,
                )));
  }

  String displayName;

  var bidPrice;

  String photoUrl;

  String productMediaUrl;

  var timeToPay;

  String auctionItemId;

  bool hasPaid;

  String productName;

  String deliveryTime;

  String ownerId;

  getBidWinner() async {
    DocumentSnapshot snapshot = await bidWinnersRef.doc(currentUser.id).get();
    displayName = snapshot.data()['displayName'];
    bidPrice = snapshot.data()['bidPrice'];
    photoUrl = snapshot.data()['photoUrl'];
    productMediaUrl = snapshot.data()['productMediaUrl'];
    timeToPay = snapshot.data()['timeToPay'];
    auctionItemId = snapshot.data()['auctionItemId'];
    hasPaid = snapshot.data()['hasPaid'];
    productName = snapshot.data()['productName'];
    deliveryTime = snapshot.data()['deliveryTime'];
    ownerId = snapshot.data()["ownerId"];
  }

  showChats(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => CommentsNChat(
                  isPostComment: false,
                  isProductComment: false,
                  chatId: widget.postId,
                  heroMsg: widget.commentData,
                )));
  }

  showProduct(BuildContext context) {
    print(widget.productId);
    print(widget.storeType);
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      if (widget.storeType == "store") {
        isStoreItem = true;
        isVaultItem = false;
        isAuctionMercItem = false;
        isAuctionVaultItem = false;
        return ProductScreen(
          hasAllData: false,
          productId: widget.productId,
        );
      } else if (widget.storeType == "auctionMerc") {
        isStoreItem = false;
        isVaultItem = false;
        isAuctionMercItem = true;
        isAuctionVaultItem = false;
        return AuctionScreen(
          productId: widget.productId,
          // isVault: false,
        );
      } else if (widget.storeType == "auctionVault") {
        isStoreItem = false;
        isVaultItem = false;
        isAuctionMercItem = false;
        isAuctionVaultItem = true;
        return AuctionScreen(
          productId: widget.productId,
          // isVault: true,
        );
      } else {
        isStoreItem = false;
        isVaultItem = true;
        isAuctionMercItem = false;
        return ProductScreen(
          hasAllData: false,
          productId: widget.productId,
        );
      }
    }));
  }

  configureMediaPreview(context) {
    if (widget.type == 'comment' || widget.type == 'like') {
      mediaPreview = GestureDetector(
        onTap: () => showPostComment(context),
        child: Container(
          height: 50.0,
          width: 50.0,
          child: AspectRatio(
            aspectRatio: 1 / 1,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: widget.mediaUrl != null
                      ? CachedNetworkImageProvider(widget.mediaUrl)
                      : null,
                ),
              ),
            ),
          ),
        ),
      );
    } else if (widget.type == 'review') {
      mediaPreview = GestureDetector(
        onTap: () => showProductReview(context),
        child: Container(
          height: 50.0,
          width: 50.0,
          child: AspectRatio(
            aspectRatio: 1 / 1,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: widget.mediaUrl != null
                      ? CachedNetworkImageProvider(widget.mediaUrl)
                      : null,
                ),
              ),
            ),
          ),
        ),
      );
    } else if (widget.type == 'order' || widget.type == 'othersBid') {
      mediaPreview = GestureDetector(
        onTap: () => showProduct(context),
        child: Container(
          height: 50.0,
          width: 50.0,
          child: AspectRatio(
            aspectRatio: 1 / 1,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: widget.mediaUrl != null
                      ? CachedNetworkImageProvider(widget.mediaUrl)
                      : null,
                ),
              ),
            ),
          ),
        ),
      );
    } else if (widget.type == 'adminChats') {
      mediaPreview = GestureDetector(
        onTap: () => showChats(context),
        child: Container(
          height: 50.0,
          width: 50.0,
          child: AspectRatio(
            aspectRatio: 1 / 1,
            child: Container(
              decoration: BoxDecoration(
                image: widget.mediaUrl != null
                    ? DecorationImage(
                        fit: BoxFit.cover,
                        image: widget.mediaUrl != null
                            ? CachedNetworkImageProvider(
                                widget.mediaUrl,
                              )
                            : null,
                      )
                    : null,
              ),
            ),
          ),
        ),
      );
    } else if (widget.type == 'mercReq') {
      mediaPreview = Container(
        height: 50.0,
        width: 50.0,
        child: AspectRatio(
          aspectRatio: 1 / 1,
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.cover,
                image: widget.mediaUrl != null
                    ? CachedNetworkImageProvider(widget.mediaUrl)
                    : null,
              ),
            ),
          ),
        ),
      );
    } else if (widget.type == 'bidWin') {
      mediaPreview = GestureDetector(
        onTap: () => purchaseAuctionProduct(context),
        child: Container(
          height: 50.0,
          width: 50.0,
          child: AspectRatio(
            aspectRatio: 1 / 1,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: widget.mediaUrl != null
                      ? CachedNetworkImageProvider(widget.mediaUrl)
                      : null,
                ),
              ),
            ),
          ),
        ),
      );
    } else if (widget.type == 'bidWinFail') {
      mediaPreview = GestureDetector(
        onTap: () => showNotificationDetails(context),
        child: Container(
          height: 50.0,
          width: 50.0,
          child: AspectRatio(
            aspectRatio: 1 / 1,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: widget.mediaUrl != null
                      ? CachedNetworkImageProvider(widget.mediaUrl)
                      : null,
                ),
              ),
            ),
          ),
        ),
      );
    } else {
      mediaPreview = Text('');
    }
    if (widget.type == 'order') {
      activityItemText = 'ordered for \$${widget.price}';
    } else if (widget.type == 'review') {
      activityItemText = 'commented On Product:  ${widget.commentData}';
    } else if (widget.type == 'comment') {
      activityItemText = 'commented: ${widget.commentData}';
    } else if (widget.type == 'commentMention') {
      activityItemText = 'mentioned You: ${widget.commentData}';
    } else if (widget.type == 'bidWin') {
      activityItemText = '${widget.commentData}';
    } else if (widget.type == 'bidWinFail') {
      activityItemText = '${widget.commentData}';
    } else if (widget.type == 'othersBid') {
      activityItemText = '${widget.commentData}';
    } else if (widget.type == 'mercReq') {
      activityItemText = "${widget.commentData}";
    } else if (widget.type == 'like') {
      activityItemText = "liked Your Post";
    } else if (widget.type == 'adminChats') {
      activityItemText = "you received a message";
    } else {
      activityItemText = "Error Unknown type '${widget.type}'";
    }
  }

  showNotificationDetails(BuildContext parentContext) {
    return showDialog(
        context: parentContext,
        builder: (context) {
          return SimpleDialog(
            children: <Widget>[
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      child: Image(
                          image: widget.mediaUrl != null
                              ? CachedNetworkImageProvider(widget.mediaUrl)
                              : null),
                      radius: 50.0,
                    ),
                    SizedBox(
                      height: 8.0,
                    ),
                    Text(
                      "Name :${widget.userName}",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 8.0,
                    ),
                    Text(
                      "${widget.commentData}",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 8.0,
                    ),
                    Text(
                      "Time :${widget.timestamp.toDate()}",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 8.0,
                    ),
                  ],
                ),
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    configureMediaPreview(context);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: neumorphicTile(
        padding: 2,
        anyWidget: ListTile(
          isThreeLine: true,
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(widget.userProfileImg),
          ),
          title: RichText(
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                  style: TextStyle(
                      fontSize: 15.0,
                      color: Theme.of(context).textTheme.bodyText1.color),
                  children: [
                    TextSpan(
                      text: widget.userName,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.bodyText1.color),
                    ),
                    TextSpan(text: ' $activityItemText'),
                  ])),
          subtitle: Text(
            timeago.format(widget.timestamp.toDate()),
          ),
          trailing: mediaPreview,
        ),
      ),
    );
  }

  purchaseAuctionProduct(BuildContext context) async {
    await getBidWinner();
    DocumentSnapshot snapshot =
        await auctionTimelineRef.doc(widget.productId).get();
    ProductItems productItems = ProductItems.fromDocument(snapshot);
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => CheckOut(
            //TODO:Work to be done here
            // productItems: productItems,
            // quantitySelected: 1,
            // userId: currentUser.id,
            )));
  }
}
