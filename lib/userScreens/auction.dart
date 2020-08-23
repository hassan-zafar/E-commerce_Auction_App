import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kannapy/tools/auctionItemCard.dart';
import 'package:kannapy/tools/productItems.dart';
import 'package:kannapy/tools/progress.dart';
import 'package:kannapy/userScreens/home.dart';

class KannapyAuction extends StatefulWidget {
  final ProductItems productItems;
  KannapyAuction({this.productItems});
  @override
  _KannapyAuctionState createState() => _KannapyAuctionState();
}

class _KannapyAuctionState extends State<KannapyAuction> {
  bool isLoading = false;
  int auctionItemCount = 0;

  List<ProductItems> auctionItems = [];
  @override
  void initState() {
    getAuctionItems();
    super.initState();
  }

  getAuctionItems() async {
    setState(() {
      isLoading = true;
    });
    QuerySnapshot snapshot = await auctionTimelineRef
        .orderBy('timestamp', descending: false)
        .getDocuments();
    setState(() {
      isLoading = false;
      auctionItemCount = snapshot.documents.length;
      auctionItems = snapshot.documents
          .map((doc) => ProductItems.fromDocument(doc))
          .toList();
    });
  }

  buildAuctionItems() {
    if (isLoading) {
      return bouncingGridProgress();
    } else if (auctionItems.isEmpty) {
      return Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 20.0),
              child: Text(
                "No Products",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.redAccent,
                  fontSize: 40.0,
                ),
              ),
            ),
          ],
        ),
      );
    }
    List<GridTile> gridTiles = [];
    auctionItems.forEach((productItems) {
      gridTiles.add(GridTile(
          child: AuctionItemCard(
        productItemsAuction: productItems,
      )));
    });
    return GridView.count(
      crossAxisCount: 1,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      children: gridTiles,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kannapy Auction'),
      ),
      body: buildAuctionItems(),
    );
  }
}
