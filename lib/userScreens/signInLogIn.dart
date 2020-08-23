//import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:firebase_auth/firebase_auth.dart';
//import 'package:flutter/gestures.dart';
//import 'package:flutter/material.dart';
//import 'package:fluttertoast/fluttertoast.dart';
//import 'package:google_sign_in/google_sign_in.dart';
//import 'package:kannapy/models/users.dart';
//import 'package:kannapy/tools/app_tools.dart';
//import 'package:kannapy/userScreens/login.dart';
//import 'package:kannapy/userScreens/createAccount.dart';
//import 'dart:async';
//import 'package:shared_preferences/shared_preferences.dart';
//import 'kannapyStore.dart';
//
//bool isAuth;
//final GoogleSignIn googleSignIn = GoogleSignIn();
//final usersRef = Firestore.instance.collection('users');
//
////final DateTime timestamp = DateTime.now();
//
//class KannapyRegister extends StatefulWidget {
//  @override
//  _KannapyRegisterState createState() => _KannapyRegisterState();
//}
//
//class _KannapyRegisterState extends State<KannapyRegister> {
//  final FirebaseAuth auth = FirebaseAuth.instance;
//
//  //final UserServices _userServices = UserServices();
//  TextEditingController userNameController = TextEditingController();
//  TextEditingController emailController = TextEditingController();
//  TextEditingController passwordController = TextEditingController();
//  BuildContext context;
//  final _scaffoldKey = GlobalKey<ScaffoldState>();
//  final textFormKey = GlobalKey<FormState>();
//  String email, password, userName;
//  bool _obscureText = true;
//  bool isLoggedIn = false;
//  bool loading = false;
//
//  Future createAccountWithMail() async {
//    final form = textFormKey.currentState;
//    //  Map value;
//    if (form.validate()) {
//      form.save();
//      // form.reset();
//      FirebaseUser user = await auth.currentUser();
//      if (user == null) {
//        user = (await auth.createUserWithEmailAndPassword(
//                email: emailController.text, password: passwordController.text))
//            .user;
//      }
//
//      DocumentSnapshot doc = await usersRef.document(user.uid).get();
//      if (!doc.exists) {
//        usersRef.document(user.uid).setData({
//          "id": user.uid,
//          "userName": userName,
//          "photoUrl": "",
//          "email": emailController.text,
//          "displayName": userName,
//          "bio": "",
//          "timestamp": timestamp,
//        });
//        doc = await usersRef.document(user.uid).get();
//
//        if (user != null) {
//          await preferences.setString('id', user.uid);
//          await preferences.setString('userName', user.displayName);
//          await preferences.setString('photoUrl', user.photoUrl);
//          await preferences.setString('email', user.email);
//        }
//        await preferences.setString('id', doc['id']);
//        await preferences.setString('userName', doc['userName']);
//        await preferences.setString('photoUrl', doc['photoUrl']);
//        await preferences.setString('email', doc['email']);
//
//        currentUser = User.fromDocument(doc);
//        if (doc.exists) {
//          setState(() {
//            isLoggedIn = true;
//            isAuth = true;
//          });
//        } else {
//          setState(() {
//            isLoggedIn = false;
//            isAuth = false;
//          });
//        }
//        SnackBar snackbar = SnackBar(
//          content: Text("Welcome $userName"),
//        );
//        _scaffoldKey.currentState.showSnackBar(snackbar);
//        Timer(Duration(seconds: 2), () {
//          Navigator.pop(context, currentUser);
//        });
//      }
//      //   currentUser = User.fromDocument(doc);
//    }
//  }
//
//  Future handleSignIn() async {
//    final form = textFormKey.currentState;
//    try {
//      preferences = await SharedPreferences.getInstance();
//      setState(() {
//        loading = true;
//      });
//      GoogleSignInAccount googleUser = await googleSignIn.signIn();
//      GoogleSignInAuthentication googleAuth = await googleUser.authentication;
//      DocumentSnapshot doc = await usersRef.document(googleUser.id).get();
//
//      final AuthCredential credential = GoogleAuthProvider.getCredential(
//        accessToken: googleAuth.accessToken,
//        idToken: googleAuth.idToken,
//      );
//      final FirebaseUser user =
//          (await auth.signInWithCredential(credential)).user;
//      if (!doc.exists) {
//        // 2) if the user doesn't exist, then we want to take them to the create account page
////        final userName = await Navigator.push(context,
////            MaterialPageRoute(builder: (context) => ProfileSettings()));
//
//        // 3) get username from create account, use it to make new user document in users collection
//        usersRef.document(googleUser.id).setData({
//          "id": googleUser.id,
//          "userName": googleUser.displayName,
//          "photoUrl": googleUser.photoUrl,
//          "email": googleUser.email,
//          "displayName": googleUser.displayName,
//          "bio": "",
//          "timestamp": timestamp
//        });
//        if (googleUser != null) {
//          await preferences.setString('id', googleUser.id);
//          await preferences.setString('userName', googleUser.displayName);
//          await preferences.setString('photoUrl', googleUser.photoUrl);
//          await preferences.setString('email', googleUser.email);
//          print("run shared preferences if block");
//        }
//        await preferences.setString('id', doc['id']);
//        await preferences.setString('userName', doc['userName']);
//        await preferences.setString('photoUrl', doc['photoUrl']);
//        await preferences.setString('email', doc['email']);
//
//        doc = await usersRef.document(googleUser.id).get();
//        print(doc.data);
//        currentUser = User.fromDocument(doc);
//        if (doc.exists) {
//          setState(() {
//            isLoggedIn = true;
//            isAuth = true;
//            print(isAuth);
//          });
//        } else {
//          setState(() {
//            isLoggedIn = false;
//            isAuth = false;
//            print(isAuth);
//          });
//        }
//        //  Timer(Duration(seconds: 2), () {
//        // Navigator.pop(context);
//        // Navigator.pop(context);
//        print("code has run to pushed Replacement function");
//        Navigator.pushReplacement(
//            context,
//            MaterialPageRoute(
//                builder: (context) => KannapyStore(
//                      userEmail: currentUser.email,
//                      currentUser: currentUser,
//                      userName: currentUser.userName,
//                      userPhotoUrl: currentUser.photoUrl,
//                    )));
//        //    });
//      }
//      // currentUser = User.fromDocument(doc);
//      return user;
//    } catch (err) {
//      print(err);
//    }
//  }
//
////  submit() async {
////    final form = textFormKey.currentState;
////    if (form.validate()) {
////      form.save();
////      print('Username: $userName, Email: $email, Password: $password');
////      SnackBar snackbar = SnackBar(content: Text("Welcome $userName!"));
////      _scaffoldKey.currentState.showSnackBar(snackbar);
////      Timer(Duration(seconds: 2), () {
////        Navigator.pop(context, userName);
////      });
////    }
////    displayProgressDialog(context);
////    String response = await appMethod.createUserAccount(
////        userName: userName,
////        email: email.toLowerCase(),
////        password: password.toLowerCase());
////
////    if (response == successful) {
////      closeProgressDialog(context);
////
////    } else {
////      closeProgressDialog(context);
////      showSnackBar(message: response, scaffoldKey: _scaffoldKey);
////    }
////  isSignedIn() async {
////    setState(() {
////      loading = true;
////    });
////    // preferences = await SharedPreferences.getInstance();
////    // isLoggedIn = await googleSignIn.isSignedIn();
////    if (isAuth) {
////      Navigator.pushReplacement(
////          context,
////          MaterialPageRoute(
////              builder: (context) => MyHomePage(
////                    currentUser: currentUser,userEmail: ,
////                  )));
////    }
////    setState(() {
////      loading = false;
////    });
////  }
//
//  @override
//  void initState() {
//    // TODO: implement initState
//    super.initState();
////    isSignedIn();
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    this.context = context;
//    TapGestureRecognizer _gestureRecognizer = TapGestureRecognizer()
//      ..onTap = () {
//        Navigator.of(context)
//            .push(MaterialPageRoute(builder: (context) => KannapyLogin()));
//      };
//    return Scaffold(
//      key: _scaffoldKey,
//      // backgroundColor: Theme.of(context).accentColor,
//      appBar: AppBar(
//        title: Text('Register'),
//      ),
//      body: Center(
//        child: SingleChildScrollView(
//          child: Form(
//            key: textFormKey,
//            child: Column(
//              children: <Widget>[
//                Text(
//                  'Register',
//                  style: Theme.of(context).textTheme.headline,
//                ),
//                SizedBox(
//                  height: 20.0,
//                ),
//                appTextField(
//                    onSavedFunc: (val) => userName = val,
//                    textValidator: (val) =>
//                        val.length < 6 ? 'Username Too Short' : null,
//                    iconColor: Theme.of(context).accentColor,
//                    labelText: 'Username',
//                    controller: userNameController,
//                    textHint: 'Enter username, min length 6',
//                    textIcon: Icons.face),
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
//                  btnColor: Theme.of(context).buttonColor,
//                  buttonText: "Submit",
//                  onBtnClicked: () async {
//                    handleSignIn();
//                  },
//                ),
//                SizedBox(
//                  height: 20.0,
//                ),
//                appButton(
//                  btnColor: Theme.of(context).buttonColor,
//                  buttonText: "Sign Up with Google",
//                  onBtnClicked: () async {
//                    handleSignIn();
//                  },
//                ),
//                SizedBox(
//                  height: 20.0,
//                ),
//                RichText(
//                  text: TextSpan(
//                      text: "Already Registered? ",
//                      style: TextStyle(fontSize: 15.0),
//                      children: [
//                        TextSpan(
//                            text: 'Login',
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
//}
