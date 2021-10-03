import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kannapy/adminScreens/adminHome.dart';
import 'package:kannapy/models/users.dart';
import 'package:kannapy/tools/seedVaultItems.dart';
import 'package:kannapy/tools/storeItems.dart';
import 'package:kannapy/userScreens/home.dart';
import 'package:kannapy/userScreens/profileScreens/dashBoard.dart';

int cartCount = 0;
bool isCart = false;
bool isFavourite = false;

class KannapyStore extends StatefulWidget {
  final AppUser currentUserInStore;
  KannapyStore({this.currentUserInStore});
  @override
  _KannapyStoreState createState() => _KannapyStoreState();
}

class _KannapyStoreState extends State<KannapyStore>
    with SingleTickerProviderStateMixin {
  final String currentUserID = currentUser?.id;

  TabController tabBarController;

  bool _disposed = false;

  int notificationCount = 0;

  checkAdmin() {
    if (currentUser.type == "admin") {
      if (!_disposed) {
        setState(() {
          kannapyAdmin = currentUser;
          isAdmin = true;
        });
      }
    }
  }

  checkMerc() {
    if (currentUser.type == "merc") {
      if (!_disposed) {
        setState(() {
          isMerc = true;
        });
      }
    }
  }

  getNotifications() async {
    QuerySnapshot snapshot =
        await activityFeedRef.doc(currentUser.id).collection('feedItems').get();
    setState(() {
      if (snapshot.docs != null) {
        notificationCount = snapshot.docs.length;
      } else {
        notificationCount = 0;
      }
    });
  }

  getCartCount() async {
    QuerySnapshot snapShot =
        await cartRef.doc(currentUser.id).collection("cartItems").get();
    setState(() {
      if (snapShot.docs != null) {
        cartCount = snapShot.docs.length;
      } else {
        cartCount = 0;
      }
    });
  }

  @override
  void initState() {
    tabBarController = TabController(length: 2, vsync: this);
    print('store current user id' + currentUserID);
    checkAdmin();
    checkMerc();
    getCartCount();
    getNotifications();
    super.initState();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: GestureDetector(
          onLongPress: isAdmin || isMerc
              ? () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) =>
                          AdminHome(currentUser: currentUser, isMerc: isMerc)));
                }
              : () {},
          child: Text(
            'KANNAPY STORE',
            style: TextStyle(
                color: Theme.of(context).appBarTheme.textTheme.headline1.color),
          ),
        ),
        bottom: TabBar(
            labelColor:
                Theme.of(context).bottomNavigationBarTheme.selectedItemColor,
            unselectedLabelColor: Colors.grey.shade500,
            controller: tabBarController,
            indicatorColor:
                Theme.of(context).bottomNavigationBarTheme.selectedItemColor,
            tabs: [
              Tab(
                child: Text("SEED VAULT"),
              ),
              Tab(
                child: Text("MERCHANDISE"),
              ),
            ]),
        actions: <Widget>[
          IconButton(
              icon: Icon(
                Icons.person_outline,
                color: Theme.of(context).appBarTheme.textTheme.headline1.color,
              ),
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => Profile(
                        profileId: currentUserID,
                      )))),
        ],
      ),
      body:



          TabBarView(
        controller: tabBarController,
        children: [
          SeedVaultItems(),
          Merchandise(),
        ],
      ),

      // floatingActionButton: Stack(
      //   children: <Widget>[
      //     FloatingActionButton(
      //       backgroundColor: Theme.of(context).primaryColor,
      //       onPressed: () {
      //         setState(() {
      //           isCart = true;
      //           isFavourite = false;
      //         });
      //         Navigator.of(context).push(MaterialPageRoute(
      //             builder: (context) => KannapyCart(
      //                   userId: currentUser?.id,
      //                   //productItems: productItems,
      //                 )));
      //       },
      //       child: Icon(
      //         Icons.shopping_cart,
      //         color: Theme.of(context).accentColor,
      //       ),
      //     ),
      //     CircleAvatar(
      //       radius: 10.0,
      //       child: Text(
      //         "$cartCount",
      //         style: TextStyle(color: Colors.grey.shade400),
      //       ),
      //       backgroundColor: Colors.red,
      //     ),
      //   ],
      // ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
