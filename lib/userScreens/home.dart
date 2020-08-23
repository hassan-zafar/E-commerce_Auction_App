import 'dart:math';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:kannapy/models/users.dart';
import 'package:kannapy/userScreens/createAccount.dart';
import 'package:kannapy/userScreens/timeline.dart';
import 'package:kannapy/userScreens/userProfile.dart';
import 'package:shimmer/shimmer.dart';
import 'auction.dart';
import 'kannapyStore.dart';

final GoogleSignIn googleSignIn = GoogleSignIn();
final userRef = Firestore.instance.collection('users');
final cardRef = Firestore.instance.collection('card');
final postsRef = Firestore.instance.collection('posts');
final productRef = Firestore.instance.collection('products');
final auctionTimelineRef = Firestore.instance.collection('auctionTimeline');
final commentsRef = Firestore.instance.collection('comments');
final favouritesRef = Firestore.instance.collection('favourites');
final cartRef = Firestore.instance.collection('cart');
final storeTimelineRef = Firestore.instance.collection('storeTimeline');
final activityFeedRef = Firestore.instance.collection('activityFeed');
final timelineRef = Firestore.instance.collection('timeline');
final auctionBidsRef = Firestore.instance.collection('auctionBids');
final DateTime timestamp = DateTime.now();
final StorageReference storageRef = FirebaseStorage.instance.ref();
User currentUser;
bool isAuctionItem = false;
bool isAdmin = false;
User kannapyAdmin;
String deliveryAddress = "";

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  bool isAuth = false;
  PageController pageController;
  int pageIndex = 0;

  @override
  void initState() {
    super.initState();
    pageController = PageController();
    //Detects when user
    //SignedIn
    googleSignIn.onCurrentUserChanged.listen((account) {
      handleSignIn(account);
    }, onError: (err) {
      // print('User SignIn Error:$err');
    });
//ReAuthenticate User when app is opened
    googleSignIn.signInSilently(suppressErrors: false).then((account) {
      handleSignIn(account);
    }).catchError((err) {
      // print('User SignIn Error:$err');
    });
    login(context);
  }

  handleSignIn(GoogleSignInAccount account) async {
    if (account != null) {
      await createUserInFirestore();
      setState(() {
        isAuth = true;
      });
      // configurePushNotifications();
    } else {
      setState(() {
        isAuth = false;
      });
    }
  }

  createUserInFirestore() async {
    final GoogleSignInAccount user = googleSignIn.currentUser;
    DocumentSnapshot doc = await userRef.document(user.id).get();
    if (!doc.exists) {
      final userName = await Navigator.push(
          context, MaterialPageRoute(builder: (context) => CreateAccount()));
      userRef.document(user.id).setData({
        "id": user.id,
        "userName": userName,
        "bio": "",
        "photoUrl": user.photoUrl,
        "displayName": user.displayName,
        "timestamp": timestamp,
        "type": "user",
      });
      //make new users their own followers(to include their posts in their timeline)
//      await followersRef
//          .document(user.id)
//          .collection('userFollowers')
//          .document(user.id)
//          .setData({});

      doc = await userRef.document(user.id).get();
    }
    currentUser = User.fromDocument(doc);
    print("current user id home" + currentUser.id);
    print("current user id home" + currentUser.photoUrl);
    //User cUser = userRef.d
    //print("current user photo url home" + cUser.displayName);
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  login(BuildContext parentContext) {
    googleSignIn.signIn().catchError((onError) {
      showDialog(
          context: parentContext,
          builder: (context) {
            return SimpleDialog(
              title: Text("Can't connect to Google servers.Please try again"),
              children: [
                RaisedButton(
                  onPressed: () => login(context),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0)),
                  child: Text('Retry'),
                ),
              ],
            );
          });
    });
  }

  logout() {
    googleSignIn.signOut();
    // print('Signed out!');
  }

  onPageChanged(int pageIndex) {
    setState(() {
      this.pageIndex = pageIndex;
    });
  }

  onTap(int pageIndex) {
    pageController.animateToPage(
      pageIndex,
      duration: Duration(milliseconds: 150),
      curve: Curves.easeInOut,
    );
  }

  Scaffold buildAuthScreen() {
    return Scaffold(
      key: _scaffoldKey,
      body: PageView(
        children: <Widget>[
          KannapyStore(currentUserinStore: currentUser),
          KannapyAuction(),
          Timeline(
            currentUser: currentUser,
          ),
          Profile(
            profileId: currentUser?.id,
          ),
        ],
        controller: pageController,
        onPageChanged: onPageChanged,
        physics: NeverScrollableScrollPhysics(),
      ),
//      drawer: FutureBuilder<Object>(
//          future: userRef.document(currentUser.id).get(),
//          builder: (context, snapshot) {
//            if (!snapshot.hasData) {
//              return circularProgress();
//            }
//            User drawerUser = User.fromDocument(snapshot.data);
//            return Drawer(
//              child: Column(
//                children: <Widget>[
//                  UserAccountsDrawerHeader(
//                    accountName: Text(drawerUser.displayName),
//                    accountEmail: Text(drawerUser.email),
//                    currentAccountPicture: CircleAvatar(
//                      backgroundImage:
//                          CachedNetworkImageProvider(drawerUser.photoUrl),
//                    ),
//                  ),
//                ],
//              ),
//            );
//          }),
      bottomNavigationBar: CupertinoTabBar(
        currentIndex: pageIndex,
        onTap: onTap,
        //backgroundColor: Theme.of(context).primaryColor,
        activeColor: Colors.white,
        inactiveColor: Theme.of(context).accentColor,
        backgroundColor: Theme.of(context).primaryColor,
        items: [
          BottomNavigationBarItem(
              icon: Icon(
            Icons.local_grocery_store,
          )),
          BottomNavigationBarItem(
            icon: Icon(Icons.offline_bolt),
          ),
          BottomNavigationBarItem(
              icon: Icon(
            Icons.whatshot,
          )),
          BottomNavigationBarItem(
              icon: Icon(
            Icons.person,
          )),
        ],
      ),
    );
  }

  Scaffold buildUnAuthScreen() {
    return Scaffold(
      body: Center(
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            image: DecorationImage(
              image: AssetImage('assets/images/kannapyLogo.png'),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return isAuth ? buildAuthScreen() : buildUnAuthScreen();
  }
}

class TilesInDrawer extends StatelessWidget {
  final onTap;
  final IconData icon;
  final String text;
  TilesInDrawer({this.onTap, this.icon, this.text});
  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).primaryColor,
        child: Icon(
          icon,
          color: Theme.of(context).accentColor,
        ),
      ),
      title: Text(text),
    );
  }
}
