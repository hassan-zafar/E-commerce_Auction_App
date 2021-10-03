import 'dart:async';
import 'dart:io';
import 'package:bot_toast/bot_toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kannapy/models/addressModel.dart';
import 'package:kannapy/models/users.dart';
import 'package:kannapy/userScreens/cart.dart';
import 'package:kannapy/userScreens/notifications.dart';
import 'package:kannapy/userScreens/timeline.dart';
import 'auction.dart';
import 'loginRelated/codeScreen.dart';
import 'productScreens/kannapyStore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final GoogleSignIn googleSignIn = GoogleSignIn();
final FirebaseAuth auth = FirebaseAuth.instance;

final Reference storageRef = FirebaseStorage.instance.ref();

final userRef = FirebaseFirestore.instance.collection('users');
final cardRef = FirebaseFirestore.instance.collection('card');
final adminOrderHistoryRef =
    FirebaseFirestore.instance.collection('adminOrderHistory');
final postsRef = FirebaseFirestore.instance.collection('posts');
final addressRef = FirebaseFirestore.instance.collection('address');
//Store timeline refs
final productRef = FirebaseFirestore.instance.collection('products');
final auctionTimelineRef =
    FirebaseFirestore.instance.collection('auctionTimeline');
// final auctionVaultTimelineRef =
//     FirebaseFirestore.instance.collection('auctionVaultTimeline');
final storeTimelineRef = FirebaseFirestore.instance.collection('storeTimeline');
final seedVaultTimelineRef =
    FirebaseFirestore.instance.collection('seedVaultTimeline');
final biddersRef = FirebaseFirestore.instance.collection('bidders');
final vendorsRef = FirebaseFirestore.instance.collection('vendors');
final commentsRef = FirebaseFirestore.instance.collection('comments');
final favouritesRef = FirebaseFirestore.instance.collection('favourites');
final mercReqRef = FirebaseFirestore.instance.collection('mercRequests');
final mercSelectedRef = FirebaseFirestore.instance.collection('mercSelected');
final bidWinnersRef = FirebaseFirestore.instance.collection('bidWinners');
final cartRef = FirebaseFirestore.instance.collection('cart');

final activityFeedRef = FirebaseFirestore.instance.collection('activityFeed');
final timelineRef = FirebaseFirestore.instance.collection('timeline');
final auctionBidsRef = FirebaseFirestore.instance.collection('auctionBids');
final reviewRef = FirebaseFirestore.instance.collection('review');
final DateTime timestamp = DateTime.now();
final codesRef = FirebaseFirestore.instance.collection('codes');
final chatRoomRef = FirebaseFirestore.instance.collection('chatRoom');
final chatListRef = FirebaseFirestore.instance.collection('chatLists');

AppUser currentUser;
bool isAuctionMercItem = false;
bool isAuctionVaultItem = false;
bool isStoreItem = false;
bool isVaultItem = false;
bool isAdmin = false;
bool isMerc = false;
AppUser kannapyAdmin;
Address deliveryAddress;
bool isAuth = false;
bool isValidCode = false;
List allCodes = [];
TextEditingController codeController = TextEditingController();
String userName, code;

