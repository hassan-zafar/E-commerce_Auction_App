import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:kannapy/adminScreens/uploadPosts.dart';
import 'package:kannapy/adminScreens/searchData.dart';
import 'package:kannapy/adminScreens/adminViewDelPosts.dart';
import 'package:kannapy/models/users.dart';
import 'addProducts.dart';
import 'appFeedback.dart';
import 'appMessages.dart';
import 'appOrders.dart';
import 'appUsers.dart';
import 'orderHistory.dart';
import 'package:kannapy/userScreens/home.dart';

class AdminHome extends StatefulWidget {
  final User currentUser;
  AdminHome({this.currentUser});
  @override
  _AdminHomeState createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  Size screenSize;
  @override
  Widget build(BuildContext context) {
    screenSize = MediaQuery.of(context).size;
    return Scaffold(
      // backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        title: currentUser.type == "admin"
            ? Text("Kannapy Admin")
            : Text("Kannapy Partner Panel"),
        centerTitle: true,
        elevation: 0.0,
      ),
      //drawer:  Drawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 20.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                        CupertinoPageRoute(builder: (context) => SearchData()));
                  },
                  child: CircleAvatar(
                    maxRadius: 70.0,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(Icons.search),
                        SizedBox(
                          height: 10.0,
                        ),
                        Text("Search Data"),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(CupertinoPageRoute(
                        builder: (context) =>
                            UserNSearch(currentUser: currentUser)));
                  },
                  child: CircleAvatar(
                    maxRadius: 70.0,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(Icons.person),
                        SizedBox(
                          height: 10.0,
                        ),
                        Text("App Users"),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 20.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(CupertinoPageRoute(
                        builder: (context) => AdminViewDelPosts(
                              profileId: currentUser?.id,
                            )));
                  },
                  child: CircleAvatar(
                    maxRadius: 70.0,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(Icons.mode_edit),
                        SizedBox(
                          height: 10.0,
                        ),
                        Text("View/Edit Posts"),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(CupertinoPageRoute(
                        builder: (context) =>
                            UserNSearch(currentUser: currentUser)));
                  },
                  child: CircleAvatar(
                    maxRadius: 70.0,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(Icons.person),
                        SizedBox(
                          height: 10.0,
                        ),
                        Text("App Users"),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 20.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                        CupertinoPageRoute(builder: (context) => AppOrders()));
                  },
                  child: CircleAvatar(
                    maxRadius: 70.0,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(Icons.trending_up),
                        SizedBox(
                          height: 10.0,
                        ),
                        Text("App Orders"),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(CupertinoPageRoute(
                        builder: (context) => AppMessages()));
                  },
                  child: CircleAvatar(
                    maxRadius: 70.0,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(Icons.chat),
                        SizedBox(
                          height: 10.0,
                        ),
                        Text("App Messages"),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 20.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(CupertinoPageRoute(
                        builder: (context) => AppFeedback()));
                  },
                  child: CircleAvatar(
                    maxRadius: 70.0,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(Icons.feedback),
                        SizedBox(
                          height: 10.0,
                        ),
                        Text("App Products"),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(CupertinoPageRoute(
                        builder: (context) => AddProducts(
                              currentUser: currentUser,
                            )));
                  },
                  child: CircleAvatar(
                    maxRadius: 70.0,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(Icons.add),
                        SizedBox(
                          height: 10.0,
                        ),
                        Text("Add Products"),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 20.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(CupertinoPageRoute(
                        builder: (context) => AdminOrdersHistory()));
                  },
                  child: CircleAvatar(
                    maxRadius: 70.0,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(Icons.history),
                        SizedBox(
                          height: 10.0,
                        ),
                        Text("Order History"),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(CupertinoPageRoute(
                        builder: (context) => UploadPosts(
                              currentUser: currentUser,
                            )));
                  },
                  child: CircleAvatar(
                    maxRadius: 70.0,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(Icons.file_upload),
                        SizedBox(
                          height: 10.0,
                        ),
                        Text("Upload Posts"),
                      ],
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
