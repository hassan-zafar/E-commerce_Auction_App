import 'package:bot_toast/bot_toast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:kannapy/models/fav_cart.dart';
import 'package:kannapy/tools/productItems.dart';
import 'package:kannapy/tools/progress.dart';
import 'package:kannapy/tools/uiFunctions.dart';
import 'package:kannapy/userScreens/home.dart';
import 'package:kannapy/userScreens/productScreens/productScreen.dart';

class KannapyFavourites extends StatefulWidget {
  final ProductItems productItems;
  final String userId;
  KannapyFavourites({this.userId, this.productItems});
  @override
  _KannapyFavouritesState createState() => _KannapyFavouritesState();
}

class _KannapyFavouritesState extends State<KannapyFavourites> {
  List<FavCart> favList = [];

  bool _isLoading = false;
  @override
  void initState() {
    super.initState();
    getFavItems();
  }

  getFavItems() async {
    _isLoading = true;
    QuerySnapshot favSnapshot = await favouritesRef
        .doc(widget.userId)
        .collection("favouriteProducts")
        .get();
    List<FavCart> favList =
        favSnapshot.docs.map((doc) => FavCart.fromDocument(doc)).toList();
    print("fav Snapshot data:" + favList.toString());
    setState(() {
      this.favList = favList;
      _isLoading = false;
    });
    BotToast.showText(text: "Swipe To Delete");
  }

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
                )));
  }

  buildFavourites() {
    if (_isLoading) {
      return bouncingGridProgress();
    }
    if (favList.isEmpty && !_isLoading) {
      return Center(
        child: Text(
          "Currently No Item in Favourites",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
        ),
      );
    }
    return ListView.separated(
      physics: BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        if (favList == null) {
          return bouncingGridProgress();
        }
        return Dismissible(
          child: GestureDetector(
            onTap: () {
              return showProduct(context, favList[index]);
            },
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0),
              child: neumorphicTile(
                padding: 2,
                anyWidget: ListTile(
                  leading: Image(
                    image: CachedNetworkImageProvider(favList[index].mediaUrl),
                    fit: BoxFit.contain,
                  ),
                  title: Text(
                    favList[index].productName,
                    style:
                        TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                  ),
                  trailing: Text(
                    "Price: \$${favList[index].productPrice.toString()}",
                    style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange),
                  ),
                  subtitle: Text(
                    "x1",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
          background: Container(
            alignment: Alignment.centerRight,
            color: Colors.red,
            child: Text('DELETE'),
          ),
          key: UniqueKey(),
          onDismissed: (direction) {
            seedVaultTimelineRef
                .doc(favList[index].productId)
                .get()
                .then((value) {
              if (value.exists) {
                value.reference.update({"favourites.${currentUser.id}": false});
              }
            });
            storeTimelineRef.doc(favList[index].productId).get().then((value) {
              if (value.exists) {
                value.reference.update({"favourites.${currentUser.id}": false});
              }
            });
            favouritesRef
                .doc(currentUser.id)
                .collection("favouriteProducts")
                .doc(favList[index].productId)
                .delete();
            setState(() {
              favList.removeAt(index);
            });
            BotToast.showText(text: "Deleted From Favourites");
          },
        );
      },
      separatorBuilder: (context, index) {
        return SizedBox(
          height: 10,
        );
      },
      itemCount: favList == null ? 1 : favList.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'My Favourites',
          style: TextStyle(
              color: Theme.of(context).appBarTheme.textTheme.headline1.color),
        ),
      ),
      body: buildFavourites(),
    );
  }
}