login(BuildContext parentContext) {
  googleSignIn.signIn().catchError((onError) {
    print(onError);
    isAuth
        // ignore: unnecessary_statements
        ? null
        : showDialog(
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

logout(BuildContext context) async {
  await googleSignIn.signOut();
  Navigator.of(context).popUntil((route) => route.isFirst);
  Navigator.pushReplacement(
      context, MaterialPageRoute(builder: (BuildContext context) => Home()));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

Future<dynamic> myBackgroundHandler(Map<String, dynamic> message) {
  return _HomeState()._showNotification(message);
}

class _HomeState extends State<Home> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  PageController pageController;

  int pageIndex = 0;
  bool isChecked = false;

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  Future _showNotification(Map<String, dynamic> message) async {
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
      'channel id',
      'channel name',
      'channel desc',
      importance: Importance.max,
      priority: Priority.high,
    );

    var platformChannelSpecifics =
        new NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      'new message arrived',
      'i want ${message['data']['title']} for ${message['data']['price']}',
      platformChannelSpecifics,
      payload: 'Default_Sound',
    );
  }

  getTokenz() async {
    String token = await _firebaseMessaging.getToken();
    print(token);
  }

  Future selectNotification(String payload) async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  @override
  void initState() {
    var initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    var initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: selectNotification);
    super.initState();
    googleSignIn.onCurrentUserChanged.listen((account) {
      handleSignIn(account, context);
    }, onError: (err) {
      print('User SignIn Error:$err');
    });
    pageController = PageController();
    //Detects when user
    //SignedIn

    getCodes();

//ReAuthenticate User when app is opened
    googleSignIn.signInSilently(suppressErrors: false).then((account) {
      handleSignIn(account, context);
    }).catchError((err) {
      print('User SignIn Error:$err');
    });
    login(context);
  }

  getCodes() async {
    QuerySnapshot snapshot = await codesRef.get();
    snapshot.docs.map((e) {
      Timestamp exp = e.data()['expiryDate'];
      if (exp.toDate().isBefore(DateTime.now())) {
        allCodes.add(e.data()['code'].toString());
      }
    });
  }

  handleSignIn(GoogleSignInAccount account, BuildContext context) async {
    if (account != null) {
      await createUserInFirestore();
      if (mounted) {
        setState(() {
          isAuth = true;
          isValidCode = true;
        });
      }
      configurePushNotifications();
    } else {
      if (mounted) {
        setState(() {
          isAuth = false;
        });
      }
    }
  }

  configurePushNotifications() {
    final GoogleSignInAccount user = googleSignIn.currentUser;
    if (Platform.isIOS) getIOSPermission();
    // if (Platform.isIOS) {
    //   _firebaseMessaging.requestNotificationPermissions(IosNotificationSettings(
    //       sound: true, badge: true, alert: true, provisional: true));
    //
    // }
    _firebaseMessaging.getToken().then((token) {
      print("Firebase Messaging Token: $token\n");
      userRef.doc(user.id).update({"androidNotificationToken": token});
    });

    _firebaseMessaging.configure(
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message\n");
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message\n");
      },
      //onBackgroundMessage: myBackgroundMessageHandler,
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message\n");
        final String recipientId = message['data']['recipient'];
        final String body = message['notification']['body'];
        if (recipientId == user.id) {
          print("Notification shown!");
          BotToast.showSimpleNotification(
              title: body,
              enableSlideOff: true,
              hideCloseButton: false,
              onlyOne: true,
              crossPage: true,
              animationDuration: Duration(milliseconds: 400),
              animationReverseDuration: Duration(milliseconds: 400),
              duration: Duration(seconds: 2));
          BotToast.showText(text: body);
        }
        print("Notification NOT shown");
      },
    );
  }

  getIOSPermission() {
    _firebaseMessaging.requestNotificationPermissions(
        IosNotificationSettings(alert: true, badge: true, sound: true));
    _firebaseMessaging.onIosSettingsRegistered.listen((settings) {
      print("Settings registered: $settings");
    });
  }

  Future<String> googleSignIN() async {
    final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
    final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;
    final AuthCredential authCredential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken);
    final UserCredential userCredential =
        await auth.signInWithCredential(authCredential);
    final User user = userCredential.user;
    assert(user.displayName != null);
    assert(user.email != null);
    print(user.displayName);
    print(user.email);
    print(user.refreshToken);
    final User currentUser = auth.currentUser;
    assert(currentUser.uid == user.uid);

    return 'Error occurred';
  }

  createUserInFirestore() async {
    final GoogleSignInAccount user = googleSignIn.currentUser;
    // final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
    // final GoogleSignInAuthentication googleSignInAuthentication =
    //     await googleSignInAccount.authentication;
    // final AuthCredential authCredential = GoogleAuthProvider.credential(
    //     accessToken: googleSignInAuthentication.accessToken,
    //     idToken: googleSignInAuthentication.idToken);
    // final UserCredential userCredential =
    //     await auth.signInWithCredential(authCredential);
    // final User user = userCredential.user;
    // assert(user.displayName != null);
    // assert(user.email != null);
    // print(user.displayName);
    // print(user.email);
    // print(user.refreshToken);
    // final User currentUSER = auth.currentUser;
    // assert(currentUSER.uid == user.uid);
    DocumentSnapshot doc = await userRef.doc(user.id).get();
    if (!doc.exists && !isValidCode) {
      await Navigator.push(
          context, MaterialPageRoute(builder: (context) => CodeScreen()));

      //doc = await userRef.doc(user.id).get();
    }
    if (isValidCode && userName != null) {
      await userRef.doc(user.id).set({
        "id": user.id,
        "userName":
            userName != null ? userName : "user-${user.id.substring(0, 4)}",
        "bio": "",
        "photoUrl": user.photoUrl,
        "displayName": user.displayName,
        "timestamp": timestamp,
        "type": "user",
        "email": user.email,
      });
      doc = await userRef.doc(user.id).get();
    }

    currentUser = AppUser.fromDocument(doc);
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  onPageChanged(int pageIndex) {
    setState(() {
      this.pageIndex = pageIndex;
    });
  }

  onTap(int pageIndex) {
    if (pageIndex == 2) {
      BotToast.showText(
        text: 'Swipe to Delete',
      );
    }
    pageController.jumpToPage(
      pageIndex,

      // duration: Duration(milliseconds: 350),
      // curve: Curves.easeInOut,
    );
  }

  Scaffold buildAuthScreen() {
    return Scaffold(
      key: _scaffoldKey,
      body: PageView(
        children: <Widget>[
          KannapyStore(currentUserInStore: currentUser),
          KannapyAuction(),
          KannapyCart(
            userId: currentUser?.id,
          ),
          Timeline(
            currentUser: currentUser,
          ),
          KannapyNotifications(),
        ],
        controller: pageController,
        onPageChanged: onPageChanged,
        physics: NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: CupertinoTabBar(
        currentIndex: pageIndex,
        onTap: onTap,
        //backgroundColor: Theme.of(context).primaryColor,
        activeColor:
            Theme.of(context).bottomNavigationBarTheme.selectedItemColor,
        inactiveColor:
            Theme.of(context).bottomNavigationBarTheme.backgroundColor,
        backgroundColor: Theme.of(context).primaryColor,
        items: [
          BottomNavigationBarItem(
              icon: Icon(
            Icons.shopping_basket,
          )),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.gavel),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
          ),
          BottomNavigationBarItem(
              icon: Icon(
            Icons.whatshot,
          )),
          BottomNavigationBarItem(
              icon: Icon(
            Icons.notifications_none,
          )),
        ],
      ),
    );
  }

  Scaffold buildUnAuthScreen() {
    return Scaffold(
      body: Container(
        color: Colors.black,
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Center(
            child: Hero(
          tag: "logo",
          child: Image(
            image: AssetImage('assets/images/kannapy_logo_splash.jpg'),
            height: 200.0,
            width: 200.0,
          ),
        )),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return isAuth && isValidCode ? buildAuthScreen() : buildUnAuthScreen();
  }
}
