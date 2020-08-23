import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kannapy/adminScreens/appUsers.dart';
import 'package:kannapy/models/users.dart';
import 'package:kannapy/tools/posts.dart';
import 'package:kannapy/tools/progress.dart';

import 'home.dart';

class Timeline extends StatefulWidget {
  final User currentUser;
  Timeline({
    this.currentUser,
  });

  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  List<Post> posts;
//  RefreshController _refreshController =
//  RefreshController(initialRefresh: false);
  @override
  void initState() {
    super.initState();
    getTimeline();
  }

  getTimeline() async {
    QuerySnapshot snapshot = await timelineRef.getDocuments();

    List<Post> posts =
        snapshot.documents.map((doc) => Post.fromDocument(doc)).toList();
    setState(() {
      this.posts = posts;
    });
  }

  buildTimeline() {
    if (posts == null) {
      return bouncingGridProgress();
    } else if (posts.isEmpty) {
      return Center(child: Text('No posts'));
    } else {
      return ListView(
        children: posts,
      );
    }
  }

  @override
  Scaffold build(context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Kannapy Feed"),
      ),
      body: buildTimeline(),
    );
  }
}
