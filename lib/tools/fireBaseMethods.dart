import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:kannapy/tools/appData.dart';
import 'package:kannapy/tools/app_methods.dart';
import 'package:kannapy/tools/app_tools.dart';

class FirebaseMethods implements AppMethods {
  Firestore firestore = Firestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  Future<String> createUserAccount(
      {String userName, String email, String password}) async {
    //TODO: implement userCurrent account
    FirebaseUser user;

    try {
      user = (await auth.createUserWithEmailAndPassword(
              email: email, password: password))
          .user;
    } on PlatformException catch (e) {
      // print(e.details);
      return (e.details);
    }

    try {
      if (user != null) {
        await firestore.collection(usersData).document(user.uid).setData({
          userID: user.uid,
          userName: userName,
          userEmail: email,
          userPassword: password,
        });

        writeDataLocally(key: userID, value: user.uid);
        writeDataLocally(key: userName, value: userName);
        writeDataLocally(key: userEmail, value: userEmail);
        writeDataLocally(key: userPassword, value: password);
      }
    } on PlatformException catch (e) {
      // print(e.details);
      return errorMSG(e.details);
    }

    return user == null ? errorMSG("Error") : successfulMSG();
  }

  Future<String> logginUser({String email, String password}) async {
    // TODO: implement logginUser

    FirebaseUser user;
    try {
      user = (await auth.signInWithEmailAndPassword(
              email: email, password: password))
          .user;

      if (user != null) {
        DocumentSnapshot userInfo = await getUserInfo(user.uid);
        await writeDataLocally(key: userID, value: userInfo[userID]);
        await writeDataLocally(key: userName, value: userInfo[userName]);
        await writeDataLocally(key: userEmail, value: userInfo[userEmail]);
        await writeDataLocally(key: photoURL, value: userInfo[photoURL]);
        await writeBoolDataLocally(key: loggedIN, value: true);

        print(userInfo[userEmail]);
      }
    } on PlatformException catch (e) {
      print(e.details);
      return errorMSG(e.details);
    }

    return user == null ? errorMSG("Error") : successfulMSG();
  }

  Future<bool> complete() async {
    return true;
  }

  Future<bool> notComplete() async {
    return false;
  }

  Future<String> successfulMSG() async {
    return successful;
  }

  Future<String> errorMSG(String e) async {
    return e;
  }

  @override
  Future<bool> logOutUser() async {
    // TODO: implement logOutUser
    await auth.signOut();
    await clearDataLocally();

    return complete();
  }

  @override
  Future<DocumentSnapshot> getUserInfo(String userId) async {
    // TODO: implement getUserInfo
    return await firestore.collection(usersData).document(userId).get();
  }
}
