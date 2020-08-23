import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kannapy/models/users.dart';
import 'package:kannapy/tools/progress.dart';
import 'package:kannapy/userScreens/home.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as Im;
import 'package:uuid/uuid.dart';

class EditPosts extends StatefulWidget {
  final String description, postTitle, mediaUrl, postId, currentUserId;

  EditPosts(
      {this.description,
      this.mediaUrl,
      this.postTitle,
      this.postId,
      this.currentUserId});
  @override
  _EditPostsState createState() => _EditPostsState();
}

class _EditPostsState extends State<EditPosts> {
  final _textFormkey = GlobalKey<FormState>();
  File file;
  bool isUploading = false;
  String postId;
  String postTitle, postDescription;

  TextEditingController postTitleController = TextEditingController();
  TextEditingController postDescriptionController = TextEditingController();

  ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    postId = widget.postId;
    postTitle = widget.postTitle;
    postDescription = widget.description;
    postDescriptionController.text = widget.description;
    postTitleController.text = widget.postTitle;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Upload Posts"),
        actions: [
          Padding(
            padding: EdgeInsets.all(10.0),
            child: RaisedButton.icon(
              onPressed: () => selectImage(context),
              icon: Icon(
                Icons.add_a_photo,
                size: 20.0,
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8.0))),
              label: Text(
                'Add Images',
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
                      controller: postTitleController,
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
                      onSaved: (val) => postDescription = val,
                      validator: (val) => val.trim().length < 1
                          ? 'Please add Product description'
                          : null,
                      controller: postDescriptionController,
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
                  RaisedButton(
                    onPressed: isUploading ? null : () => handleSubmit(),
                    padding: EdgeInsets.only(
                        left: 20.0, right: 20.0, bottom: 10.0, top: 10.0),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8.0))),
                    child: Text(
                      'Upload Post',
                      style: TextStyle(fontSize: 20.0),
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
          title: Text("Create Post"),
          children: <Widget>[
            SimpleDialogOption(
                child: Text("Select Image"), onPressed: handleImageFromGallery),
            SimpleDialogOption(child: Text("Select Video"), onPressed: () {}),
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
    StorageUploadTask uploadTask =
        storageRef.child("post_$postId.jpg").putFile(imageFile);
    StorageTaskSnapshot storageSnap = await uploadTask.onComplete;
    String downloadUrl = await storageSnap.ref.getDownloadURL();
    return downloadUrl;
  }

  createPostInFirestore(
      {String postMediaUrl, String postTitle, String description}) {
    postsRef
        .document(widget.currentUserId)
        .collection("adminPosts")
        .document(postId)
        .updateData({
      "postId": postId,
      "postTitle": postTitle,
      "postMediaUrl": postMediaUrl,
      "description": description,
      "timestamp": timestamp,
    });
    timelineRef.document(postId).setData({
      "postId": postId,
      "postTitle": postTitle,
      "postMediaUrl": postMediaUrl,
      "description": description,
      "timestamp": timestamp,
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
        postTitle: postTitleController.text,
        description: postDescriptionController.text,
      );
      setState(() {
        file = null;
        isUploading = false;
      });

      postTitleController.clear();
      postDescriptionController.clear();
      Navigator.pop(context);

      BotToast.showText(
          text: "Edited Successfully Please Refresh!",
          duration: Duration(
            seconds: 2,
          ));
    }
  }
}
