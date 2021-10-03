import 'dart:async';

import 'package:animator/animator.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:kannapy/adminScreens/commentsNChat.dart';
import 'package:kannapy/adminScreens/editPosts.dart';
import 'package:kannapy/models/users.dart';
import 'package:kannapy/nm_box.dart';
import 'package:kannapy/tools/customImages.dart';
import 'package:kannapy/tools/progress.dart';
import 'package:kannapy/tools/uiFunctions.dart';
import 'package:kannapy/userScreens/home.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:uuid/uuid.dart';

import 'file:///C:/kannapy/lib/userScreens/profileScreens/dashBoard.dart';
import 'package:kannapy/tools/notificationHandler.dart';

//actually a model like user model class but written in the same file with post widget so that we can add methods to it to pass them to our state class
class Post extends StatefulWidget {
  final String postId;
  final String ownerId;
  final String userName;
  final String postTitle;
  final String description;
  final String postMediaUrl;
  final String subHeading;
  final dynamic likes;
  final String videoLink;

  Post({
    this.postId,
    this.ownerId,
    this.userName,
    this.postTitle,
    this.description,
    this.postMediaUrl,
    this.likes,
    this.subHeading,
    this.videoLink,
  });
  factory Post.fromDocument(DocumentSnapshot doc) {
    return Post(
      postId: doc.data()["postId"],
      ownerId: doc.data()["ownerId"],
      userName: doc.data()["userName"],
      description: doc.data()["description"],
      postTitle: doc.data()["postTitle"],
      postMediaUrl: doc.data()["postMediaUrl"],
      likes: doc.data()['likes'],
      subHeading: doc.data()['subHeading'],
      videoLink: doc.data()['videoLink'],
    );
  }
  int getLikeCount(likes) {
    if (likes == null) {
      return 0;
    }
    int count = 0;
    likes.values.forEach((val) {
      if (val) {
        count += 1;
      }
    });
    return count;
  }

  @override
  _PostState createState() => _PostState(
      postId: this.postId,
      ownerId: this.ownerId,
      userName: this.userName,
      description: this.description,
      postMediaUrl: this.postMediaUrl,
      postTitle: this.postTitle,
      likes: this.likes,
      likeCount: getLikeCount(likes),
      subHeading: this.subHeading,
      videoLink: this.videoLink);
}

class _PostState extends State<Post> {
  bool _isLiked = false;
  bool showHeart = false;
  final String currentUserId = currentUser?.id;
  final String postId;
  final String ownerId;
  final String userName;
  final String postTitle;
  final String description;
  final String subHeading;
  final String postMediaUrl;
  final String videoLink;
  //AnimationController _controller;
  int likeCount;
  Map likes;
  _PostState({
    this.postId,
    this.ownerId,
    this.userName,
    this.postTitle,
    this.description,
    this.postMediaUrl,
    this.likes,
    this.likeCount,
    this.subHeading,
    this.videoLink,
  });

  YoutubePlayerController _ytController;

  List allAdmins = [];
  @override
  initState() {
    _ytController = YoutubePlayerController(
      initialVideoId: videoLink != null ? videoLink : "",
      flags: YoutubePlayerFlags(
        autoPlay: false,
        hideThumbnail: false,
        controlsVisibleAtStart: true,
        mute: false,
      ),
    );
    super.initState();
    getAdmins();
  }

  getAdmins() async {
    QuerySnapshot snapshots =
        await userRef.where('type', isEqualTo: 'admin').get();
    snapshots.docs.forEach((e) {
      allAdmins.add(AppUser.fromDocument(e));
    });
  }

