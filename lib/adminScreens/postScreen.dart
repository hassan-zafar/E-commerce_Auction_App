import 'package:flutter/material.dart';
import 'package:kannapy/tools/posts.dart';
import 'package:kannapy/tools/progress.dart';
import 'package:kannapy/userScreens/home.dart';

class PostScreen extends StatelessWidget {
  final String userId;
  final String postId;
  PostScreen({
    this.userId,
    this.postId,
  });
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: postsRef.doc(userId).collection('adminPosts').doc(postId).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return bouncingGridProgress();
          }
          Post post = Post.fromDocument(snapshot.data);
          return Center(
            child: Scaffold(
              appBar: AppBar(
                title: Text(post.postTitle),
              ),
              body: ListView(
                children: <Widget>[
                  Container(
                    child: post,
                  )
                ],
              ),
            ),
          );
        });
  }
}
