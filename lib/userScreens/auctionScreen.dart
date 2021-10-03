import 'package:bot_toast/bot_toast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kannapy/models/users.dart';
import 'package:kannapy/tools/productItems.dart';
import 'package:kannapy/tools/progress.dart';
import 'package:kannapy/userScreens/home.dart';
import 'package:slide_countdown_clock/slide_countdown_clock.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:timer_count_down/timer_count_down.dart';
import 'package:kannapy/models/biddersModel.dart';
import 'package:kannapy/tools/notificationHandler.dart';
import 'package:kannapy/tools/CommonFunctions.dart';
import 'package:kannapy/adminScreens/addEditProducts.dart';

class AuctionScreen extends StatefulWidget {
  final String productId;
  final ProductItems productItems;
  // final bool isVault;
  AuctionScreen({
    this.productId,
    this.productItems,
    // @required this.isVault
  });
  @override
  _AuctionScreenState createState() => _AuctionScreenState();
}

class _AuctionScreenState extends State<AuctionScreen> {
  List biddersIds = [];
  Map biddersMap = {};
  List biddersBids = [];
  bool stopBidding = false;
  List<Bidders> allBiddersGlobal = [];

  TextEditingController bidController = TextEditingController();
  ScrollController _biddersController = ScrollController();

  var highestBid;
  var highestBidder;
  Map bidsMapArrByPrices;
  AppUser highestBidderData;
  ProductItems productItemsInit;
  var _varRef;
  bool closeClock = false;
  @override
  void initState() {
    // _varRef = widget.isVault ? auctionVaultTimelineRef : auctionTimelineRef;
    _varRef = auctionTimelineRef;
    getHighestBidder(productItemsInit: productItemsInit, varRef: _varRef);
    super.initState();
  }

  checkTime(ProductItems productItemsInit) async {
    setState(() {
      closeClock = productItemsInit.auctionEndTime.toDate().isBefore(timestamp);
      stopBidding =
          productItemsInit.auctionEndTime.toDate().isBefore(timestamp);
    });
    var submissionTime = productItemsInit.auctionEndTime
        .toDate()
        .add(Duration(days: 1, minutes: 20));
    if (stopBidding &&
        highestBidderData != null &&
        productItemsInit.hasSentWinnerNotification) {
      bidWinnersRef.doc(highestBidderData.id).get().then((doc) {
        if (!doc.exists) {
          doc.reference.set({
            "id": highestBidderData.id,
            "displayName": highestBidderData.userName,
            "auctionItemId": productItemsInit.productId,
            "bid": highestBid,
            "productName": productItemsInit.productName,
            "timeToPay": submissionTime,
            "hasPaid": false,
            'photoUrl': highestBidderData.photoUrl,
            'productMediaUrl': productItemsInit.mediaUrl[0],
            'deliveryTime': productItemsInit.deliveryTime,
            'ownerId': productItemsInit.ownerId
          });
        }
      });
      activityFeedRef
          .doc(highestBidderData.id)
          .collection('feedItems')
          .doc(productItemsInit.productId)
          .set({
        "type": "bidWin",
        "commentData": "pay before $submissionTime !!",
        "userName": highestBidderData.userName,
        "userId": highestBidderData.id,
        "userProfileImg": highestBidderData.photoUrl,
        "ownerId": productItemsInit.ownerId,
        "mediaUrl": productItemsInit.mediaUrl[0],
        "timestamp": timestamp,
        "productId": productItemsInit.productId,
      });
      sendAndRetrieveMessage(
          message: "pay before $submissionTime to claim your product!!",
          title: "${highestBidderData.userName} Congratulations on Winning",
          token: highestBidderData.androidNotificationToken);
      sendMail(
          recipientEmail: highestBidderData.email,
          text:
              "Dear ${highestBidderData.userName},\n We Congratulate you on winning ${productItemsInit.productName} at the auction that ended ${productItemsInit.auctionEndTime}\n. But it is not over yet You have to now pay for it before $submissionTime, so We can deliver it to you ASAP.\nRegards\nKannapy.co",
          subject: "Kannapy Auction Win");
      auctionTimelineRef.doc(productItemsInit.productId).update({
        "hasSentWinnerNotification": true,
      });
      allBiddersGlobal.forEach((e) {
        if (e.bidderId != highestBidderData.id) {
          activityFeedRef
              .doc(e.bidderId)
              .collection('feedItems')
              .doc(e.productId)
              .set({
            "type": "bidWinFail",
            "commentData":
                "Sorry You couldn't won the Auction.Better Luck Next Time",
            "userName": e.biddersName,
            "userId": e.bidderId,
            "userProfileImg": e.photoUrl,
            "ownerId": productItemsInit.ownerId,
            "mediaUrl": productItemsInit.mediaUrl[0],
            "timestamp": timestamp,
            "productId": e.productId,
          });
          sendMail(
              recipientEmail: e.email,
              text:
                  "Dear ${e.biddersName},\n Hope You are in good health. We would like to inform you that you couldn't win the Auction Bidding of ${productItemsInit.productName}. Better luck next Time. :) \nRegards\nKannapy.co",
              subject: "Kannapy Auction Bid Fail");
        }
      });
    }
  }