  @override
  dispose() {
    _ytController.dispose();
    super.dispose();
  }

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
      future: userRef.doc(ownerId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return bouncingGridProgress();
        }
        AppUser user = AppUser.fromDocument(snapshot.data);
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    postTitle,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  Text(subHeading != null ? subHeading : description),
                ],
              ),
            ),
            isAdmin
                ? IconButton(
                    onPressed: () => handleOptionPost(context),
                    icon: Icon(Icons.more_vert),
                  )
                : Text(''),
          ],
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
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: neumorphicTile(
                    padding: 12,
                    anyWidget: Text(
                      'Edit',
                    ),
                  ),
                ),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context);
                  deletePost();
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: neumorphicTile(
                    padding: 12,
                    anyWidget: Text(
                      'Delete',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ),
              ),
              SimpleDialogOption(
                onPressed: () => Navigator.pop(context),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: neumorphicTile(padding: 12, anyWidget: Text('Cancel')),
                ),
              )
            ],
          );
        });
  }

  handleLikePosts() {
    _isLiked = likes[currentUserId] == true;
    if (_isLiked) {
      postsRef
          .doc(ownerId)
          .collection('adminPosts')
          .doc(postId)
          .update({'likes.$currentUserId': false});
      timelineRef.doc(postId).update({'likes.$currentUserId': false});
      removeLikeFromActivityFeed();
      setState(() {
        likeCount -= 1;
        _isLiked = false;
        likes[currentUserId] = false;
      });
    } else if (!_isLiked) {
      postsRef
          .doc(ownerId)
          .collection('adminPosts')
          .doc(postId)
          .update({'likes.$currentUserId': true});
      timelineRef.doc(postId).update({'likes.$currentUserId': true});
      addLikeToActivityFeed();
      setState(() {
        likeCount += 1;
        _isLiked = true;
        showHeart = true;
        likes[currentUserId] = true;
      });
      Timer(Duration(milliseconds: 500), () {
        setState(() {
          showHeart = false;
        });
      });
    }
  }

  removeLikeFromActivityFeed() {
    bool isNotPostOwner = currentUserId != ownerId;
    if (isNotPostOwner) {
      activityFeedRef
          .doc(ownerId)
          .collection("feedItems")
          .doc(postId)
          .get()
          .then((doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      });
    }
  }

  addLikeToActivityFeed() async {
    bool isNotProductOwner = ownerId != currentUser.id;
    print(allAdmins);
    if (isNotProductOwner) {
      allAdmins.forEach((element) {
        activityFeedRef.doc(element.id).collection('feedItems').add({
          "type": "like",
          "commentData": "Liked Post",
          "userName": currentUser.userName,
          "userId": currentUser.id,
          "userProfileImg": currentUser.photoUrl,
          "postId": postId,
          "mediaUrl": postMediaUrl,
          "timestamp": timestamp,
        });
        sendAndRetrieveMessage(
            token: element.androidNotificationToken,
            message: "${currentUser.userName} liked your post $postTitle",
            title: "Liked Product");
      });
    }
  }

//Note:to delete Post,ownerId and currentUserId must be equal, so they can be used interchangeably
  deletePost() async {
    postsRef
        .doc(ownerId)
        .collection('adminPosts')
        .doc(postId)
        .get()
        .then((doc) {
      if (doc.exists) {}
      doc.reference.delete();
      timelineRef.doc(postId).get().then((value) {
        if (value.exists) {
          value.reference.delete();
        }
      });
    });
    //delete post from storage
    storageRef.child("post_$postId.jpg").delete();
    //then delete all activityFeed notifications

    //then delete all comments
    QuerySnapshot commentSnapshot =
        await commentsRef.doc(postId).collection('comments').get();

    commentSnapshot.docs.forEach((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });

    BotToast.showText(text: "Post Deleted Please Refresh");
  }

  GestureDetector buildPostImage() {
    return GestureDetector(
      onDoubleTap: handleLikePosts,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          cachedNetworkImage(postMediaUrl),
          showHeart
              ? Animator<double>(
                  duration: Duration(milliseconds: 500),
                  cycles: 0,
                  curve: Curves.elasticOut,
                  tween: Tween<double>(begin: 0.8, end: 1.6),
                  builder: (context, anim, child) {
                    return Transform.scale(
                      scale: anim.value,
                      child: Icon(
                        _isLiked ? Icons.favorite : Icons.favorite_border,
                        color: Colors.white,
                        size: 80.0,
                      ),
                    );
                  },
                )
              : Text(""),
        ],
      ),
    );
  }

  buildPostVideo() {
    return YoutubePlayer(
      controller: _ytController,
      showVideoProgressIndicator: true,
      aspectRatio: 1,
    );
  }

  buildPostFooter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: [
            GestureDetector(
              onTap: handleLikePosts,
              child: Icon(
                _isLiked ? Icons.favorite : Icons.favorite_border,
                size: 28.0,
              ),
            ),
            Padding(padding: EdgeInsets.only(right: 10.0)),
            GestureDetector(
              onTap: () => showComments(
                context,
                mediaUrl: postMediaUrl,
                postId: postId,
                ownerId: ownerId,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Padding(padding: EdgeInsets.only(top: 40.0)),
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 28,
                  ),
                ],
              ),
            ),
          ],
        ),
        Padding(
          padding: EdgeInsets.only(left: 10.0),
          child: Text(
            '$likeCount likes',
            style: TextStyle(
              fontStyle: FontStyle.italic,
              fontSize: 20.0,
            ),
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 20.0),
            ),
            Expanded(
              child: Text(
                description,
                style: TextStyle(wordSpacing: 2, fontSize: 14.0),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 20.0, top: 10.0),
          child: GestureDetector(
            onTap: () => showComments(
              context,
              mediaUrl: postMediaUrl,
              postId: postId,
              ownerId: ownerId,
            ),
            child: Text(
              "View All Comments",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15.0,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    _isLiked = likes[currentUserId] == true;
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Container(
        decoration: nMBox,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: <Widget>[
              buildPostHeader(),
              videoLink == null ? buildPostImage() : buildPostVideo(),
              buildPostFooter(),
            ],
          ),
        ),
      ),
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
              videoLink: videoLink,
              subHeading: subHeading,
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
    return CommentsNChat(
      postId: postId,
      isProductComment: false,
      postOwnerId: ownerId,
      postMediaUrl: mediaUrl,
      isPostComment: true,
    );
  }));
}
