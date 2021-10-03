import 'package:bot_toast/bot_toast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kannapy/models/users.dart';
import 'package:kannapy/tools/notificationHandler.dart';
import 'package:kannapy/tools/progress.dart';
import 'package:kannapy/tools/uiFunctions.dart';
import 'package:kannapy/userScreens/home.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:uuid/uuid.dart';

class CommentsNChat extends StatefulWidget {
  final String postId;
  final String postOwnerId;
  final String chatId;
  final String postMediaUrl;
  final String heroMsg;
  final bool isPostComment;
  final bool isProductComment;
  final String chatNotificationToken;
//  final String userName;
  CommentsNChat(
      {this.postId,
      this.postMediaUrl,
      this.postOwnerId,
      this.chatId,
      this.heroMsg,
      @required this.isPostComment,
      this.chatNotificationToken,
      @required this.isProductComment});
  @override
  CommentsNChatState createState() => CommentsNChatState(
        postId: this.postId,
        postMediaUrl: this.postMediaUrl,
        postOwnerId: this.postOwnerId,
        isComment: this.isPostComment,
        isProductComment: this.isProductComment,
      );
}

TextEditingController _commentNMessagesController = TextEditingController();

class CommentsNChatState extends State<CommentsNChat> {
  final String postId;
  final String postOwnerId;
  final String postMediaUrl;
  final bool isComment;
  final bool isProductComment;
//  final String userName;
  CommentsNChatState({
    @required this.postId,
    this.postMediaUrl,
    this.postOwnerId,
    this.isComment,
    this.isProductComment,
  });
  List<AppUser> allAdmins = [];
  String chatHeadId;
  List<CommentsNMessages> commentsListGlobal = [];
  buildComments() {
    return StreamBuilder(
      stream: commentsRef
          .doc(postId)
          .collection("comments")
          .orderBy("timestamp", descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return bouncingGridProgress();
        }
        List<CommentsNMessages> commentsList = [];
        snapshot.data.documents.forEach((doc) {
          commentsList.add(CommentsNMessages.fromDocument(doc));
          commentsListGlobal.add(CommentsNMessages.fromDocument(doc));
        });

        return ListView(
          children: commentsList,
        );
      },
    );
  }

  getAdmins() async {
    QuerySnapshot snapshots =
        await userRef.where('type', isEqualTo: 'admin').get();
    snapshots.docs.forEach((e) {
      allAdmins.add(AppUser.fromDocument(e));
    });
  }

  @override
  initState() {
    super.initState();
    if (mounted) {
      setState(() {
        chatHeadId = isAdmin ? widget.chatId : currentUser.id;
      });
    }
    getAdmins();
  }

  buildChat() {
    print(widget.chatId);
    return StreamBuilder(
      stream: chatRoomRef
          .doc(isAdmin ? widget.chatId : currentUser.id)
          .collection("chats")
          .orderBy("timestamp", descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return bouncingGridProgress();
        }
        List<CommentsNMessages> chatMessages = [];
        snapshot.data.documents.forEach((doc) {
          chatMessages.add(CommentsNMessages.fromDocument(doc));
        });
        return ListView(
          children: chatMessages,
        );
      },
    );
  }

  addComment() async {
    String commentId = Uuid().v1();
    if (_commentNMessagesController.text.trim().length > 1 &&
        !_commentNMessagesController.text.contains("@")) {
      if (commentsListGlobal.isNotEmpty) {
        for (int i = 0; i < commentsListGlobal.length; i++) {
          if (_commentNMessagesController.text
              .contains("@${commentsListGlobal[i].userName}")) {
            await activityFeedRef
                .doc(commentsListGlobal[i].userId)
                .collection('feedItems')
                .add({
              "type": "commentMention",
              "commentData": _commentNMessagesController.text,
              "userName": currentUser.userName,
              "userId": currentUser.id,
              "userProfileImg": currentUser.photoUrl,
              "postId": postId,
              "mediaUrl": postMediaUrl,
              "timestamp": timestamp,
            });
            sendAndRetrieveMessage(
                token: commentsListGlobal[i].androidNotificationToken,
                message: _commentNMessagesController.text,
                title: "Mentioned in Comment");
            break;
          }
        }
      }
      //     else{
      //   activityFeedRef.doc(postOwnerId).collection('feedItems').add({
      //     "type": "commentMention",
      //     "commentData": _commentNMessagesController.text,
      //     "userName": currentUser.userName,
      //     "userId": currentUser.id,
      //     "userProfileImg": currentUser.photoUrl,
      //     "postId": postId,
      //     "mediaUrl": postMediaUrl,
      //     "timestamp": timestamp,
      //   });
      //
      // }
      commentsRef.doc(postId).collection("comments").doc(commentId).set({
        "userName": currentUser.userName,
        "userId": currentUser.id,
        "androidNotificationToken": currentUser.androidNotificationToken,
        "comment": _commentNMessagesController.text,
        "timestamp": timestamp,
        "avatarUrl": currentUser.photoUrl,
        "isComment": widget.isPostComment,
        "isProductComment": widget.isProductComment,
        "postId": postId,
        "commentId": commentId,
        "likesMap": {},
        "likes": 0,
      });

      sendNotificationToAdmin(
        type: "comment",
        isAdminChat: false,
      );
    } else {
      BotToast.showText(text: "Comment shouldn't be left Empty");
    }
    _commentNMessagesController.clear();
  }

  void sendNotificationToAdmin(
      {@required String type, String title, @required bool isAdminChat}) {
    isProductComment
        ? title = "Commented on product"
        : title = "Commented on post";
    bool isNotPostOwner = postOwnerId != currentUser.id;
    if (isNotPostOwner) {
      allAdmins.forEach((element) {
        activityFeedRef.doc(element.id).collection('feedItems').add({
          "type": "comment",
          "commentData": _commentNMessagesController.text,
          "userName": currentUser.userName,
          "userId": currentUser.id,
          "userProfileImg": currentUser.photoUrl,
          "postId": postId,
          "mediaUrl": postMediaUrl,
          "timestamp": timestamp,
        });
        sendAndRetrieveMessage(
            token: element.androidNotificationToken,
            message: _commentNMessagesController.text,
            title: isAdminChat ? "Admin Chats" : title);
      });
    }
  }

  addChatMessage() {
    String commentId = Uuid().v1();
    if (_commentNMessagesController.text.trim().length > 1) {
      chatRoomRef
          .doc(isAdmin ? widget.chatId : currentUser.id)
          .collection("chats")
          .doc(commentId)
          .set({
        "userName": currentUser.userName,
        "userId": currentUser.id,
        "androidNotificationToken": currentUser.androidNotificationToken,
        "comment": _commentNMessagesController.text,
        "timestamp": timestamp,
        "avatarUrl": currentUser.photoUrl,
        "isComment": widget.isPostComment,
        "isProductComment": widget.isProductComment,
        "commentId": commentId,
      });
      // chatListRef.doc(isAdmin ? widget.chatId : currentUser.id).set({
      //   "userName": currentUser.userName,
      //   "userId": currentUser.id,
      //   "comment": _commentNMessagesController.text,
      //   "timestamp": timestamp,
      //   "androidNotificationToken": widget.chatNotificationToken,
      //   "avatarUrl": currentUser.photoUrl,
      //   "isComment": widget.isComment,
      //   "isProductComment": widget.isProductComment,
      // });
      sendNotificationToAdmin(
          type: "adminChats", title: "Admin Chats", isAdminChat: true);
      if (isAdmin) {
        activityFeedRef.doc(widget.chatId).collection('feedItems').add({
          "type": "adminChats",
          "commentData": _commentNMessagesController.text,
          "userName": currentUser.userName,
          "userId": currentUser.id,
          "userProfileImg": currentUser.photoUrl,
          "postId": widget.chatId,
          "mediaUrl": postMediaUrl,
          "timestamp": timestamp,
        });
        sendAndRetrieveMessage(
            token: widget.chatNotificationToken,
            message: _commentNMessagesController.text,
            title: "Admin Chats");
      }
    } else {
      BotToast.showText(
          text: widget.isPostComment || widget.isProductComment
              ? "Comment field shouldn't be left Empty"
              : "Message field shouldn't be left Empty");
    }
    _commentNMessagesController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.isPostComment || widget.isProductComment
            ? 'COMMENTS'
            : "Contact Admin"),
      ),
      body: Padding(
        padding: const EdgeInsets.only(bottom: 20.0),
        child: Column(
          children: <Widget>[
            Expanded(
              child: widget.isPostComment || widget.isProductComment
                  ? buildComments()
                  : buildChat(),
            ),
            Divider(),
            neumorphicTile(
              padding: 8,
              anyWidget: ListTile(
                title: TextFormField(
                  controller: _commentNMessagesController,
                  decoration: InputDecoration(
                    hintText: widget.isPostComment || widget.isProductComment
                        ? "Write a Comment..."
                        : "Write admin a message...",
                  ),
                ),
                trailing: IconButton(
                  onPressed: widget.isPostComment || widget.isProductComment
                      ? addComment
                      : addChatMessage,
                  icon: Icon(
                    Icons.send,
                    size: 40.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CommentsNMessages extends StatefulWidget {
  final String userName;
  final String userId;
  final String avatarUrl;
  final String comment;
  final Timestamp timestamp;
  final bool isComment;
  final bool isProductComment;
  final String commentId;
  final Map likesMap;
  final Map nestedCommentsMap;
  final int likes;
  final String postId;
  final String androidNotificationToken;
  CommentsNMessages({
    this.userName,
    this.userId,
    this.avatarUrl,
    this.comment,
    this.timestamp,
    this.isComment,
    this.commentId,
    this.likes,
    this.likesMap,
    this.isProductComment,
    this.nestedCommentsMap,
    this.androidNotificationToken,
    @required this.postId,
  });
  factory CommentsNMessages.fromDocument(DocumentSnapshot doc) {
    return CommentsNMessages(
      avatarUrl: doc.data()['avatarUrl'],
      comment: doc.data()['comment'],
      timestamp: doc.data()['timestamp'],
      userId: doc.data()['userId'],
      userName: doc.data()['userName'],
      isComment: doc.data()['isComment'],
      commentId: doc.data()["commentId"],
      likes: doc.data()["likes"],
      likesMap: doc.data()["likesMap"],
      postId: doc.data()["postId"],
      nestedCommentsMap: doc.data()["nestedCommentsMap"],
      androidNotificationToken: doc.data()["androidNotificationToken"],
      isProductComment: doc.data()["isProductComment"],
    );
  }

  @override
  _CommentsNMessagesState createState() => _CommentsNMessagesState();
}

class _CommentsNMessagesState extends State<CommentsNMessages> {
  var commentLikes;
  bool _isLiked = false;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12, right: 12, left: 12),
      child: widget.isComment || widget.isProductComment
          ? buildCommentBubble()
          : buildMessageBubble(context),
    );
  }

  buildCommentBubble() {
    commentLikes = widget.likes;
    _isLiked = widget.likesMap[currentUser.id] == true;
    return neumorphicTile(
      padding: 12,
      anyWidget: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Row(
            children: [
              CircleAvatar(
                backgroundImage: CachedNetworkImageProvider(widget.avatarUrl),
              ),
              SizedBox(
                width: 8,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Text("${widget.userName} : ",
                            style:
                                TextStyle(fontSize: 14.0, color: Colors.black)),
                        Flexible(
                          child: Text(
                            "${widget.comment}",
                            style:
                                TextStyle(fontSize: 14.0, color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      timeago.format(widget.timestamp.toDate()),
                      style: TextStyle(color: Colors.black54, fontSize: 12),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Row(
                      children: [
                        GestureDetector(
                            onTap: () async {
                              if (_isLiked) {
                                setState(() {
                                  commentLikes -= 1;
                                  _isLiked = false;
                                });
                                await commentsRef
                                    .doc(widget.postId)
                                    .collection("comments")
                                    .doc(widget.commentId)
                                    .update({
                                  "likes": commentLikes,
                                  "likesMap": {currentUser.id: false}
                                });
                                BotToast.showText(text: "Like Removed");
                              } else {
                                setState(() {
                                  commentLikes += 1;
                                  _isLiked = true;
                                });
                                await commentsRef
                                    .doc(widget.postId)
                                    .collection("comments")
                                    .doc(widget.commentId)
                                    .update({
                                  "likes": commentLikes,
                                  "likesMap": {currentUser.id: true}
                                });
                                activityFeedRef
                                    .doc(widget.postId)
                                    .collection('feedItems')
                                    .add({
                                  "type": "comment",
                                  "commentData":
                                      _commentNMessagesController.text,
                                  "userName": currentUser.userName,
                                  "userId": currentUser.id,
                                  "userProfileImg": currentUser.photoUrl,
                                  "postId": widget.postId,
                                  "mediaUrl": widget.avatarUrl,
                                  "timestamp": timestamp,
                                });
                                sendAndRetrieveMessage(
                                    token: widget.androidNotificationToken,
                                    message: _commentNMessagesController.text,
                                    title: "Comment Liked");

                                BotToast.showText(text: "Comment Liked");
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8, right: 8),
                              child: Text("$commentLikes  Like"),
                            )),
                        GestureDetector(
                            onTap: () {
                              _commentNMessagesController.text =
                                  "@${widget.userName} ";
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8, right: 8),
                              child: Text("Reply"),
                            ))
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  buildMessageBubble(BuildContext context) {
    bool isMe = currentUser.id == widget.userId;
    return Container(
      width: MediaQuery.of(context).size.width * 0.5,
      decoration: BoxDecoration(
        color: isMe ? Colors.cyan : Colors.black26,
        borderRadius: isMe
            ? BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
                topLeft: Radius.circular(20),
              )
            : BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                CircleAvatar(
                  backgroundImage: CachedNetworkImageProvider(widget.avatarUrl),
                ),
                SizedBox(
                  width: 8,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Text("${widget.userName} : ",
                              style: TextStyle(
                                  fontSize: 14.0, color: Colors.black)),
                          Flexible(
                            child: Text(
                              "${widget.comment}",
                              style: TextStyle(
                                  fontSize: 14.0, color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        timeago.format(widget.timestamp.toDate()),
                        style: TextStyle(color: Colors.black54, fontSize: 12),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
