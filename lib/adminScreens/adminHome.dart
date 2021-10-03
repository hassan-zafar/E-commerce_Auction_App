import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kannapy/adminScreens/adminViewDelPosts.dart';
import 'package:kannapy/adminScreens/chatLists.dart';
import 'package:kannapy/adminScreens/manageCodes.dart';
import 'package:kannapy/adminScreens/requests.dart';
import 'package:kannapy/adminScreens/uploadPosts.dart';
import 'package:kannapy/models/users.dart';
import 'package:kannapy/tools/uiFunctions.dart';
import 'package:kannapy/userScreens/home.dart';

import 'addEditProducts.dart';
import 'appUsers.dart';
import 'orders.dart';

class AdminHome extends StatefulWidget {
  final AppUser currentUser;
  final bool isMerc;
  AdminHome({this.currentUser, this.isMerc});
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
            ? Text(
                "Kannapy Admin",
                style: TextStyle(
                    color: Theme.of(context)
                        .appBarTheme
                        .textTheme
                        .headline1
                        .color),
              )
            : Text(
                "Kannapy Partner Panel",
                style: TextStyle(
                    color: Theme.of(context)
                        .appBarTheme
                        .textTheme
                        .headline1
                        .color),
              ),
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
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                isMerc
                    ? Text('')
                    : GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(CupertinoPageRoute(
                              builder: (context) => ManageCodes()));
                        },
                        child: neumorphicTile(
                          anyWidget: Container(
                            height: 120,
                            width: 120,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                FaIcon(
                                  FontAwesomeIcons.keycdn,
                                ),
                                SizedBox(
                                  height: 10.0,
                                ),
                                Text(
                                  "Manage Codes",
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                isMerc
                    ? Text('')
                    : GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(CupertinoPageRoute(
                              builder: (context) => ChatLists()));
                        },
                        child: neumorphicTile(
                          anyWidget: Container(
                            height: 120,
                            width: 120,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20)),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(
                                  Icons.chat_bubble_outline,
                                ),
                                SizedBox(
                                  height: 10.0,
                                ),
                                Text(
                                  "View Chats",
                                ),
                              ],
                            ),
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
                        builder: (context) => AddEditProducts(
                              currentUser: currentUser,
                              isEdit: false,
                            )));
                  },
                  child: neumorphicTile(
                    anyWidget: Container(
                      height: 120,
                      width: 120,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.add,
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          Text(
                            "Add Products",
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                isMerc
                    ? Text('')
                    : GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(CupertinoPageRoute(
                              builder: (context) => Requests()));
                        },
                        child: neumorphicTile(
                          anyWidget: Container(
                            height: 120,
                            width: 120,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20)),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(
                                  Icons.person_add,
                                ),
                                SizedBox(
                                  height: 10.0,
                                ),
                                Text(
                                  "View Requests",
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
              ],
            ),
            isMerc
                ? Text('')
                : SizedBox(
                    height: 20.0,
                  ),
            isMerc
                ? Text('')
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(CupertinoPageRoute(
                              builder: (context) =>
                                  UserNSearch(currentUser: currentUser)));
                        },
                        child: neumorphicTile(
                          anyWidget: Container(
                            height: 120,
                            width: 120,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(
                                  Icons.person,
                                ),
                                SizedBox(
                                  height: 10.0,
                                ),
                                Text(
                                  "App Users",
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(CupertinoPageRoute(
                              builder: (context) => AdminViewDelPosts(
                                    profileId: currentUser?.id,
                                  )));
                        },
                        child: neumorphicTile(
                          anyWidget: Container(
                            height: 120,
                            width: 120,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(
                                  Icons.mode_edit,
                                ),
                                SizedBox(
                                  height: 10.0,
                                ),
                                Text(
                                  "View/Edit Posts",
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
            isMerc
                ? Text('')
                : SizedBox(
                    height: 20.0,
                  ),
            isMerc
                ? Text('')
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[],
                  ),
            isMerc
                ? Text('')
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(CupertinoPageRoute(
                              builder: (context) => AdminOrders()));
                        },
                        child: neumorphicTile(
                          anyWidget: Container(
                            height: 120,
                            width: 120,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(
                                  Icons.history,
                                ),
                                SizedBox(
                                  height: 10.0,
                                ),
                                Text(
                                  "Order History",
                                ),
                              ],
                            ),
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
                        child: neumorphicTile(
                          anyWidget: Container(
                            height: 120,
                            width: 120,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(
                                  Icons.file_upload,
                                ),
                                SizedBox(
                                  height: 10.0,
                                ),
                                Text(
                                  "Upload Posts",
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}
