import 'dart:async';
import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import "package:flutter/material.dart";
import 'package:image/image.dart' as Im;
import 'package:image_picker/image_picker.dart';
import 'package:kannapy/models/users.dart';
import 'package:kannapy/tools/progress.dart';
import 'package:path_provider/path_provider.dart';

import '../home.dart';

class EditProfile extends StatefulWidget {
  final String currentUserID;
  EditProfile({this.currentUserID});
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  TextEditingController displayNameController = TextEditingController();
  TextEditingController userNameController = TextEditingController();
  TextEditingController bioTextController = TextEditingController();
  AppUser user;
  String newPhotoUrl;
  bool isLoading = false;
  bool _bioValid = true;
  bool _displayNameValid = true;
  bool _isUpdating = false;
  bool _userNameValid = true;

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  File file;

  @override
  void initState() {
    getUser();
    super.initState();
  }

  getUser() async {
    setState(() {
      isLoading = true;
    });
    DocumentSnapshot doc = await userRef.doc(widget.currentUserID).get();
    user = AppUser.fromDocument(doc);
    displayNameController.text = user.displayName;
    bioTextController.text = user.bio;
    userNameController.text = user.userName;
    newPhotoUrl = user.photoUrl;
    setState(() {
      isLoading = false;
    });
  }

  Column buildDisplayField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 10),
          child: Text(
            "Display Name",
            style: TextStyle(color: Colors.grey),
          ),
        ),
        TextField(
          controller: displayNameController,
          decoration: InputDecoration(
            hintText: "Update Display Name",
            errorText: _displayNameValid ? null : "Name Too Short",
          ),
        ),
      ],
    );
  }

  Column buildUserField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 10),
          child: Text(
            "User Name",
            style: TextStyle(color: Colors.grey),
          ),
        ),
        TextField(
          controller: userNameController,
          decoration: InputDecoration(
            hintText: "Update User Name",
            errorText: _userNameValid ? null : "Name Too Short",
          ),
        ),
      ],
    );
  }

  Column buildBioField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 10),
          child: Text(
            "Bio",
            style: TextStyle(color: Colors.grey),
          ),
        ),
        TextField(
          controller: bioTextController,
          decoration: InputDecoration(
            hintText: "Update Bio",
            errorText: _bioValid ? null : "Bio Too Long",
          ),
        ),
      ],
    );
  }

  logout() async {
    await googleSignIn.signOut();
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return Home();
    }));
  }

  updateProfileData() async {
    setState(() {
      displayNameController.text.trim().length < 3 ||
              displayNameController.text.isEmpty
          ? _displayNameValid = false
          : _displayNameValid = true;
      userNameController.text.trim().length < 3 ||
              userNameController.text.isEmpty
          ? _userNameValid = false
          : _userNameValid = true;
      bioTextController.text.trim().length > 100
          ? _bioValid = false
          : _bioValid = true;
      _isUpdating = true;
    });
    if (_displayNameValid && _bioValid && _userNameValid) {
      // ignore: unnecessary_statements
      file != null ? await compressImage() : null;
      // ignore: unnecessary_statements
      file == null ? null : newPhotoUrl = await uploadImage(file);
      userRef.doc(widget.currentUserID).update({
        "displayName": displayNameController.text,
        "userName": userNameController.text,
        "bio": bioTextController.text,
        "photoUrl": newPhotoUrl,
      });
      setState(() {
        _isUpdating = false;
      });

      Navigator.pop(context);
      BotToast.showText(text: 'Profile Updated');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        title: Text("Edit Profile"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.done),
            onPressed: _isUpdating ? null : () => updateProfileData(),
          ),
        ],
      ),
      body: isLoading
          ? bouncingGridProgress()
          : ListView(
              children: <Widget>[
                _isUpdating ? linearProgress() : Text(""),
                Container(
                  child: Column(
                    children: <Widget>[
                      Stack(
                        children: [
                          CircleAvatar(
                            backgroundImage: file == null
                                ? CachedNetworkImageProvider(user.photoUrl)
                                : FileImage(file),
                            radius: 60.0,
                          ),
                          GestureDetector(
                            onTap: handleImageFromGallery,
                            child: CircleAvatar(
                                backgroundColor: Colors.green,
                                radius: 20.0,
                                child: Center(
                                    child: Icon(
                                  Icons.add,
                                  size: 20.0,
                                  color: Colors.white,
                                ))),
                          ),
                        ],
                        alignment: Alignment.bottomRight,
                      ),
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: Column(
                          children: <Widget>[
                            buildDisplayField(),
                            buildUserField(),
                            buildBioField(),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(25.0),
                        child: FlatButton.icon(
                          onPressed: () => logout(),
                          icon: Icon(
                            Icons.cancel,
                            color: Colors.red,
                            size: 40,
                          ),
                          label: Text(
                            "Log Out",
                            style: TextStyle(color: Colors.red, fontSize: 20.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  compressImage() async {
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    Im.Image imageFile = Im.decodeImage(file.readAsBytesSync());
    final compressedImageFile = File('$path/img_${widget.currentUserID}.jpg')
      ..writeAsBytesSync(Im.encodeJpg(imageFile, quality: 85));
    setState(() {
      file = compressedImageFile;
    });
  }

  handleImageFromGallery() async {
    var picker = await ImagePicker().getImage(source: ImageSource.gallery);
    File file;
    print(file.toString());
    file = File(picker.path);
    setState(() {
      this.file = file;
    });
  }

  Future<String> uploadImage(imageFile) async {
    UploadTask uploadTask = storageRef
        .child("user_img_${widget.currentUserID}.jpg")
        .putFile(imageFile);
    String downloadUrl;
    //TaskSnapshot storageSnap = await
    uploadTask.then((res) async {
      downloadUrl = await res.ref.getDownloadURL();
    });
    //downloadUrl = await storageSnap.ref.getDownloadURL();
    return downloadUrl;
  }
}
