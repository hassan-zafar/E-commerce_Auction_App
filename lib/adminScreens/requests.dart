import 'package:bot_toast/bot_toast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kannapy/tools/progress.dart';
import 'package:kannapy/userScreens/home.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class Requests extends StatefulWidget {
  @override
  _RequestsState createState() => _RequestsState();
}

class _RequestsState extends State<Requests> {
  List<UserMercData> userMercData = [];
  var snap;
  RefreshController _refreshController = RefreshController();

  bool isUpdating = false;
  bool isLoading = false;
  @override
  void initState() {
    getRequests();
    super.initState();
  }

  getRequests() async {
    setState(() {
      isLoading = true;
    });
    QuerySnapshot snapshot = await mercReqRef.get();
    userMercData =
        snapshot.docs.map((e) => UserMercData.fromDocument(e)).toList();
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Requests'),
      ),
      body: SmartRefresher(
        controller: _refreshController,
        child: buildRequests(),
        onRefresh: () {
          getRequests();
          _refreshController.refreshCompleted();
        },
      ),
    );
  }

  delFromList(int index, String del) async {
    await mercReqRef.doc(userMercData[index].userId).delete();
    await addToFeed(index, del);
  }

  addToFeed(int index, String msg) {
    activityFeedRef
        .doc(userMercData[index].userId)
        .collection('feedItems')
        .add({
      "type": "mercReq",
      "commentData": msg,
      "userName": userMercData[index].displayName,
      "userId": userMercData[index].userId,
      "userProfileImg": userMercData[index].photoUrl,
      "ownerId": currentUser.id,
      "mediaUrl": currentUser.photoUrl,
      "timestamp": timestamp,
      "productId": "",
    });
  }

  upgradeToMerc(int index, String cong) async {
    setState(() {
      isUpdating = true;
    });
    await userRef.doc(userMercData[index].userId).update({"type": "merc"});
    await mercSelectedRef.doc(userMercData[index].userId).set({
      "mercId": userMercData[index].userId,
      "timestamp": timestamp,
    }).then((value) => mercReqRef.doc(userMercData[index].userId).delete());
    await addToFeed(index, cong);
    setState(() {
      isUpdating = false;
    });
    _refreshController.refreshCompleted();
    BotToast.showText(text: "User Upgraded");
  }

  buildRequests() {
    if (isLoading) {
      return bouncingGridProgress();
    }
    if (userMercData.isEmpty) {
      return Center(
        child: Text(
          "No Requests",
          style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
        ),
      );
    }
    return ListView.separated(
        itemBuilder: (context, index) {
          return Dismissible(
            onDismissed: (direction) {
              delFromList(index, "Sorry Your request has been denied");
              BotToast.showText(text: "Request Dismissed");
            },
            background: Container(
              alignment: Alignment.centerRight,
              color: Colors.red,
              child: Text('Dismiss'),
            ),
            direction: DismissDirection.horizontal,
            key: UniqueKey(),
            child: GestureDetector(
              onTap: () => handleRequestDetails(context, index),
              child: Container(
                color: Colors.black26,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: userMercData[index].photoUrl == null
                        ? null
                        : CachedNetworkImageProvider(
                            userMercData[index].photoUrl),
                    backgroundColor: Colors.grey,
                  ),
                  title: Text(
                    userMercData[index].displayName,
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    "E-mail: ${userMercData[index].email}",
                    style: TextStyle(color: Colors.white),
                    overflow: TextOverflow.fade,
                  ),
                  trailing: GestureDetector(
                      onTap: () => isUpdating
                          ? null
                          : upgradeToMerc(index,
                              "Congratulations you have been upgraded to Merchandiser.Long pressing on Kannapy Logo will give you Panel access"),
                      child: Icon(Icons.done)),
                ),
              ),
            ),
          );
        },
        separatorBuilder: (context, index) {
          return Divider();
        },
        itemCount: userMercData.length);
  }

  handleRequestDetails(BuildContext parentContext, int index) {
    return showDialog(
        context: parentContext,
        builder: (context) {
          return SimpleDialog(
            children: <Widget>[
              Center(
                child: Column(
                  children: [
                    Hero(
                      tag: userMercData[index].userId,
                      child: CircleAvatar(
                        child: Image(
                            image: CachedNetworkImageProvider(
                                userMercData[index].photoUrl)),
                        radius: 50.0,
                      ),
                    ),
                    SizedBox(
                      height: 8.0,
                    ),
                    Text(
                      "Name :${userMercData[index].displayName}",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 8.0,
                    ),
                    Text(
                      "Entered Name:${userMercData[index].userName}",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 8.0,
                    ),
                    Text(
                      "E-mail :${userMercData[index].email}",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 8.0,
                    ),
                    Text(
                      "Message :${userMercData[index].requestMessage}",
                      maxLines: 10,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "Time :${userMercData[index].timestamp.toDate()}",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 8.0,
                    ),
                  ],
                ),
              ),
            ],
          );
        });
  }
}

class UserMercData {
  final String userId;
  final String userName;
  final String requestMessage;
  final String email;
  final String requestStatus;
  final timestamp;
  final String photoUrl;
  final String displayName;
  UserMercData({
    this.userName,
    this.email,
    this.photoUrl,
    this.userId,
    this.timestamp,
    this.requestMessage,
    this.requestStatus,
    this.displayName,
  });

  factory UserMercData.fromDocument(DocumentSnapshot doc) {
    return UserMercData(
      userName: doc.data()["userName"],
      email: doc.data()["email"],
      photoUrl: doc.data()["photoUrl"],
      userId: doc.data()["userId"],
      timestamp: doc.data()["timestamp"],
      requestMessage: doc.data()["requestMessage"],
      requestStatus: doc.data()["requestStatus"],
      displayName: doc.data()['displayName'],
    );
  }
}
