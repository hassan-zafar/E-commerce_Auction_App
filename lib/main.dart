//@dart=2.9
import 'package:bot_toast/bot_toast.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:kannapy/userScreens/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KANNAPY',
      builder: BotToastInit(),
      navigatorObservers: [BotToastNavigatorObserver()],
      theme: ThemeData(
        //brightness: Brightness.dark,
        primaryColor: Colors.black,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        accentColor: Colors.white,
        buttonColor: Colors.white,
        highlightColor: Colors.white,
        cardColor: Colors.white,
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
            selectedItemColor: Colors.white,
            backgroundColor: Colors.grey.shade500,
            selectedIconTheme: IconThemeData(color: Colors.grey.shade500)),
        bottomSheetTheme: BottomSheetThemeData(
          backgroundColor: Colors.black,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  topRight: Radius.circular(20.0))),
        ),
        appBarTheme: AppBarTheme(
            textTheme: TextTheme(
                headline1: TextStyle(color: Colors.grey.shade400),
                bodyText1: TextStyle(color: Colors.black))),
      ),
      home: Home(),
    );
  }
}
