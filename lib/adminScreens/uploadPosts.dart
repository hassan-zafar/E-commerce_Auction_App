import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image/image.dart' as Im;
import 'package:image_picker/image_picker.dart';
import 'package:kannapy/models/users.dart';
import 'package:kannapy/tools/progress.dart';
import 'package:kannapy/tools/uiFunctions.dart';
import 'package:kannapy/userScreens/home.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class UploadPosts extends StatefulWidget {
  final AppUser currentUser;
  UploadPosts({this.currentUser});
  @override
  _UploadPostsState createState() => _UploadPostsState();
}

class _UploadPostsState extends State<UploadPosts> {
  final _textFormkey = GlobalKey<FormState>();
  File file;
  String postId = Uuid().v4();
  bool isUploading = false;
  String postTitle, postDescription, postSubheading, videoLink;
  ScrollController _scrollController = ScrollController();
  TextEditingController _postTitleController = TextEditingController();
  TextEditingController _postDescriptionController = TextEditingController();
  TextEditingController _postSubHeadController = TextEditingController();
  TextEditingController _urlController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Upload Posts"),
        actions: [
          Padding(
            padding: EdgeInsets.all(10.0),
            child: RaisedButton.icon(
              onPressed: () {
                buildMediaDialog(context);
              },
              icon: Icon(
                Icons.add,
                size: 20.0,
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8.0))),
              label: Text(
                'Add Media',
                style: TextStyle(fontSize: 10.0),
              ),
            ),
          )
        ],
      ),
      body: WillPopScope(
        onWillPop: _onBackPressed,
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            children: [
              isUploading ? linearProgress() : Text(""),
              file == null
                  ? Container()
                  : Container(
                      height: 220.0,
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: Center(
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                fit: BoxFit.cover,
                                image: FileImage(file),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
              Form(
                  key: _textFormkey,
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: 25.0,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 18.0, right: 18.0),
                        child: TextFormField(
                          onSaved: (val) => postTitle = val,
                          validator: (val) => val.trim().length < 3
                              ? 'Post Title Too Short'
                              : null,
                          controller: _postTitleController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                                // borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                ),
                            labelText: "Post Title",
                            hintText: "Min length 3",
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 25.0,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 18.0, right: 18.0),
                        child: TextFormField(
                          onSaved: (val) => postSubheading = val,
                          validator: (val) => val.trim().length < 3
                              ? 'Post Sub heading Too Short'
                              : null,
                          controller: _postSubHeadController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                                // borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                ),
                            labelText: "Post Sub Heading",
                            hintText: "Min length 3",
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 25.0,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 18.0, right: 18.0),
                        child: TextFormField(
                          onSaved: (val) => postDescription = val,
                          validator: (val) => val.trim().length < 1
                              ? 'Please add Product description'
                              : null,
                          controller: _postDescriptionController,
                          maxLines: 7,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: "Post Description",
                            hintText: "Add description of this Post",
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 25.0,
                      ),
                      GestureDetector(
                        onTap: isUploading ? null : () => handleSubmit(),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: neumorphicTile(
                            padding: 16,
                            anyWidget: Text(
                              'Upload Post',
                              style: TextStyle(fontSize: 20.0),
                            ),
                          ),
                        ),
                      )
                    ],
                  )),
            ],
          ),
        ),
      ),
    );
  }

  compressImage() async {
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    Im.Image imageFile = Im.decodeImage(file.readAsBytesSync());
    final compressedImageFile = File('$path/img_$postId.jpg')
      ..writeAsBytesSync(Im.encodeJpg(imageFile, quality: 85));
    setState(() {
      file = compressedImageFile;
    });
  }

  handleImageFromGallery() async {
    Navigator.pop(context);
    var picker = await ImagePicker().getImage(source: ImageSource.gallery);
    File file;
    print(file.toString());
    file = File(picker.path);
    setState(() {
      this.file = file;
    });
  }

  Future<String> uploadImage(imageFile) async {
    Reference firebaseStorageRef =
        FirebaseStorage.instance.ref().child('posts/$postId.jpg');
    UploadTask uploadTask = firebaseStorageRef.putFile(imageFile);
    // storageRef.child("post_$postId.jpg").putFile(imageFile);
    // TaskSnapshot storageSnap = await uploadTask.onComplete;
    // String downloadUrl = await storageSnap.ref.getDownloadURL();
    // return downloadUrl;

    String downloadUrl;
    await uploadTask.whenComplete(() async {
      downloadUrl = await firebaseStorageRef.getDownloadURL();
    });
    // uploadTask.then((res) async {
    //   downloadUrl = await res.ref.getDownloadURL();
    // });
    return downloadUrl;
  }

  createPostInFirestore(
      {String postMediaUrl,
      String postTitle,
      String description,
      String subHeading,
      String videoLink}) {
    postsRef
        .doc(widget.currentUser.id)
        .collection("adminPosts")
        .doc(postId)
        .set({
      "postId": postId,
      "ownerId": widget.currentUser.id,
      "userName": widget.currentUser.userName,
      "postTitle": postTitle,
      "subHeading": subHeading,
      "postMediaUrl": postMediaUrl,
      "description": description,
      "timestamp": timestamp,
      "videoLink": videoLink,
      'likes': {},
    });
    timelineRef.doc(postId).set({
      "postId": postId,
      "ownerId": widget.currentUser.id,
      "userName": widget.currentUser.userName,
      "postTitle": postTitle,
      "postMediaUrl": postMediaUrl,
      "description": description,
      "timestamp": timestamp,
      "subHeading": subHeading,
      "videoLink": videoLink,
      'likes': {},
    });
  }

  handleSubmit() async {
    print(file);
    print(videoLink);
    final _form = _textFormkey.currentState;
    if (videoLink == null && file == null) {
      BotToast.showText(text: "Image / Video URL must be Selected");
    } else {
      if (_form.validate()) {
        setState(() {
          isUploading = true;
        });
        _scrollController.animateTo(0.0,
            duration: Duration(milliseconds: 600), curve: Curves.easeOut);
        // ignore: unnecessary_statements
        file != null ? await compressImage() : null;
        String postMediaUrl = file != null
            ? await uploadImage(file).catchError((onError) {
                isUploading = false;
                BotToast.showText(text: "Couldn't connect to servers!!");
              })
            : "";
        await createPostInFirestore(
            postMediaUrl: postMediaUrl,
            postTitle: _postTitleController.text,
            description: _postDescriptionController.text,
            subHeading: _postSubHeadController.text,
            videoLink: videoLink);
        _postTitleController.clear();
        _postDescriptionController.clear();
        _postSubHeadController.clear();
        _urlController.clear();
        setState(() {
          file = null;
          isUploading = false;
          postId = Uuid().v4();
        });
        Navigator.pop(context);
      }
      BotToast.showText(text: "Post Uploaded");
    }
  }

  Future<bool> _onBackPressed() {
    isUploading
        ? BotToast.showText(text: "Sorry can't go back as post is being added")
        : Navigator.of(context).pop();
    return null;
  }

  buildMediaDialog(BuildContext parentContext) {
    return showDialog(
        context: parentContext,
        builder: (context) {
          return SimpleDialog(
            children: <Widget>[
              SimpleDialogOption(
                onPressed: () {
                  //Navigator.pop(context);
                  handleImageFromGallery();
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: neumorphicTile(
                    padding: 12,
                    anyWidget: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FaIcon(FontAwesomeIcons.image),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          'Upload Image',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context);
                  buildUrlAddDialog(context);
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: neumorphicTile(
                    padding: 12,
                    anyWidget: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FaIcon(FontAwesomeIcons.youtube),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          'Upload Video Url',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SimpleDialogOption(
                onPressed: () => Navigator.pop(context),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: neumorphicTile(
                      padding: 12,
                      anyWidget: Row(
                        children: [
                          Icon(Icons.exit_to_app),
                          SizedBox(
                            width: 5,
                          ),
                          Text('Cancel'),
                        ],
                      )),
                ),
              )
            ],
          );
        });
  }

  buildUrlAddDialog(BuildContext parentContext) {
    final _textFormKey = GlobalKey<FormState>();
    return showDialog(
        context: parentContext,
        builder: (context) {
          return SimpleDialog(
            elevation: 6,
            title: Center(child: Text("Enter Video URL")),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0)),
            titlePadding: EdgeInsets.all(12.0),
            contentPadding: EdgeInsets.all(12.0),
            children: [
              Form(
                key: _textFormKey,
                child: TextFormField(
                  onSaved: (val) => _urlController.text = val,
                  validator: (val) =>
                      val.trim().length <= 4 ? "Enter Valid URL!" : null,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Enter YouTube URL",
                    hintText: "URL Must be Valid",
                  ),
                  controller: _urlController,
                ),
              ),
              RaisedButton.icon(
                elevation: 6,
                padding: EdgeInsets.all(6),
                onPressed: () {
                  final _form = _textFormKey.currentState;
                  if (_form.validate()) {
                    setState(() {
                      videoLink =
                          YoutubePlayer.convertUrlToId(_urlController.text);
                    });
                    BotToast.showText(
                        text: "Url Added",
                        duration: Duration(milliseconds: 300),
                        onClose: () {
                          Navigator.pop(context);
                        });
                  }
                },
                icon: FaIcon(FontAwesomeIcons.youtubeSquare),
                label: Text("Video URL"),
              ),
            ],
          );
        });
  }
}