  getHighestBidder(
      {ProductItems productItemsInit, @required var varRef}) async {
    DocumentSnapshot snapshot = await varRef.doc(widget.productId).get();
    productItemsInit = ProductItems.fromDocument(snapshot);
    print(productItemsInit.bids);
    if (productItemsInit.bids != null && !productItemsInit.bids.isEmpty) {
      biddersMap = productItemsInit.bids;
      biddersBids = biddersMap.values.toList();
      bidsMapArrByPrices = Map.fromEntries(
          biddersMap.entries.map((e) => MapEntry(e.value, e.key)));
      highestBid = biddersBids
          .reduce((value, element) => value > element ? value : element);
      highestBidder = bidsMapArrByPrices[highestBid];
      var userSnapshot = await userRef.doc(highestBidder).get();
      setState(() {
        highestBidderData = AppUser.fromDocument(userSnapshot);
      });
    }
    checkTime(productItemsInit);
  }

  void deleteProduct(List mediaUrl) async {
    productRef
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
      // auctionVaultTimelineRef.doc(widget.productId).get().then((doc) {
      //   if (doc.exists) {
      //     doc.reference.delete();
      //   }
      // });
      seedVaultTimelineRef.doc(widget.productId).get().then((doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      });
    });
    for (int i = 0; i < mediaUrl.length; i++) {
      storageRef
          .child(
              "products_${widget.productItems.type}/$i-${widget.productItems}.jpg")
          .delete();
    }
    (await reviewRef.doc(widget.productId).collection('reviews').get())
        .docs
        .forEach((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    BotToast.showText(text: "Product Deleted Please Refresh");
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Kannapy auction",
          style: TextStyle(
              color: Theme.of(context).appBarTheme.textTheme.headline1.color),
        ),
        actions: [
          isAdmin
              ? IconButton(
                  icon: Icon(Icons.more_vert),
                  onPressed: () => handleOptionProduct(context,
                      widget.productItems.mediaUrl, widget.productItems))
              : Text(""),
        ],
      ),
      body: buildAuctionProduct(),
      bottomSheet: stopBidding
          ? Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0),
              )),
              height: 70.0,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Session has closed',
                      style: TextStyle(
                          fontSize: 25.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ],
                ),
              ),
            )
          : GestureDetector(
              onTap: () => stopBidding
                  ? BotToast.showText(text: 'Bidding has been closed!')
                  : handleBidPlaced(context),
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  topRight: Radius.circular(20.0),
                )),
                height: 70.0,
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.monetization_on,
                        size: 40.0,
                        color: Colors.white,
                      ),
                      Text(
                        ' Place Your Bid',
                        style: TextStyle(
                            fontSize: 25.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  buildAuctionProduct() {
    return StreamBuilder(
        stream: _varRef.doc(widget.productId).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return bouncingGridProgress();
          }
          ProductItems productItems = ProductItems.fromDocument(snapshot.data);
          biddersIds = widget.productItems.bids.keys.toList();
          biddersMap = widget.productItems.bids;
          biddersBids = widget.productItems.bids.values.toList();

          var t =
              productItems.auctionEndTime.toDate().difference(DateTime.now());
          var bidStopTime = t.inSeconds - 1200;
          print(highestBidderData);
          Countdown(
            seconds: bidStopTime,
            build: (context, double bidTime) {
              return Text("");
            },
            onFinished: () {
              stopBidding = true;
            },
          );
          return Center(
            child: ListView(
              shrinkWrap: true,
              physics: BouncingScrollPhysics(),
              children: <Widget>[
                Container(
                  child: productItems,
                ),
                Card(
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20.0))),
                  color: Colors.black,
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: Column(
                      children: [
                        closeClock
                            ? Text('')
                            : Padding(
                                padding: EdgeInsets.all(12.0),
                                child: SlideCountdownClock(
                                  duration: Duration(seconds: t.inSeconds),
                                  slideDirection: SlideDirection.Up,
                                  separator: "-",
                                  textStyle: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                  separatorTextStyle: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle),
                                  onDone: () {
                                    getHighestBidder(
                                        productItemsInit: productItems,
                                        varRef: _varRef);
                                  },
                                  shouldShowDays: true,
                                ),
                              ),
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: productItems.auctionEndTime
                                  .toDate()
                                  .isBefore(timestamp)
                              ? Text(
                                  "Finished: ${timeago.format(
                                    productItems.auctionEndTime.toDate(),
                                    allowFromNow: true,
                                  )}",
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontSize: 30.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                )
                              : Text(
                                  "Time Left: ${timeago.format(
                                    productItems.auctionEndTime.toDate(),
                                    allowFromNow: true,
                                  )}",
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold),
                                ),
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                highestBidderData == null || stopBidding == false
                    ? Text("")
                    : Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        color: Colors.red,
                        elevation: 10,
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.8,
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              children: [
                                Text(
                                  'Congratulations to ${highestBidderData.userName} for winning',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15.0),
                                ),
                                SizedBox(
                                  height: 15.0,
                                ),
                                ListTile(
                                  leading: CircleAvatar(
                                    backgroundImage: CachedNetworkImageProvider(
                                        highestBidderData.photoUrl),
                                    backgroundColor: Colors.grey,
                                  ),
                                  title: Text(
                                    highestBidderData.userName,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  trailing: Text("Bid : £$highestBid"),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                SizedBox(
                  height: 15.0,
                ),
                Container(
                  child: Column(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(20.0),
                              topLeft: Radius.circular(20.0),
                            )),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                            child: Text(
                              "All Bidders:${allBiddersGlobal.length}",
                              style: TextStyle(
                                  fontSize: 20.0, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                      buildBidders(),
                    ],
                  ),
                ),
                Container(
                  height: 70.0,
                ),
              ],
            ),
          );
        });
  }

  buildBidders() {
    return StreamBuilder(
      stream:
          biddersRef.doc(widget.productId).collection("allBidders").snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return bouncingGridProgress();
        }
        List<Bidders> allBidders = [];
        snapshot.data.docs.forEach((e) {
          allBidders.add(Bidders.fromDocument(e));
        });
        allBiddersGlobal = allBidders;
        return ListView.builder(
            controller: _biddersController,
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            itemBuilder: (BuildContext context, index) {
              return ListTile(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0)),
                leading: CircleAvatar(
                  backgroundImage:
                      CachedNetworkImageProvider(allBidders[index].photoUrl),
                  backgroundColor: Colors.grey,
                ),
                title: Text(
                  allBidders[index].biddersName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: Text("Bid : £${allBidders[index].bidPrice}"),
              );
            },
            itemCount: allBidders.length);
      },
    );
  }

  registerBid() {
    // var varRef = widget.isVault ? auctionVaultTimelineRef : auctionTimelineRef;
    var varRef = auctionTimelineRef;
    varRef
        .doc(widget.productId)
        .update({"bids.${currentUser.id}": double.parse(bidController.text)});
    biddersRef
        .doc(widget.productId)
        .collection("allBidders")
        .doc(currentUser.id)
        .set({
      "bidderId": currentUser.id,
      "productId": widget.productId,
      "biddersName": currentUser.userName,
      "biddersDisplayName": currentUser.displayName,
      "bidPrice": bidController.text,
      "email": currentUser.email,
      "timestamp": timestamp,
      "hasWon": false,
      "photoUrl": currentUser.photoUrl,
      "androidNotificationToken": currentUser.androidNotificationToken,
    });
    allBiddersGlobal.forEach((e) {
      if (e.bidderId != currentUser.id) {
        activityFeedRef.doc(e.bidderId).collection('feedItems').add({
          "type": "othersBid",
          "commentData": "Another person placed the bid",
          "userName": currentUser.userName,
          "userId": currentUser.id,
          "userProfileImg": currentUser.photoUrl,
          "productOwnerId": widget.productItems.ownerId,
          "mediaUrl": widget.productItems.mediaUrl[0],
          "timestamp": timestamp,
          "rating": "",
          "productId": productItemsInit.productId,
          "price": bidController.text,
        });
        var priceDiff =
            double.parse(bidController.text) - double.parse(e.bidPrice);
        sendAndRetrieveMessage(
            token: e.androidNotificationToken,
            title: "Auction House Bid Placed",
            message:
                "${currentUser.userName} has placed the $priceDiff higher bid than you");
      }
    });
    BotToast.showText(text: "Bid Placed");
  }

  handleBidPlaced(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: Center(child: Text("IMPORTANT INFORMATION")),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0)),
            //backgroundColor: Colors.black,
            elevation: 20.0,
            titlePadding: EdgeInsets.all(10.0),
            contentPadding: EdgeInsets.all(10.0),
            children: [
              Text(
                  "Warning Germination of Cannabis seeds is illegal in most countries.\n\nPlease note: You have to be at least 18 years old to order cannabis seeds from KANNAPY.\n\nBy section 6 of the Misuse of Drugs Act 1971 it is an offence to cultivate any plant of the genus Cannabis in the United Kingdom without a license from the Secretary of State. Anyone committing an offence contrary to this section may be imprisoned of fined, or both. Please note therefore that germination of cannabis seeds without an appropriate license is illegal in the United Kingdom.\n\nKANNAPY does not encourage anyone to break the law in their country.\n\nKANNAPY cannot be held responsible for the actions of persons who purchase our Cannabis seeds. KANNAPY can sell you cannabis seeds legally for the use of fishing bait additives or as adult souvenirs, or you may purchase to collect and store, incase the law changes.\n\nInternational Warning!\n\nWe dispatch our seeds on the condition that they will not be used by others in conflict with applicable local law. Unfortunately, regulation and implementation in respect of Cannabis seeds often differ from country to country. For this reason we advise you as a matter of urgency to make inquiries about the regulations to which you are subject. It is your responsibility to check with your local laws. As a KANNAPY company customer, you are prohibited from distributing seeds bought from KANNAPY to countries where possession of and/or trafficking in Cannabis seeds is illegal. This site is intended for those persons 18 years of age and older.\n\nFor your own protection we 'require' you to inquire about and comply with all local laws and international laws governing the purchase of marijuana seeds/cannabis seeds in your part of the world. In many countries, it is illegal to germinate these cannabis seeds. By ordering, 'you confirm that you checked your local and international law and it is safe to do so' and that the responsibility for that decision rests solely upon you.\n\nAll cannabis seeds / marijuana seeds are for sold educational and Souvenir purposes only."),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RaisedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("Cancel"),
                  ),
                  RaisedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      return biddingDialog(productItemsInit);
                    },
                    child: Text("Accept"),
                  ),
                ],
              ),
            ],
          );
        });
  }

  biddingDialog(ProductItems productItems) {
    return showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: Text("Enter the Amount for bidding"),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          titlePadding: EdgeInsets.all(8.0),
          contentPadding: EdgeInsets.all(8.0),
          children: [
            TextField(
              // onSaved: (val) => bidController.text = val,
              // validator: (val) {
              //   if (val.trim().isEmpty) {
              //     return "Bids can't be left empty";
              //   } else if (double.parse(val) < 1 ||
              //       double.parse(val) - 1 <
              //           biddersBids.reduce((value, element) =>
              //               value > element ? value : element)) {
              //     return "Your Bid must be Greater than present Bids";
              //   } else {
              //     return null;
              //   }
              // },
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Enter your Bid",
                hintText: "Must be greater than the current bids",
              ),
              keyboardType: TextInputType.number,
              controller: bidController,
            ),
            RaisedButton.icon(
                onPressed: () {
                  if (biddersBids.isNotEmpty) {}
                  if (bidController.text.trim().isEmpty) {
                    BotToast.showText(
                        text: "Bids can't be left empty",
                        align: Alignment.center);
                  } else if (double.parse(bidController.text) < 1) {
                    BotToast.showText(
                        text: "Place a valid Bid", align: Alignment.center);
                  } else if (biddersBids.isNotEmpty &&
                      double.parse(bidController.text) - 1 <
                          biddersBids.reduce((value, element) =>
                              value > element ? value : element)) {
                    BotToast.showText(
                        text: "Your Bid must be Greater than present Bids",
                        align: Alignment.center);
                  }
                  if (bidController.text.isNotEmpty) {
                    setState(() {
                      registerBid();
                    });
                    bidController.clear();
                    Navigator.of(context).pop();
                    getHighestBidder(
                        productItemsInit: productItems, varRef: _varRef);
                    BotToast.showText(text: "Bid successfully Added");
                  }

                  // else {
                  //   setState(() {
                  //     registerBid();
                  //   });
                  //   bidController.clear();
                  //   Navigator.of(context).pop();
                  //   BotToast.showText(
                  //       text: "Bid Successfully Added!",
                  //       duration: Duration(
                  //         seconds: 2,
                  //       ));
                  // }
                },
                icon: Icon(Icons.credit_card),
                label: Text("Bid")),
          ],
        );
      },
    );
  }

  timer(ProductItems productItems, DateTime t) {
    Countdown(
        seconds: t.second,
        onFinished: () async {
          getHighestBidder(productItemsInit: productItems, varRef: _varRef);
        },
        build: (context, double time) {
          if (time <= 1200) {
            stopBidding = true;
          }
          return productItems.auctionEndTime.toDate().isBefore(timestamp)
              ? Text('')
              : Text(
                  "${time.toInt().toString()} seconds left",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
                );
        });
  }
}
