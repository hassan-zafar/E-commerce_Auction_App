import 'package:bot_toast/bot_toast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kannapy/models/fav_cart.dart';
import 'package:kannapy/tools/appData.dart';
import 'package:kannapy/tools/productItems.dart';
import 'package:kannapy/tools/progress.dart';
import 'package:kannapy/userScreens/cart.dart';
import 'package:kannapy/userScreens/home.dart';

class KannapyFavourites extends StatefulWidget {
  final ProductItems productItems;
  final String userId;
  KannapyFavourites({this.userId, this.productItems});
  @override
  _KannapyFavouritesState createState() => _KannapyFavouritesState();
}

class _KannapyFavouritesState extends State<KannapyFavourites> {
  List<FavCart> favList = [];
  @override
  void initState() {
    super.initState();
    getFavItems();
  }

  getFavItems() async {
    QuerySnapshot favSnapshot = await favouritesRef
        .document(widget.userId)
        .collection("favouriteProducts")
        .getDocuments();
    List<FavCart> favList =
        favSnapshot.documents.map((doc) => FavCart.fromDocument(doc)).toList();
    print("fav Snapshot data:" + favList.toString());
    setState(() {
      this.favList = favList;
    });
  }

  buildFavourites() {
    return ListView.separated(
      itemBuilder: (context, index) {
        if (favList == null) {
          return bouncingGridProgress();
        }
        return Dismissible(
          child: ListTile(
            leading: Image(
              image: CachedNetworkImageProvider(favList[index].mediaUrl),
              fit: BoxFit.contain,
            ),
            title: Text(
              favList[index].productName,
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
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
          background: Container(
            alignment: Alignment.centerRight,
            color: Colors.red,
            child: Text('DELETE'),
          ),
          key: UniqueKey(),
          onDismissed: (direction) {
            setState(() {
              favouritesRef
                  .document(currentUser.id)
                  .collection("favouriteProducts")
                  .document(favList[index].productId)
                  .delete();
              favList.removeAt(index);
            });
            BotToast.showText(text: "Deleted To Favourites");
          },
        );
      },
      separatorBuilder: (context, index) {
        return Divider();
      },
      itemCount: favList == null ? 1 : favList.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Favourites'),
      ),
      body: buildFavourites(),
    );
  }
}
