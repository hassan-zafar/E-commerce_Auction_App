import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:kannapy/userScreens/home.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kannabis',
      builder: BotToastInit(),
      navigatorObservers: [BotToastNavigatorObserver()],
      theme: ThemeData(
        textTheme: TextTheme(headline: TextStyle(fontSize: 40.0)),
        brightness: Brightness.dark,
        primaryColor: Colors.black,
        accentColor: Color(0xff6F7372),
        buttonColor: Color(0xffFE0000),
      ),
      home: Home(),
    );
  }
}
