import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

abstract class AppMethods {
  Future<String> logginUser({String email, String password});
  Future<String> createUserAccount(
      {String userName, String email, String password});
  Future<bool> logOutUser();
  Future<DocumentSnapshot> getUserInfo(String userId);
}
