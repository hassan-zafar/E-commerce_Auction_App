import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image/image.dart' as Im;
import 'package:image_picker/image_picker.dart';
import 'package:kannapy/tools/progress.dart';
import 'package:kannapy/tools/uiFunctions.dart';
import 'package:kannapy/userScreens/home.dart';
import 'package:path_provider/path_provider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class EditPosts extends StatefulWidget {
  final String description,
      postTitle,
      mediaUrl,
      postId,
      currentUserId,
      subHeading,
      videoLink;

  EditPosts(
      {this.description,
      this.mediaUrl,
      this.postTitle,
      this.postId,
      this.currentUserId,
      this.subHeading,
      this.videoLink});
  @override
  _EditPostsState createState() => _EditPostsState();
}

class _EditPostsState extends State<EditPosts> {
  final _textFormkey = GlobalKey<FormState>();
  File file;
  bool isUploading = false;
  String postId;
  String postTitle, postDescription, postSubheading, videoLink;

  TextEditingController _postTitleController = TextEditingController();
  TextEditingController _postDescriptionController = TextEditingController();
  TextEditingController _postSubHeadController = TextEditingController();
  TextEditingController _videoLinkController = TextEditingController();

  ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    postId = widget.postId;
    postTitle = widget.postTitle;
    postDescription = widget.description;
    postSubheading = widget.subHeading;
    videoLink = widget.videoLink;
    _postDescriptionController.text = widget.description;
    _postTitleController.text = widget.postTitle;
    _postSubHeadController.text = widget.subHeading;
    _videoLinkController.text = widget.videoLink;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Update Posts"),
        actions: [
          Padding(
            padding: EdgeInsets.all(10.0),
            child: RaisedButton.icon(
              onPressed: () => buildMediaDialog(context),
              icon: Icon(
                Icons.add,
                size: 20.0,
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8.0))),
              label: Text(
                'Update Media',
                style: TextStyle(fontSize: 10.0),
              ),
            ),
          )
        ],
      ),
      body: ListView(
        controller: _scrollController,
        children: [
          isUploading ? linearProgress() : Text(""),
          file == null
              ? Container(
                  height: 220.0,
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Image(
                        image: CachedNetworkImageProvider(widget.mediaUrl),
                      ),
                    ),
                  ),
                )
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
                      validator: (val) =>
                          val.trim().length < 3 ? 'Post Title Too Short' : null,
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
                      padding: const EdgeInsets.all(8.0),
                      child: neumorphicTile(
                        padding: 8,
                        anyWidget: Container(
                          width: 150,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              FaIcon(FontAwesomeIcons.upload),
                              SizedBox(
                                width: 5,
                              ),
                              Text(
                                'Update Post',
                                style: TextStyle(fontSize: 20.0),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              )),
        ],
      ),
    );
  }

  selectImage(parentContext) {
    return showDialog(
      context: parentContext,
      builder: (context) {
        return SimpleDialog(
          title: Text("Upload Image"),
          children: <Widget>[
            SimpleDialogOption(
                child: Text("Select Image"), onPressed: handleImageFromGallery),
            // SimpleDialogOption(child: Text("Select Video"), onPressed: () {}),
            SimpleDialogOption(
              child: Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            )
          ],
        );
      },
    );
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

  Future<String> uploadImage(imageFile) async {
    UploadTask uploadTask =
        storageRef.child("post_$postId.jpg").putFile(imageFile);
    // TaskSnapshot storageSnap = await uploadTask.onComplete;
    // String downloadUrl = await storageSnap.ref.getDownloadURL();
    // return downloadUrl;
    String downloadUrl;
    //TaskSnapshot storageSnap = await
    uploadTask.then((res) async {
      downloadUrl = await res.ref.getDownloadURL();
    });
    return downloadUrl;
  }

  createPostInFirestore(
      {String postMediaUrl,
      String postTitle,
      String description,
      String subHeading,
      String videoLink}) {
    postsRef
        .doc(widget.currentUserId)
        .collection("adminPosts")
        .doc(postId)
        .update({
      "postId": postId,
      "postTitle": postTitle,
      "postMediaUrl": postMediaUrl,
      "description": description,
      "subHeading": subHeading,
      "timestamp": timestamp,
      "videoLink": videoLink,
    });
    timelineRef.doc(postId).update({
      "postId": postId,
      "postTitle": postTitle,
      "postMediaUrl": postMediaUrl,
      "description": description,
      "timestamp": timestamp,
      "subHeading": subHeading,
      "videoLink": videoLink,
    });
  }

  handleSubmit() async {
    final _form = _textFormkey.currentState;
    if (_form.validate()) {
      setState(() {
        isUploading = true;
      });
      _scrollController.animateTo(0.0,
          duration: Duration(milliseconds: 500), curve: Curves.easeOut);
      if (file != null) await compressImage();

      String postMediaUrl =
          file != null ? await uploadImage(file) : widget.mediaUrl;

      createPostInFirestore(
        postMediaUrl: postMediaUrl,
        postTitle: _postTitleController.text,
        description: _postDescriptionController.text,
        subHeading: _postSubHeadController.text,
        videoLink: videoLink,
      );
      setState(() {
        file = null;
        isUploading = false;
      });

      _postTitleController.clear();
      _postDescriptionController.clear();
      _postSubHeadController.clear();
      Navigator.pop(context);

      BotToast.showText(
          text: "Edited Successfully Please Refresh!",
          duration: Duration(
            seconds: 2,
          ));
    }
  }

  buildMediaDialog(BuildContext parentContext) {
    return showDialog(
        context: parentContext,
        builder: (context) {
          return SimpleDialog(
            children: <Widget>[
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context);
                  selectImage(parentContext);
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
                  onSaved: (val) => _videoLinkController.text = val,
                  validator: (val) =>
                      val.trim().length <= 4 ? "Enter Valid URL!" : null,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Enter YouTube URL",
                    hintText: "URL Must be Valid",
                  ),
                  controller: _videoLinkController,
                ),
              ),
              RaisedButton.icon(
                elevation: 6,
                padding: EdgeInsets.all(6),
                onPressed: () {
                  final _form = _textFormKey.currentState;
                  if (_form.validate()) {
                    setState(() {
                      videoLink = YoutubePlayer.convertUrlToId(
                          _videoLinkController.text);
                    });
                    print(videoLink);
                    BotToast.showText(
                        text: "Url Added",
                        duration: Duration(microseconds: 300),
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
