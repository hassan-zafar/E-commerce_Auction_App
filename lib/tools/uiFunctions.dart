import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:kannapy/tools/VaultItemTile.dart';
import 'package:kannapy/tools/auctionItemTile.dart';
import 'package:kannapy/tools/progress.dart';
import 'package:kannapy/tools/storeItemTile.dart';
import 'package:kannapy/userScreens/home.dart';

import 'productItems.dart';

neumorphicTile({
  Widget anyWidget,
  double padding = 8,
  bool circular = true,
}) {
  return Neumorphic(
    padding: EdgeInsets.all(padding),
    style: NeumorphicStyle(
        shape: NeumorphicShape.concave,
        boxShape: circular
            ? NeumorphicBoxShape.roundRect(BorderRadius.circular(20))
            : NeumorphicBoxShape.rect(),
        depth: 4,
        surfaceIntensity: 0.2,
        intensity: 1,
        //oppositeShadowLightSource: true,
        lightSource: LightSource.topLeft,
        color: Colors.white),
    child: anyWidget,
  );
}

handleCode(String code, DateTime expiryDate) async {
  await codesRef.doc(code).set({"code": code, "expiryDate": expiryDate}).then(
      (value) => BotToast.showText(text: "Code Added Successfully"));
}

buildProductItemsStream({
  @required varRef,
  @required var varProductItemsLive,
  @required var varProductItemsUpcoming,
  bool isLoading,
  @required bool isLive,
  @required BuildContext context,
}) {
  return StreamBuilder(
      stream: varRef.orderBy('timestamp', descending: true).snapshots(),
      builder: (context, snapshots) {
        if (!snapshots.hasData) {
          return bouncingGridProgress();
        }
        var varProductItems =
            isLive ? varProductItemsLive : varProductItemsUpcoming;
        isLive
            ? snapshots.data.docs.forEach((doc) {
                if (!doc.data().containsKey("liveSaleDate") ||
                    doc
                        .data()["liveSaleDate"]
                        .toDate()
                        .isBefore(DateTime.now())) {
                  if (!varProductItemsLive
                      .contains(ProductItems.fromDocument(doc))) {
                    varProductItemsLive.add(ProductItems.fromDocument(doc));
                  }
                }
              })
            : snapshots.data.docs.forEach((doc) {
                if (!isLive &&
                    doc.data()["liveSaleDate"] != null &&
                    doc
                        .data()["liveSaleDate"]
                        .toDate()
                        .isAfter(DateTime.now())) {
                  if (!varProductItemsUpcoming
                      .contains(ProductItems.fromDocument(doc))) {
                    varProductItemsUpcoming.add(ProductItems.fromDocument(doc));
                  }
                }
              });

        if (snapshots.hasData && varProductItems.isEmpty) {
          return Container(
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                isLive ? liveUpcoming() : upcomingLive(),
                Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 140.0),
                    child: Text(
                      "No Products",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.redAccent,
                        fontSize: 40.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        List<GridTile> gridTiles = [];
        varProductItems.forEach((productItems) {
          gridTiles.add(GridTile(
            child: ProductItemsTile(
              productItems: productItems,
              isLive: isLive,
              varRef: varRef,
            ),
          ));
        });
        varProductItems.clear();
        varProductItemsLive.clear();
        varProductItemsUpcoming.clear();
        return ListView(
          children: [
            isLive ? liveUpcoming() : upcomingLive(),
            gridViewWidgetStore(gridTiles: gridTiles),
          ],
        );
      });
}

buildStoreItemsLiveUpcoming({
  @required List<ProductItems> varProductItems,
  bool isLoading,
  @required bool isLive,
  @required BuildContext context,
}) {
  if (isLoading) {
    return bouncingGridProgress();
  } else if (varProductItems.isEmpty) {
    return Container(
      child: Column(
        // mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          isLive ? liveUpcoming() : upcomingLive(),
          Center(
            child: Padding(
              padding: EdgeInsets.only(top: 140.0),
              child: Center(
                child: Text(
                  "No Products",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent,
                    fontSize: 40.0,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  List<GridTile> gridTiles = [];
  varProductItems.forEach((productItems) {
    if (productItems.type == "storeItem") {
      gridTiles.add(GridTile(
          child: ProductItemsTile(
        productItems: productItems,
        isLive: isLive,
        varRef: productItems.type,
      )));
    } else if (productItems.type == "vaultItem") {
      gridTiles.add(
        GridTile(
          child: VaultItemTile(
            productItems: productItems,
          ),
        ),
      );
    }
  });
  return ListView(
    children: [
      isLive ? liveUpcoming() : upcomingLive(),
      gridViewWidgetStore(gridTiles: gridTiles),
    ],
  );
}

buildAuctionLiveUpcoming({
  @required List<ProductItems> varAuctionItems,
  bool isLoading,
  @required bool isLive,
  @required bool isVault,
  @required BuildContext context,
}) {
  if (isLoading) {
    return bouncingGridProgress();
  } else if (varAuctionItems.isEmpty) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          isLive ? liveUpcoming() : upcomingLive(),
          Center(
            child: Padding(
              padding: EdgeInsets.only(top: 140.0),
              child: Center(
                child: Text(
                  "No Products",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent,
                    fontSize: 40.0,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  print(varAuctionItems.length);

  List gridTilesAuction = [];
  varAuctionItems.toSet().forEach((productItems) {
    gridTilesAuction.add(GridTile(
        child: AuctionItemTile(
      productItemsAuction: productItems,
      isVault: isVault,
    )));
  });
  return ListView(
    children: [
      isLive ? liveUpcoming() : upcomingLive(),
      ListView(children: gridTilesAuction,)
      //gridViewWidgetAuction(gridTiles: gridTilesAuction)
    ],
  );
}

buildAuctionLiveUpcomingStream({
  @required varRef,
  @required List<ProductItems> varAuctionItemsLive,
  @required List<ProductItems> varAuctionItemsUpcoming,
  bool isLoading,
  @required bool isVault,
  @required bool isLive,
  @required BuildContext context,
}) {
  return StreamBuilder(
      stream: varRef.orderBy('timestamp', descending: true).snapshots(),
      builder: (context, snapshots) {
        if (!snapshots.hasData) {
          return bouncingGridProgress();
        }
        var varProductItems =
            isLive ? varAuctionItemsLive : varAuctionItemsUpcoming;
        isLive
            ? snapshots.data.docs.forEach((doc) {
                if (!doc.data().containsKey("liveSaleDate") ||
                    doc
                        .data()["liveSaleDate"]
                        .toDate()
                        .isBefore(DateTime.now())) {
                  if (!varAuctionItemsLive
                      .contains(ProductItems.fromDocument(doc))) {
                    varAuctionItemsLive.add(ProductItems.fromDocument(doc));
                  }
                }
              })
            : snapshots.data.docs.forEach((doc) {
                if (!isLive &&
                    doc.data()["liveSaleDate"] != null &&
                    doc
                        .data()["liveSaleDate"]
                        .toDate()
                        .isAfter(DateTime.now())) {
                  if (!varAuctionItemsUpcoming
                      .contains(ProductItems.fromDocument(doc))) {
                    varAuctionItemsUpcoming.add(ProductItems.fromDocument(doc));
                  }
                }
              });
        if (snapshots.hasData && varProductItems.isEmpty) {
          return Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                isLive ? liveUpcoming() : upcomingLive(),
                Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 140.0),
                    child: Text(
                      "No Products",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.redAccent,
                        fontSize: 40.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        List<GridTile> gridTiles = [];
        varProductItems.forEach((productItems) {
          gridTiles.add(GridTile(
            child: AuctionItemTile(
              productItemsAuction: productItems,
              isVault: isVault,
            ),
          ));
        });
        varProductItems.clear();
        varAuctionItemsLive.clear();
        varAuctionItemsUpcoming.clear();
        return ListView(
          children: [
            isLive ? liveUpcoming() : upcomingLive(),
            gridViewWidgetAuction(gridTiles: gridTiles),
          ],
        );
      });
}

gridViewWidgetAuction({var gridTiles}) {
  return GridView.count(
    physics: BouncingScrollPhysics(),
    crossAxisCount: 1,
    mainAxisSpacing: 1.5,
    crossAxisSpacing: 1.5,
    scrollDirection: Axis.vertical,
    shrinkWrap: true,
    children: gridTiles,
  );
}

TextStyle addressTextStyle() {
  return TextStyle(fontSize: 14, fontWeight: FontWeight.w300);
}

TextStyle checkOutTextStyle() {
  return TextStyle(fontSize: 15, fontWeight: FontWeight.w400);
}

gridViewWidgetStore({var gridTiles}) {
  return GridView.count(
    physics: BouncingScrollPhysics(),
    crossAxisCount: 2,
    childAspectRatio: 12 / 16,
    mainAxisSpacing: 1.5,
    scrollDirection: Axis.vertical,
    crossAxisSpacing: 1.5,
    shrinkWrap: true,
    children: gridTiles,
  );
}

cartCheckOut({@required bool isCart}) {
  return Padding(
    padding: const EdgeInsets.all(12.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Cart',
            style: TextStyle(
                fontWeight: isCart ? FontWeight.bold : FontWeight.w100,
                fontSize: 20),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "CheckOut",
            style: TextStyle(
                fontWeight: isCart ? FontWeight.w100 : FontWeight.bold,
                fontSize: 30),
          ),
        ),
      ],
    ),
  );
}

liveUpcoming() {
  return Padding(
    padding: const EdgeInsets.all(12.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Center(
            child: Text(
          "Live",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
        )),
        Text(
          "->Upcoming",
          style: TextStyle(fontWeight: FontWeight.w100, fontSize: 20),
        ),
      ],
    ),
  );
}

upcomingLive() {
  return Padding(
    padding: const EdgeInsets.all(12.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '<-Live',
          style: TextStyle(fontWeight: FontWeight.w100, fontSize: 20),
        ),
        Center(
          child: Text(
            "Upcoming",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
          ),
        ),
      ],
    ),
  );
}
