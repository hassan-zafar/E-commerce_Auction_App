import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:kannapy/adminScreens/adminHome.dart';
import 'package:kannapy/adminScreens/commentsNChat.dart';
import 'package:kannapy/models/users.dart';
import 'package:kannapy/nm_box.dart';
import 'package:kannapy/tools/progress.dart';
import 'package:kannapy/tools/uiFunctions.dart';
import 'package:kannapy/userScreens/home.dart';
import 'package:share/share.dart';
import 'package:uuid/uuid.dart';
import 'file:///C:/kannapy/lib/userScreens/profileScreens/aboutUs.dart';
import 'file:///C:/kannapy/lib/userScreens/profileScreens/address.dart';
import 'file:///C:/kannapy/lib/userScreens/profileScreens/favourites.dart';

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
  String invitationCode = Uuid().v4();

  buildProfileButton() {
    bool isProfileOwner = currentUserID == widget.profileId;
    if (isProfileOwner) {
      return GestureDetector(
        onTap: editProfile,
        child: Container(
            decoration: nMBox,
            padding: EdgeInsets.all(12),
            child: Text('Edit Profile')),
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

  StreamBuilder buildProfileHeader() {
    return StreamBuilder(
      stream: userRef.doc(widget.profileId).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return bouncingGridProgress();
        }
        AppUser user = AppUser.fromDocument(snapshot.data);

        return Padding(
          padding: EdgeInsets.all(16.0),
          child: neumorphicTile(
              padding: 12,
              anyWidget: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: nMBoxCirc,
                      child: CircleAvatar(
                        radius: 42.0,
                        backgroundImage:
                            user.photoUrl == null || user.photoUrl == ""
                                ? null
                                : NetworkImage(user.photoUrl),
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(top: 12.0),
                    child: Text(
                      user.userName != null ? user.userName : "Not assigned",
                      style: TextStyle(fontSize: 20.0),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(top: 4.0),
                    child: Text(
                      user.displayName != null
                          ? user.displayName
                          : "Not assigned",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(top: 2.0),
                    child: Text(
                      user.bio,
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  buildProfileButton(),
                ],
              )),
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
        centerTitle: true,
        title: GestureDetector(
          onLongPress: isAdmin || isMerc
              ? () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) =>
                          AdminHome(currentUser: currentUser, isMerc: isMerc)));
                }
              : () {},
          child: Text(
            'Profile',
            style: TextStyle(
                color: Theme.of(context).appBarTheme.textTheme.headline1.color),
          ),
        ),
      ),
      body: ListView(
        children: <Widget>[
          buildProfileHeader(),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: neumorphicTile(
                anyWidget: ListTile(
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => DeliveryAddress(justViewing: true))),
              title: Text("Delivery Address"),
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).iconTheme.color,
                child: Icon(
                  Icons.location_on,
                  color:
                      Theme.of(context).appBarTheme.textTheme.headline1.color,
                ),
              ),
            )),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: neumorphicTile(
                anyWidget: ListTile(
              onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => OrderHistory())),
              title: Text("Order History"),
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).iconTheme.color,
                child: Icon(
                  Icons.history,
                  color:
                      Theme.of(context).appBarTheme.textTheme.headline1.color,
                ),
              ),
            )),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: neumorphicTile(
                anyWidget: ListTile(
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => KannapyFavourites(
                        userId: currentUserID,
                      ))),
              title: Text("Wish List"),
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).iconTheme.color,
                child: Icon(
                  Icons.favorite_border,
                  color:
                      Theme.of(context).appBarTheme.textTheme.headline1.color,
                ),
              ),
            )),
          ),
          isAdmin
              ? SizedBox(
                  height: 0.1,
                )
              : Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: neumorphicTile(
                      anyWidget: ListTile(
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => CommentsNChat(
                              isPostComment: false,
                              isProductComment: false,
                            ))),
                    title: Text("Contact Admin"),
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).iconTheme.color,
                      child: Icon(
                        Icons.chat_bubble_outline,
                        color: Theme.of(context)
                            .appBarTheme
                            .textTheme
                            .headline1
                            .color,
                      ),
                    ),
                  )),
                ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: neumorphicTile(
                anyWidget: ListTile(
              onTap: () => share(context),
              title: Text("Invite a Friend"),
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).iconTheme.color,
                child: Icon(
                  Icons.person_add,
                  color:
                      Theme.of(context).appBarTheme.textTheme.headline1.color,
                ),
              ),
            )),
          ),
          // Padding(
          //   padding: const EdgeInsets.all(12.0),
          //   child: neumorphicTile(
          //       anyWidget: ListTile(
          //     onTap: () => Navigator.of(context).push(MaterialPageRoute(
          //         builder: (context) => RequestToBecomeMerc(
          //               currentUserId: currentUserID,
          //             ))),
          //     title: Text("Request to become a merchandiser"),
          //     leading: CircleAvatar(
          //       backgroundColor: Theme.of(context).iconTheme.color,
          //       child: Icon(
          //         Icons.person_add,
          //         color:
          //             Theme.of(context).appBarTheme.textTheme.headline1.color,
          //       ),
          //     ),
          //   )),
          // ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: neumorphicTile(
                anyWidget: ListTile(
              onTap: () => Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => AboutUs())),
              title: Text("About Us"),
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).iconTheme.color,
                child: Icon(
                  Icons.info_outline,
                  color:
                      Theme.of(context).appBarTheme.textTheme.headline1.color,
                ),
              ),
            )),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: neumorphicTile(
                anyWidget: ListTile(
              onTap: () => logout(context),
              title: Text("Logout"),
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).iconTheme.color,
                child: Icon(
                  Icons.cancel,
                  color: Colors.red,
                ),
              ),
            )),
          ),
          SizedBox(
            height: 15,
          )
        ],
      ),
    );
  }

  share(BuildContext context) {
    DateTime expiryDate = DateTime.now().add(Duration(days: 2));
    handleCode(invitationCode, expiryDate);
    final RenderBox box = context.findRenderObject();
    Share.share(
      invitationCode,
      subject: "Invitation Code",
      sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size,
    );
  }
}
