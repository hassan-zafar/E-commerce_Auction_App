import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kannapy/adminScreens/editPosts.dart';
import 'package:kannapy/adminScreens/postComments.dart';
import 'package:kannapy/models/users.dart';
import 'package:kannapy/tools/customImages.dart';
import 'package:kannapy/tools/progress.dart';
import 'package:kannapy/userScreens/home.dart';
import 'package:kannapy/userScreens/userProfile.dart';

//actually a model like user model class but written in the same file with post widget so that we can add methods to it to pass them to our state class
class Post extends StatefulWidget {
  final String postId;
  final String ownerId;
  final String userName;
  final String postTitle;
  final String description;
  final String postMediaUrl;

  Post({
    this.postId,
    this.ownerId,
    this.userName,
    this.postTitle,
    this.description,
    this.postMediaUrl,
  });
  factory Post.fromDocument(DocumentSnapshot doc) {
    return Post(
      postId: doc["postId"],
      ownerId: doc["ownerId"],
      userName: doc["userName"],
      description: doc["description"],
      postTitle: doc["postTitle"],
      postMediaUrl: doc["postMediaUrl"],
    );
  }

  @override
  _PostState createState() => _PostState(
        postId: this.postId,
        ownerId: this.ownerId,
        userName: this.userName,
        description: this.description,
        postMediaUrl: this.postMediaUrl,
        postTitle: this.postTitle,
      );
}

class _PostState extends State<Post> {
  bool isLiked;
  final String currentUserId = currentUser?.id;
  final String postId;
  final String ownerId;
  final String userName;
  final String postTitle;
  final String description;
  final String postMediaUrl;

  ///AnimationController _controller;
  int likeCount;
  Map likes;
  _PostState({
    this.postId,
    this.ownerId,
    this.userName,
    this.postTitle,
    this.description,
    this.postMediaUrl,
  });
//  @override
//  void dispose() {
//    _controller.dispose();
//    super.dispose();
//  }

  showProfile(BuildContext context, {String profileId}) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Profile(
                  profileId: profileId,
                )));
  }

  buildPostHeader() {
    return FutureBuilder(
      future: userRef.document(ownerId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return bouncingGridProgress();
        }
        User user = User.fromDocument(snapshot.data);
        bool isPostOwner = currentUserId == ownerId;
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(user.photoUrl),
            backgroundColor: Colors.grey,
          ),
          title: GestureDetector(
            onTap: () => showProfile(context, profileId: user.id),
            child: Text(
              user.userName,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          subtitle: Text(postTitle),
          trailing: isPostOwner
              ? IconButton(
                  onPressed: () => handleOptionPost(context),
                  icon: Icon(Icons.more_vert),
                )
              : Text(''),
        );
      },
    );
  }

  handleOptionPost(BuildContext parentContext) {
    return showDialog(
        context: parentContext,
        builder: (context) {
          return SimpleDialog(
            children: <Widget>[
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context);
                  editPostScreen();
                },
                child: Text(
                  'Edit',
                ),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context);
                  deletePost();
                },
                child: Text(
                  'Delete',
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

//Note:to delete Post,ownerId and currentUserId must be equal, so they can be used interchangeably
  deletePost() async {
    postsRef
        .document(ownerId)
        .collection('adminPosts')
        .document(postId)
        .get()
        .then((doc) {
      if (doc.exists) {}
      doc.reference.delete();
    });
    //delete post from storage
    storageRef.child("post_$postId.jpg").delete();
    //then delete all activityFeed notifications

    //then delete all comments
    QuerySnapshot commentSnapshot = await commentsRef
        .document(postId)
        .collection('comments')
        .getDocuments();

    commentSnapshot.documents.forEach((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

  GestureDetector buildPostImage() {
    return GestureDetector(
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          cachedNetworkImage(postMediaUrl),
        ],
      ),
    );
  }

  buildPostFooter() {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(padding: EdgeInsets.only(top: 40.0, left: 20.0)),
            Padding(padding: EdgeInsets.only(right: 20.0)),
            GestureDetector(
              onTap: () => showComments(
                context,
                mediaUrl: postMediaUrl,
                postId: postId,
                ownerId: ownerId,
              ),
              child: Icon(
                Icons.chat_bubble,
                size: 28.0,
              ),
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 20.0),
              child: Text(
                "$userName ",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                ),
              ),
            ),
            Expanded(
              child: Text(description),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        buildPostHeader(),
        buildPostImage(),
        buildPostFooter(),
      ],
    );
  }

  editPostScreen() {
    return Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => EditPosts(
              description: description,
              mediaUrl: postMediaUrl,
              postTitle: postTitle,
              postId: postId,
              currentUserId: currentUserId,
            )));
  }
}

showComments(
  BuildContext context, {
  String postId,
  String ownerId,
  String mediaUrl,
}) {
  Navigator.push(context, MaterialPageRoute(builder: (context) {
    return PostComments(
      postId: postId,
      postOwnerId: ownerId,
      postMediaUrl: mediaUrl,
//      userName: userName,
    );
  }));
}
