import 'package:flutter/material.dart';
import 'package:kannapy/adminScreens/postScreen.dart';
import 'package:kannapy/tools/customImages.dart';
import 'package:kannapy/tools/posts.dart';

class PostTile extends StatelessWidget {
  final Post post;
  PostTile(this.post);

  showPost(context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PostScreen(
                  userId: post.ownerId,
                  postId: post.postId,
                )));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showPost(context),
      child: cachedNetworkImage(post.postMediaUrl),
    );
  }
}
