import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart';
import 'package:meta/meta.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

final Client client = Client();
Future<Map<String, dynamic>> sendAndRetrieveMessage(
    {@required String token,
    @required String message,
    @required String title}) async {
  final String serverToken =
      "AAAAQ-l2mr0:APA91bF9ZiFs3ShKPpWqOZxWqZZ2bfw942HbO1qX4uCS3U1knkbITQkU1RyOAEKwISfb4U8UcEUtQDXnzb2DS6rZ3QiJ4c2NmRAf-V86TOMNHmNR1khCLUJQwpCSQMCs36YASexwy6_S";
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  print("clicked");
  print(token);
  // await client.post(
  //   'https://fcm.googleapis.com/fcm/send',
  //   body: json.encode({
  //     'notification': {'body': '$message', 'title': '$title'},
  //     'priority': 'high',
  //     'data': {
  //       'click_action': 'FLUTTER_NOTIFICATION_CLICK',
  //       'id': '1',
  //       'status': 'done',
  //     },
  //     'to': '$token',
  //   }),
  //   headers: {
  //     'Content-Type': 'application/json',
  //     'Authorization': 'key=$serverToken',
  //   },
  // ).then((value) => print("sent"));
  await http
      .post(
        'https://fcm.googleapis.com/fcm/send',
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'key=$serverToken',
        },
        body: jsonEncode(
          <String, dynamic>{
            'notification': <String, dynamic>{
              'body': message,
              'title': '$title'
            },
            'priority': 'high',
            'data': <String, dynamic>{
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'id': '1',
              'status': 'done'
            },
            'to': token,
          },
        ),
      )
      .then((value) => print("Notification Sent"));

  final Completer<Map<String, dynamic>> completer =
      Completer<Map<String, dynamic>>();

  _firebaseMessaging.configure(
    onMessage: (Map<String, dynamic> message) async {
      completer.complete(message);
    },
  );

  return completer.future;
}
