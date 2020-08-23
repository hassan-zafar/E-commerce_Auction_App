import 'package:flutter/material.dart';
import 'package:kannapy/adminScreens/orderHistory.dart';
import 'package:kannapy/models/users.dart';
import 'package:kannapy/tools/progress.dart';
import 'package:kannapy/userScreens/aboutUs.dart';
import 'package:kannapy/userScreens/address.dart';
import 'package:kannapy/userScreens/cart.dart';
import 'package:kannapy/userScreens/favourites.dart';
import 'package:kannapy/userScreens/home.dart';
import 'package:kannapy/userScreens/notifications.dart';

import 'editProfile.dart';
import 'history.dart';

class Profile extends StatefulWidget {
  final String profileId;
  Profile({this.profileId});
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final String currentUserID = currentUser?.id;
  bool isLoading = false;
  int postCount = 0;
  @override
//  void initState() {
//    SnackBar snackbar = SnackBar(content: Text("Chal gi!"));
//    _scaffoldKey.currentState.showSnackBar(snackbar);
//    print(currentUserID);
//    super.initState();
//  }

  buildProfileButton() {
    //Will show different screen for LoggedIn user vs Visiting User
    bool isProfileOwner = currentUserID == widget.profileId;
    if (isProfileOwner) {
      return RaisedButton(
        onPressed: editProfile,
        child: Text('Edit Profile'),
      );
    }
  }

  editProfile() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => EditProfile(
                  currentUserID: currentUserID,
                )));
  }

  FutureBuilder buildProfileHeader() {
    return FutureBuilder(
      future: userRef.document(widget.profileId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return bouncingGridProgress();
        }
        User user = User.fromDocument(snapshot.data);
        print(user.photoUrl);
        print(user.userName);

        return Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  CircleAvatar(
                    radius: 42.0,
                    backgroundColor: Colors.grey,
                    backgroundImage:
                        user.photoUrl == null || user.photoUrl == ""
                            ? null
                            : NetworkImage(user.photoUrl),
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: <Widget>[
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            buildProfileButton(),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.only(top: 12.0),
                alignment: Alignment.centerLeft,
                child: Text(
                  user.userName != null ? user.userName : "dfdsfsd",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0),
                ),
              ),
              Container(
                padding: EdgeInsets.only(top: 4.0),
                alignment: Alignment.centerLeft,
                child: Text(
                  user.displayName != null ? user.displayName : "dfdsfsd",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.only(top: 2.0),
                alignment: Alignment.centerLeft,
                child: Text(
                  user.bio,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // bool get wantKeepAlive => true;
  @override
  Scaffold build(BuildContext context) {
    // super.build(context);
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text('Profile'),
        ),
        body: ListView(
          children: <Widget>[
            buildProfileHeader(),
            Divider(),
            ListTile(
              onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => DeliveryAddress())),
              title: Text("Delivery Address"),
              leading: CircleAvatar(
                child: Icon(Icons.location_on),
              ),
            ),
            Divider(),
            ListTile(
              onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => OrderHistory())),
              title: Text("Order History"),
              leading: CircleAvatar(
                child: Icon(Icons.history),
              ),
            ),
            Divider(),
            ListTile(
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => KannapyNotifications())),
              title: Text("Notifications"),
              leading: CircleAvatar(
                child: Icon(Icons.notifications_none),
              ),
            ),
            Divider(),
            ListTile(
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => KannapyFavourites(
                        userId: currentUserID,
                      ))),
              title: Text("Favourites"),
              leading: CircleAvatar(
                child: Icon(Icons.favorite_border),
              ),
            ),
            Divider(),
            ListTile(
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => KannapyCart(
                        userId: currentUserID,
                      ))),
              title: Text("Cart"),
              leading: CircleAvatar(
                child: Icon(Icons.shopping_cart),
              ),
            ),
            Divider(),
            ListTile(
              onTap: () => Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => AboutUs())),
              title: Text("About Us"),
              leading: CircleAvatar(
                child: Icon(Icons.info_outline),
              ),
            ),
            Divider(),
            ListTile(
              onTap: () => logout(),
              title: Text("Logout"),
              leading: CircleAvatar(
                child: Icon(
                  Icons.cancel,
                  color: Colors.red,
                ),
              ),
            ),
            Divider(),
          ],
        ));
  }

  logout() async {
    await googleSignIn.signOut();
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return Home();
    }));
  }
}
