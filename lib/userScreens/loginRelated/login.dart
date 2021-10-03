//import 'package:firebase_auth/firebase_auth.dart';
//import 'package:flutter/gestures.dart';
//import 'package:flutter/material.dart';
//import 'package:kannapy/tools/app_tools.dart';
//import 'package:kannapy/userScreens/register.dart';
//import 'package:kannapy/userScreens/signInLogIn.dart';
//import 'dart:async';
//
//class KannapyLogin extends StatefulWidget {
//  @override
//  _KannapyLoginState createState() => _KannapyLoginState();
//}
//
//class _KannapyLoginState extends State<KannapyLogin> {
//  TextEditingController emailController = TextEditingController();
//  TextEditingController passwordController = TextEditingController();
//  BuildContext context;
//  bool _obscureText = true;
//  final _scaffoldKey = GlobalKey<ScaffoldState>();
//  final textFormKey = GlobalKey<FormState>();
//  final FirebaseAuth _auth = FirebaseAuth.instance;
//
//  String email, password;
//  bool obscureText;
//  @override
//  Widget build(BuildContext context) {
//    this.context = context;
//    TapGestureRecognizer _gestureRecognizer = TapGestureRecognizer()
//      ..onTap = () {
//        Navigator.of(context)
//            .push(MaterialPageRoute(builder: (context) => KannapyRegister()));
//        print("Move to Register Page");
//      };
//    return Scaffold(
//      key: _scaffoldKey,
//      appBar: AppBar(
//        title: Text('LogIn'),
//      ),
//      body: Center(
//        child: SingleChildScrollView(
//          child: Form(
//            key: textFormKey,
//            child: Column(
//              children: <Widget>[
//                Text(
//                  'LogIn',
//                  style: Theme.of(context).textTheme.headline,
//                ),
//                SizedBox(
//                  height: 20.0,
//                ),
//                SizedBox(
//                  height: 20.0,
//                ),
//                appTextField(
//                    onSavedFunc: (val) => email = val,
//                    textValidator: (val) =>
//                        !val.contains('@') ? 'Invalid Email' : null,
//                    iconColor: Theme.of(context).accentColor,
//                    labelText: 'Email',
//                    controller: emailController,
//                    textHint: 'Enter a valid email',
//                    textIcon: Icons.email),
//                SizedBox(
//                  height: 20.0,
//                ),
//                Padding(
//                  padding: const EdgeInsets.only(left: 18.0, right: 18.0),
//                  child: TextFormField(
//                    obscureText: _obscureText,
//                    onSaved: (val) => password = val,
//                    validator: (val) =>
//                        val.length < 6 ? 'Password Too Short' : null,
//                    controller: passwordController,
//                    decoration: InputDecoration(
//                      suffixIcon: GestureDetector(
//                        onTap: () {
//                          setState(() {
//                            _obscureText = !_obscureText;
//                          });
//                        },
//                        child: Icon(_obscureText == true
//                            ? Icons.visibility
//                            : Icons.visibility_off),
//                      ),
//                      border: OutlineInputBorder(
//                        borderRadius: BorderRadius.all(Radius.circular(5.0)),
//                      ),
//                      labelText: "Password",
//                      hintText: "Enter a valid password, min length 6",
//                      icon: Icon(
//                        Icons.lock,
//                        color: Theme.of(context).accentColor,
//                      ),
//                    ),
//                  ),
//                ),
//                SizedBox(
//                  height: 20.0,
//                ),
//                appButton(
//                    btnColor: Theme.of(context).buttonColor,
//                    buttonText: "Submit",
//                    onBtnClicked: signInEmail),
//                SizedBox(
//                  height: 20.0,
//                ),
//                RichText(
//                  text: TextSpan(
//                      text: "New User? ",
//                      style: TextStyle(fontSize: 15.0),
//                      children: [
//                        TextSpan(
//                            text: 'Register',
//                            style: TextStyle(
//                                color: Colors.blue,
//                                fontWeight: FontWeight.bold,
//                                fontSize: 18.0,
//                                fontStyle: FontStyle.italic),
//                            recognizer: _gestureRecognizer),
//                      ]),
//                ),
//              ],
//            ),
//          ),
//        ),
//      ),
//    );
//  }
//
//  signInEmail() async {
//    final form = textFormKey.currentState;
//    if (form.validate()) {
//      form.save();
//      _auth.signInWithEmailAndPassword(email: email, password: password);
//
//      Navigator.pop(context);
//    }
//  }
//}
