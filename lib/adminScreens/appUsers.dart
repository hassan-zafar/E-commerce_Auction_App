import 'package:bot_toast/bot_toast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kannapy/models/users.dart';
import 'package:kannapy/tools/progress.dart';
import 'package:kannapy/tools/uiFunctions.dart';
import 'package:kannapy/userScreens/home.dart';

class UserNSearch extends StatefulWidget {
  final AppUser currentUser;
  UserNSearch({this.currentUser});
  @override
  _UserNSearchState createState() => _UserNSearchState();
}

class _UserNSearchState extends State<UserNSearch>
    with AutomaticKeepAliveClientMixin<UserNSearch> {
  Future<QuerySnapshot> searchResultsFuture;
  TextEditingController searchController = TextEditingController();

  String typeSelected = 'users';
  handleSearch(String query) {
    Future<QuerySnapshot> users =
        userRef.where("userName", isGreaterThanOrEqualTo: query).get();
    setState(() {
      searchResultsFuture = users;
    });
  }

  clearSearch() {
    searchController.clear();
  }

  AppBar buildSearchField(context) {
    return AppBar(
      backgroundColor: Theme.of(context).accentColor,
      title: TextFormField(
        controller: searchController,
        decoration: InputDecoration(
            hintText: "Search",
            prefixIcon: Icon(Icons.search),
            suffixIcon: IconButton(
              icon: Icon(Icons.clear),
              onPressed: clearSearch,
            )),
        onFieldSubmitted: handleSearch,
      ),
    );
  }

  buildSearchResult() {
    return FutureBuilder(
      future: searchResultsFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return bouncingGridProgress();
        }
        List<UserResult> searchResults = [];
        snapshot.data.documents.forEach((doc) {
          String completeName =
              doc.data()["userName"].toString().toLowerCase().trim();
          if (completeName.contains(searchController.text)) {
            AppUser user = AppUser.fromDocument(doc);
            UserResult searchResult = UserResult(user);
            searchResults.add(searchResult);
          }
        });
        return ListView(
          children: searchResults,
        );
      },
    );
  }

  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SafeArea(
      child: Scaffold(
        appBar: buildSearchField(context),
        body:
            searchResultsFuture == null ? buildAllUsers() : buildSearchResult(),
      ),
    );
  }

  buildAllUsers() {
    return StreamBuilder(
        stream: userRef.orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return bouncingGridProgress();
          }
          List<UserResult> userResults = [];
          List<UserResult> allAdmins = [];
          List<UserResult> allMerc = [];

          snapshot.data.docs.forEach((doc) {
            AppUser user = AppUser.fromDocument(doc);

            //remove auth user from recommended list
            if (user.type == 'admin') {
              UserResult adminResult = UserResult(user);
              allAdmins.add(adminResult);
            } else if (user.type == 'merc') {
              UserResult mercResult = UserResult(user);
              allMerc.add(mercResult);
            } else {
              UserResult userResult = UserResult(user);
              userResults.add(userResult);
            }
          });
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: neumorphicTile(
              padding: 8,
              anyWidget: ListView(
                physics: BouncingScrollPhysics(),
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        typeSelected = "users";
                      });
                    },
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: neumorphicTile(
                        padding: 2,
                        anyWidget: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              "${userResults.length}",
                              style: TextStyle(fontSize: 30.0),
                            ),
                            Icon(
                              Icons.person_outline,
                              size: 30.0,
                            ),
                            SizedBox(
                              width: 8.0,
                            ),
                            Text(
                              "Total Users",
                              style: TextStyle(fontSize: 30.0),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              typeSelected = "admin";
                            });
                          },
                          child: neumorphicTile(
                              padding: 12,
                              anyWidget:
                                  Text("All Admins ${allAdmins.length}")),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(12),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              typeSelected = "merc";
                            });
                          },
                          child: neumorphicTile(
                              padding: 12,
                              anyWidget:
                                  Text("All Merchandisers ${allMerc.length}")),
                        ),
                      )
                    ],
                  ),
                  typeSelected == 'admin'
                      ? Column(
                          children: allAdmins,
                        )
                      : Text(""),
                  typeSelected == 'merc'
                      ? Column(
                          children: allMerc,
                        )
                      : Text(''),
                  typeSelected == 'users'
                      ? Column(
                          children: userResults,
                        )
                      : Text(''),
                ],
              ),
            ),
          );
        });
  }
}

class UserResult extends StatelessWidget {
  final AppUser user;
  UserResult(this.user);
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          GestureDetector(
            onLongPress: () => makeAdminMerc(context),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: neumorphicTile(
                padding: 2,
                anyWidget: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: CachedNetworkImageProvider(user.photoUrl),
                    backgroundColor: Colors.grey,
                  ),
                  title: Text(
                    user.userName,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    user.displayName,
                  ),
                  trailing: Text(user.type),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  makeAdminMerc(BuildContext parentContext) {
    return showDialog(
        context: parentContext,
        builder: (context) {
          return SimpleDialog(
            children: <Widget>[
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context);
                  makeAdmin("Upgraded to Admin");
                },
                child: Text(
                  'Make Admin',
                ),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context);
                  makeMerc("Upgraded to Merchandiser");
                },
                child: Text(
                  'Make Merchandiser',
                ),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context);
                  deleteUser();
                },
                child: Text(
                  'Delete User',
                  style: TextStyle(color: Colors.red),
                ),
              ),
              SimpleDialogOption(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              )
            ],
          );
        });
  }

  void makeAdmin(String msg) {
    userRef.doc(user.id).update({"type": "admin"});
    mercReqRef.doc(user.id).delete();
    addToFeed(msg);

    BotToast.showText(text: "User Upgraded to Admin");
  }

  void makeMerc(String msg) {
    userRef.doc(user.id).update({"type": "merc"});
    mercSelectedRef.doc(user.id).set({
      "mercId": user.id,
      "timestamp": timestamp,
    }).then((value) => mercReqRef.doc(user.id).delete());
    addToFeed(msg);

    BotToast.showText(text: "User Upgraded to merchandiser");
  }

  addToFeed(String msg) {
    activityFeedRef.doc(user.id).collection('feedItems').add({
      "type": "mercReq",
      "commentData": msg,
      "userName": user.displayName,
      "userId": user.id,
      "userProfileImg": user.photoUrl,
      "ownerId": currentUser.id,
      "mediaUrl": currentUser.photoUrl,
      "timestamp": timestamp,
      "productId": "",
    });
  }

  void deleteUser() {
    userRef.doc(user.id).delete();
    BotToast.showText(text: 'User Deleted Refresh');
  }
}
