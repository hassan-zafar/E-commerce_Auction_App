import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kannapy/adminScreens/adminHome.dart';
import 'package:kannapy/models/users.dart';
import 'package:kannapy/tools/productItems.dart';
import 'package:kannapy/tools/productItemsTile.dart';
import 'package:kannapy/tools/progress.dart';
import 'package:kannapy/userScreens/favourites.dart';
import 'package:kannapy/userScreens/messages.dart';
import 'package:kannapy/userScreens/cart.dart';
import 'package:kannapy/userScreens/home.dart';

int cartCount = 0;
bool isCart = false;
bool isFavourite = false;

class KannapyStore extends StatefulWidget {
  final User currentUserinStore;
  KannapyStore({this.currentUserinStore});
  @override
  _KannapyStoreState createState() => _KannapyStoreState();
}

class _KannapyStoreState extends State<KannapyStore> {
  final String currentUserID = currentUser?.id;
  int productCount = 0;
  bool isLoading = false;
  List<ProductItems> productItems = [];

  checkAdmin() {
    if (currentUser.type == "admin") {
      setState(() {
        kannapyAdmin = currentUser;
        isAdmin = true;
      });
    }
  }

  getcartCount() async {
    QuerySnapshot snapShot = await cartRef
        .document(currentUser.id)
        .collection("cartItems")
        .getDocuments();
    setState(() {
      if (snapShot.documents != null) {
        cartCount = snapShot.documents.length;
      } else {
        cartCount = 0;
      }
    });
  }

  @override
  void initState() {
    print('store current user id' + currentUserID);
    checkAdmin();
    getcartCount();
    getProductItems();
    super.initState();
  }

  getProductItems() async {
    setState(() {
      isLoading = true;
    });
    QuerySnapshot snapshot = await storeTimelineRef
        .orderBy('timestamp', descending: false)
        .getDocuments();
    setState(() {
      isLoading = false;
      productCount = snapshot.documents.length;
      productItems = snapshot.documents
          .map((doc) => ProductItems.fromDocument(doc))
          .toList();
    });
  }

  buildProductItems() {
    if (isLoading) {
      return bouncingGridProgress();
    } else if (productItems.isEmpty) {
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
    productItems.forEach((productItems) {
      gridTiles.add(GridTile(child: ProductItemsTile(productItems)));
    });
    return GridView.count(
      crossAxisCount: 2,
      childAspectRatio: 1,
      physics: NeverScrollableScrollPhysics(),
      mainAxisSpacing: 1.5,
      crossAxisSpacing: 1.5,
      shrinkWrap: true,
      children: gridTiles,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: GestureDetector(
            onLongPress: isAdmin
                ? () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) =>
                            AdminHome(currentUser: currentUser)));
                  }
                : () {},
            child: Text('Kannapy Store')),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
              icon: Icon(
                Icons.favorite,
                color: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  isFavourite = true;
                  isCart = false;
                });
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => KannapyFavourites(
                          userId: currentUser.id,
                        )));
              }),
          Stack(
            //alignment: Alignment.topLeft,
            children: <Widget>[
              IconButton(
                  //alignment: Alignment.center,
                  icon: Icon(
                    Icons.chat,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => KannapyMessages()));
                  }),
              CircleAvatar(
                backgroundColor: Colors.red,
                radius: 8.0,
                child: Text(
                  '0',
                  style: TextStyle(color: Colors.white, fontSize: 12.0),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Flexible(
              child: buildProductItems(),
            )
          ],
        ),
      ),
      floatingActionButton: Stack(
        children: <Widget>[
          FloatingActionButton(
            backgroundColor: Theme.of(context).primaryColor,
            onPressed: () {
              setState(() {
                isCart = true;
                isFavourite = false;
              });
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => KannapyCart(
                        userId: currentUser?.id,
                        //productItems: productItems,
                      )));
            },
            child: Icon(
              Icons.shopping_cart,
              color: Theme.of(context).accentColor,
            ),
          ),
          CircleAvatar(
            radius: 10.0,
            child: Text(
              "$cartCount",
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        ],
      ),
    );
  }
}
