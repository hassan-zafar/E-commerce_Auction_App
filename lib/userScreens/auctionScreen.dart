import 'package:bot_toast/bot_toast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kannapy/models/users.dart';
import 'package:kannapy/tools/app_tools.dart';
import 'package:kannapy/tools/productItems.dart';
import 'package:kannapy/tools/progress.dart';
import 'package:kannapy/userScreens/home.dart';
import 'dart:math';

class AuctionScreen extends StatefulWidget {
  final ProductItems productItem;
  AuctionScreen({
    this.productItem,
  });
  @override
  _AuctionScreenState createState() => _AuctionScreenState();
}

class _AuctionScreenState extends State<AuctionScreen> {
  var biddersIds;
  var biddersMap;
  List biddersBids;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool bidPlaced = false;
  @override
  void initState() {}

  TextEditingController bidController = TextEditingController();
  ScrollController _biddersController = ScrollController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Kannapy auction"),
      ),
      body: FutureBuilder(
          future:
              auctionTimelineRef.document(widget.productItem.productId).get(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return bouncingGridProgress();
            }
            ProductItems productItems =
                ProductItems.fromDocument(snapshot.data);
            biddersIds = productItems.bids.keys.toList();
            biddersMap = productItems.bids;
            biddersBids = productItems.bids.values.toList();
            print(biddersMap);
            return Center(
              child: ListView(
                shrinkWrap: true,
                children: <Widget>[
                  Container(
                    child: productItems,
                  ),
                  Container(
                    color: Colors.black26,
                    child: ListView.separated(
                        controller: _biddersController,
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        itemBuilder: (BuildContext context, index) {
                          return buildBidders(index);
                        },
                        separatorBuilder: (BuildContext context, index) {
                          return Divider();
                        },
                        itemCount: biddersMap.length),
                  ),
                  Container(
                    height: 70.0,
                  ),
                ],
              ),
            );
          }),
      bottomSheet: GestureDetector(
        onTap: () {
          showDialog(
              context: context,
              builder: (context) {
                final _textFormkey = GlobalKey<FormState>();
                return SimpleDialog(
                  title: Text("Enter the Amount for bidding"),
                  shape: RoundedRectangleBorder(),
                  titlePadding: EdgeInsets.all(8.0),
                  contentPadding: EdgeInsets.all(8.0),
                  children: [
                    Form(
                      key: _textFormkey,
                      child: TextFormField(
                        onSaved: (val) => bidController.text = val,
                        validator: (val) => double.parse(val) < 1 ||
                                double.parse(val) - 1 <
                                    biddersBids.reduce((value, element) =>
                                        value > element ? value : element)
                            ? "Your Bid must be Greater than present Bids"
                            : null,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Enter your Bid",
                          hintText: "Must be greater than the current bids",
                        ),
                        keyboardType: TextInputType.number,
                        controller: bidController,
                      ),
                    ),
                    RaisedButton.icon(
                        onPressed: () {
                          final _form = _textFormkey.currentState;
                          if (biddersBids.isNotEmpty) {
                            if (_form.validate()) {
                              setState(() {
                                registerBid();
                                bidPlaced = true;
                              });
                              bidController.clear();
                              Navigator.of(context).pop();
                              BotToast.showText(text: "Bid successfully Added");
                            }
                          } else {
                            setState(() {
                              bidPlaced = true;
                              registerBid();
                            });
                            bidController.clear();
                            Navigator.of(context).pop();
                            BotToast.showText(
                                text: "Bid Successfully Added!",
                                duration: Duration(
                                  seconds: 2,
                                ));
                          }
                        },
                        icon: Icon(Icons.credit_card),
                        label: Text("Bid")),
                  ],
                );
              });
        },
        child: Container(
          decoration: BoxDecoration(
              color: Theme.of(context).accentColor,
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
                  color: Colors.deepOrange,
                ),
                Text(
                  'Place Your Bid',
                  style: TextStyle(fontSize: 35.0, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  buildBidders(int index) {
    return StreamBuilder(
      stream: userRef.document(biddersIds[index]).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return bouncingGridProgress();
        }
        User user = User.fromDocument(snapshot.data);
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(user.photoUrl),
            backgroundColor: Colors.grey,
          ),
          title: Text(
            user.displayName,
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          trailing: Text("Bid :\$${biddersMap[biddersIds[index]]}"),
        );
      },
    );
  }

  registerBid() {
    auctionTimelineRef.document(widget.productItem.productId).updateData(
        {"bids.${currentUser.id}": double.parse(bidController.text)});
  }
}

//class AuctionScreen extends StatelessWidget {
//  final String productId;
//  AuctionScreen({
//    this.productId,
//  });
//  TextEditingController bidController = TextEditingController();
//  @override
//  Widget build(BuildContext context) {
//    return FutureBuilder(
//        future: auctionTimelineRef.document(productId).get(),
//        builder: (context, snapshot) {
//          if (!snapshot.hasData) {
//            return bouncingGridProgress();
//          }
//          ProductItems productItems = ProductItems.fromDocument(snapshot.data);
//          return Center(
//            child: Scaffold(
//              appBar: AppBar(
//                title: Text(productItems.productName),
//              ),
//              body: ListView(
//                children: <Widget>[
//                  Container(
//                    child: productItems,
//                  ),
//                  Card(),
//                ],
//              ),
//              bottomSheet: GestureDetector(
//                onTap: () => showDialog(
//                    context: context,
//                    builder: (context) => SimpleDialog(
//                          title: Text("Enter the Amount for bidding"),
//                          shape: RoundedRectangleBorder(),
//                          titlePadding: EdgeInsets.all(8.0),
//                          contentPadding: EdgeInsets.all(8.0),
//                          children: [
//                            TextField(
//                              keyboardType: TextInputType.number,
//                              controller: bidController,
//                            ),
//                            RaisedButton.icon(
//                                onPressed: () {
//                                  registerBid();
//                                  Navigator.of(context).pop();
//                                },
//                                icon: Icon(Icons.send),
//                                label: Text("Submit"))
//                          ],
//                        )),
//                child: Container(
//                  decoration: BoxDecoration(
//                      borderRadius: BorderRadius.only(
//                    topLeft: Radius.circular(20.0),
//                    topRight: Radius.circular(20.0),
//                  )),
//                  height: 80.0,
//                  child: Center(
//                    child: Row(
//                      mainAxisAlignment: MainAxisAlignment.center,
//                      children: [
//                        Icon(
//                          Icons.monetization_on,
//                          size: 40.0,
//                          color: Colors.deepOrange,
//                        ),
//                        Text(
//                          'Place Your Bid',
//                          style: TextStyle(
//                              fontSize: 30.0, fontWeight: FontWeight.bold),
//                        ),
//                      ],
//                    ),
//                  ),
//                ),
//              ),
//
//            ),
//          );
//        });
//  }
//
//  registerBid() {
//    auctionTimelineRef
//        .document(productId)
//        .updateData({"bids.${currentUser.id}": bidController.text});
//  }
//}
