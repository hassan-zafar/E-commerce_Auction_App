import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kannapy/models/users.dart';
import 'package:kannapy/tools/productItems.dart';
import 'package:kannapy/tools/progress.dart';
import 'package:kannapy/userScreens/auctionScreen.dart';
import 'package:kannapy/userScreens/home.dart';

class AuctionItemCard extends StatefulWidget {
  ProductItems productItemsAuction;
  AuctionItemCard({this.productItemsAuction});
  @override
  _AuctionItemCardState createState() => _AuctionItemCardState();
}

class _AuctionItemCardState extends State<AuctionItemCard> {
  List bidUserids = [];
  List bidPrices = [];
  Map bidsMap;
  var highestBid;
  var highestBidder;
  Map bidsMapArrByPrices;
  bool bidPlaced = false;
  showItem(context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => AuctionScreen(
                  productItem: widget.productItemsAuction,
                )));
  }

  @override
  void initState() {
    bidPrices = widget.productItemsAuction.bids.values.toList();
    bidUserids = widget.productItemsAuction.bids.keys.toList();

    if (bidUserids.isEmpty) {
      setState(() {
        bidPlaced = false;
      });
    } else {
      setState(() {
        bidPlaced = true;
      });
      bidsMap = widget.productItemsAuction.bids;
      bidsMapArrByPrices =
          Map.fromEntries(bidsMap.entries.map((e) => MapEntry(e.value, e.key)));
      highestBid = bidPrices
          .reduce((value, element) => value > element ? value : element);
      highestBidder = bidsMapArrByPrices[highestBid];
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return bidPlaced
        ? afterBidPlaced()
        : GestureDetector(
            onTap: () {
              setState(() {
                isAuctionItem = true;
              });
              showItem(context);
            },
            child: Card(
              child: Stack(
                alignment: FractionalOffset.topLeft,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Stack(
                      alignment: FractionalOffset.bottomCenter,
                      children: <Widget>[
                        Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: CachedNetworkImageProvider(
                                  widget.productItemsAuction.mediaUrl[0]),
                              fit: BoxFit.fitWidth,
                            ),
                          ),
                        ),
                        Container(
                          color: Colors.black38,
                          child: ListTile(
                            title: Text(
                              "Become the First to place bid",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    child: Padding(
                      padding: EdgeInsets.all(6.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            widget.productItemsAuction.productName,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          Text(
                            "Opening Bid: \$${widget.productItemsAuction.price}",
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 15.0),
                          ),
                        ],
                      ),
                    ),
                    color: Colors.black38,
                  ),
                ],
              ),
            ),
          );
  }

  afterBidPlaced() {
    return StreamBuilder<Object>(
        stream: userRef.document(bidsMapArrByPrices[highestBid]).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return bouncingGridProgress();
          }
          User user = User.fromDocument(snapshot.data);
          return GestureDetector(
            onTap: () {
              setState(() {
                isAuctionItem = true;
              });
              showItem(context);
            },
            child: Card(
              child: Stack(
                alignment: FractionalOffset.topLeft,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Stack(
                      alignment: FractionalOffset.bottomCenter,
                      children: <Widget>[
                        Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: CachedNetworkImageProvider(
                                  widget.productItemsAuction.mediaUrl[0]),
                              fit: BoxFit.fitWidth,
                            ),
                          ),
                        ),
                        Container(
                          color: Colors.black38,
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundImage:
                                  CachedNetworkImageProvider(user.photoUrl),
                              backgroundColor: Colors.grey,
                            ),
                            title: Text(
                              user.userName,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text('Highest Bidder'),
                            trailing: bidPrices != null
                                ? Text(
                                    "\$${bidsMap[highestBidder]}",
                                    style: TextStyle(
                                        color: Colors.deepOrange,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20.0),
                                  )
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    child: Padding(
                      padding: EdgeInsets.all(6.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            widget.productItemsAuction.productName,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          Text(
                            "Opening Bid: \$${widget.productItemsAuction.price}",
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 15.0),
                          ),
                        ],
                      ),
                    ),
                    color: Colors.black38,
                  ),
                ],
              ),
            ),
          );
        });
  }

  Widget bitNotPlaced() {
    return GestureDetector(
      onTap: () {
        setState(() {
          isAuctionItem = true;
        });
        showItem(context);
      },
      child: Card(
        child: Stack(
          alignment: FractionalOffset.topLeft,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Stack(
                alignment: FractionalOffset.bottomCenter,
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: CachedNetworkImageProvider(
                            widget.productItemsAuction.mediaUrl[0]),
                        fit: BoxFit.fitWidth,
                      ),
                    ),
                  ),
                  Container(
                    color: Colors.black38,
                    child: ListTile(
                      title: Text(
                        "Become the First to bid",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              child: Padding(
                padding: EdgeInsets.all(6.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      widget.productItemsAuction.productName,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    Text(
                      "Opening Bid: \$${widget.productItemsAuction.price}",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 15.0),
                    ),
                  ],
                ),
              ),
              color: Colors.black38,
            ),
          ],
        ),
      ),
    );
  }
}
