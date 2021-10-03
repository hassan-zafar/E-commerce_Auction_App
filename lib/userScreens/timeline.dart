import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kannapy/adminScreens/adminHome.dart';
import 'package:kannapy/models/users.dart';
import 'package:kannapy/tools/posts.dart';
import 'package:kannapy/tools/progress.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'home.dart';
import 'profileScreens/dashBoard.dart';

class Timeline extends StatefulWidget {
  final AppUser currentUser;
  final String postId;
  Timeline({
    this.currentUser,
    this.postId,
  });

  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline>
    with AutomaticKeepAliveClientMixin<Timeline> {
  List<Post> posts;

  bool _disposed = false;
  RefreshController _refreshController = RefreshController();
  @override
  void initState() {
    super.initState();
    getTimeline();
  }

  getTimeline() async {
    QuerySnapshot snapshot =
        await timelineRef.orderBy('timestamp', descending: true).get();

    List<Post> posts =
        snapshot.docs.map((doc) => Post.fromDocument(doc)).toList();
    if (!_disposed) {
      setState(() {
        this.posts = posts;
      });
    }
  }

  buildTimeline() {
    if (posts == null) {
      return bouncingGridProgress();
    } else if (posts.isEmpty) {
      return Center(child: Text('No posts'));
    } else {
      return ListView(
        physics: BouncingScrollPhysics(),
        children: posts,
      );
    }
  }

  @override
  Scaffold build(BuildContext context) {
    super.build(context);
    return Scaffold(
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
            'KANNAPY FEED',
            style: TextStyle(
                color: Theme.of(context).appBarTheme.textTheme.headline1.color),
          ),
        ),
        actions: [
          IconButton(
              icon: Icon(Icons.person_outline,
                  color:
                      Theme.of(context).appBarTheme.textTheme.headline1.color),
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => Profile(
                        profileId: currentUser?.id,
                      )))),
        ],
      ),
      body: SmartRefresher(
        child: buildTimeline(),
        header: WaterDropMaterialHeader(
          distance: 40.0,
        ),
        controller: _refreshController,
        onRefresh: () {
          _refreshController.requestRefresh();
          getTimeline();
          buildTimeline();
          _refreshController.refreshCompleted();
        },
      ),
    );
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _disposed = true;
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;
}
