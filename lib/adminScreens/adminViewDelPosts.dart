import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kannapy/tools/posts.dart';
import 'package:kannapy/tools/postsTile.dart';
import 'package:kannapy/tools/progress.dart';
import 'package:kannapy/userScreens/home.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class AdminViewDelPosts extends StatefulWidget {
  final String profileId;
  AdminViewDelPosts({this.profileId});
  @override
  _AdminViewDelPostsState createState() => _AdminViewDelPostsState();
}

class _AdminViewDelPostsState extends State<AdminViewDelPosts> {
  final String currentUserID = currentUser?.id;
  String postOrientation = "grid";
  bool isLoading = false;
  int postCount = 0;
  List<Post> posts = [];
  RefreshController _refreshController = RefreshController();

  @override
  void initState() {
    super.initState();
    getProfilePost();
  }

  getProfilePost() async {
    setState(() {
      isLoading = true;
    });

    QuerySnapshot snapshot =
        await timelineRef.orderBy('timestamp', descending: true).get();
    // QuerySnapshot snapshot = await postsRef
    //     .doc(widget.profileId)
    //     .collection('adminPosts')
    //     .orderBy('timestamp', descending: true)
    //     .get();
    setState(() {
      isLoading = false;
      postCount = snapshot.docs.length;
      posts = snapshot.docs.map((doc) => Post.fromDocument(doc)).toList();
    });
  }

  buildProfilePosts() {
    if (isLoading) {
      return bouncingGridProgress();
    } else if (posts.isEmpty) {
      return Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 20.0),
              child: Text(
                "No Posts",
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
    } else if (postOrientation == "grid") {
      List<GridTile> gridTiles = [];
      posts.forEach((posts) {
        gridTiles.add(GridTile(child: PostTile(posts)));
      });
      return GridView.count(
        crossAxisCount: 3,
        childAspectRatio: 1,
        physics: NeverScrollableScrollPhysics(),
        mainAxisSpacing: 1.5,
        crossAxisSpacing: 1.5,
        shrinkWrap: true,
        children: gridTiles,
      );
    } else if (postOrientation == 'list') {
      return Column(
        children: posts,
      );
    }
  }

  setPostOrientation(String postOrientation) {
    setState(() {
      this.postOrientation = postOrientation;
    });
  }

  buildTogglePostOrientation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        IconButton(
            icon: Icon(Icons.grid_on),
            color: postOrientation == 'grid' ? Colors.black : Colors.grey,
            onPressed: () => setPostOrientation("grid")),
        IconButton(
            icon: Icon(Icons.list),
            color: postOrientation == 'list' ? Colors.black : Colors.grey,
            onPressed: () => setPostOrientation("list")),
      ],
    );
  }

  // bool get wantKeepAlive => true;
  @override
  Scaffold build(BuildContext context) {
    // super.build(context);
    return Scaffold(
        appBar: AppBar(title: Text("View/Del Posts")),
        body: SmartRefresher(
          child: ListView(
            children: <Widget>[
              buildTogglePostOrientation(),
              Divider(
                height: 0.0,
              ),
              buildProfilePosts(),
            ],
          ),
          controller: _refreshController,
          header: WaterDropMaterialHeader(
            distance: 40.0,
          ),
          onRefresh: () {
            getProfilePost();
            _refreshController.refreshCompleted();
          },
        ));
  }
}
