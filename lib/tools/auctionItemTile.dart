import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:kannapy/models/users.dart';
import 'package:kannapy/tools/productItems.dart';
import 'package:kannapy/tools/progress.dart';
import 'package:kannapy/tools/uiFunctions.dart';
import 'package:kannapy/userScreens/auctionScreen.dart';
import 'package:kannapy/userScreens/home.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:kannapy/models/biddersModel.dart';
import 'package:auto_size_text/auto_size_text.dart';

class AuctionItemTile extends StatefulWidget {
  final ProductItems productItemsAuction;
  final bool isVault;
  AuctionItemTile({this.productItemsAuction, @required this.isVault});
  @override
  _AuctionItemTileState createState() => _AuctionItemTileState();
}

class _AuctionItemTileState extends State<AuctionItemTile> {
  List bidUserIds = [];
  List bidPrices = [];
  Map bidsMap;
  var highestBid;
  String highestBidder;
  Map bidsMapArrByPrices;
  bool bidPlaced = false;
  showItem(context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => AuctionScreen(
                  productId: widget.productItemsAuction.productId,
                  productItems: widget.productItemsAuction,
                  // isVault: widget.isVault,
                )));
  }

  @override
  void initState() {
    getBidData();

    super.initState();
  }

  getBidData() {
    bidPrices = widget.productItemsAuction.bids.values.toList();
    bidUserIds = widget.productItemsAuction.bids.keys.toList();

    if (bidUserIds.isEmpty) {
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
    print(highestBidder);
    print(highestBid);
  }

  @override
  Widget build(BuildContext context) {
    return bidPlaced && highestBidder != null
        ? afterBidPlaced()
        : GestureDetector(
            onTap: () {
              setState(() {
                if (!widget.isVault) {
                  isAuctionMercItem = true;
                  isAuctionVaultItem = false;
                } else {
                  isAuctionVaultItem = true;
                  isAuctionMercItem = false;
                }
              });
              showItem(context);
            },
            child: Padding(
              padding: EdgeInsets.all(12),
              child: neumorphicTile(
                anyWidget: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              widget.productItemsAuction.productName,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            buildAuctionTimer(),
                          ],
                        ),
                      ),
                    ),
                    Image(
                      image: CachedNetworkImageProvider(
                          widget.productItemsAuction.mediaUrl[0]),
                      height: 230,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 32.0),
                      child: Text(
                        "Become the First to place bid",
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
  }

  afterBidPlaced() {
    return StreamBuilder(
        stream: userRef.doc(highestBidder).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return bouncingGridProgress();
          }

          AppUser user = AppUser.fromDocument(snapshot.data);
          return GestureDetector(
            onTap: () {
              setState(() {
                if (!widget.isVault) {
                  isAuctionMercItem = true;
                  isAuctionVaultItem = false;
                } else {
                  isAuctionVaultItem = true;
                  isAuctionMercItem = false;
                }
              });
              showItem(context);
            },
            child: Padding(
              padding: EdgeInsets.all(12),
              child: neumorphicTile(
                padding: 8,
                anyWidget: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              widget.productItemsAuction.productName,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            buildAuctionTimer(),
                          ],
                        ),
                      ),
                    ),
                    Image(
                      image: CachedNetworkImageProvider(
                          widget.productItemsAuction.mediaUrl[0]),
                      height: 230,
                      //width: MediaQuery.of(context).size,
                      fit: BoxFit.contain,
                    ),
                    Container(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: CachedNetworkImageProvider(
                              user != null ? user.photoUrl : null),
                          backgroundColor: Colors.grey,
                        ),
                        title: Text(
                          user != null ? user.userName : null,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          'Highest Bidder',
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: bidPrices != null && bidsMap != null
                            ? Text(
                                "£${bidsMap[highestBidder]}",
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20.0),
                              )
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  buildAuctionTimer() {
    if (widget.productItemsAuction.auctionEndTime
        .toDate()
        .isBefore(timestamp)) {
      return AutoSizeText(
        "Finished: ${timeago.format(
          widget.productItemsAuction.auctionEndTime.toDate(),
          allowFromNow: true,
        )}",
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
      );
    }
    DateTime aucTime = widget.productItemsAuction.auctionEndTime.toDate();
    String days;
    aucTime.day > 0 ? days = aucTime.day.toString() : "";
    return Row(
      children: [
        Text("End Time: "),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${aucTime.hour}h:${aucTime.minute}m on",
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12.0),
            ),
            Text(
              "${aucTime.day}/${aucTime.month}/${aucTime.year}",
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12.0),
            ),
          ],
        ),
      ],
    );
  }
}
