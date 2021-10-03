import 'package:bot_toast/bot_toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kannapy/tools/policy_Dialog.dart';
import 'package:kannapy/userScreens/home.dart';

import 'file:///C:/kannapy/lib/userScreens/loginRelated/createAccount.dart';

class CodeScreen extends StatefulWidget {
  final user;
  CodeScreen({this.user});
  @override
  _CodeScreenState createState() => _CodeScreenState();
}

bool agreed = false;

class _CodeScreenState extends State<CodeScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  TextEditingController _codeController = TextEditingController();
  @override
  initState() {
    getCodes();
    popIfAuth();
    super.initState();
  }

  popIfAuth() async {
    isAuth
        ? Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => Home()))
        : null;
  }

  buildWarning({
    BuildContext parentContext,
    GoogleSignInAccount user,
  }) {
    return showDialog(
        context: parentContext,
        builder: (context) => SimpleDialog(
              title: Center(child: Text("LEGAL DISCLAIMER")),
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Text(
                        "‘KANNAPY LTD’S  MOBILE APPLICATION , ALONG WITH KANNAPY’s WEBSITE AND ALL RELATED COMMUNICATIONS AND MEDIA MATERIALS SHOULD NOT BE USED BY THOSE UNDER THE AGE OF 18. IT SHOULD ALSO BE NOTED THAT ALL CANNABIS SEEDS SOLD VIA OUR MOBILE APP STORE ARE SOLD ONLY AS NOVELTY ADULT SOUVENIRS AND INTENDED ONLY FOR COLLECTION AND THE PRESERVATION OF CANNABIS GENETICS UNTIL SUCH TIME THE LAWS CHANGE.\n\nTHE GERMINATION OF CANNABIS SEEDS REMAINS ILLEGAL IN MOST COUNTRIES. IT IS YOUR RESPONSIBILITY TO ENSURE THAT  YOU ARE COMPLIANT WITH ALL LOCAL, REGIONAL AND NATIONAL LAWS IN YOUR RESPECTIVE TERRITORY.\n\nBY PROCEEDING TO REGISTER, YOU ARE CONFIRMING THAT YOU HAVE READ OUR FULL TERMS AND CONDITIONS, AND THAT YOU ARE OVER THE AGE OF 18. BY CONTINUING TO REGISTER.  YOUFULLYN ABSOLVE ‘KANNAPY LTD’ OF ANY AND ALL OF LEGAL LIABILITIES FOR ANY ACTIONS TAKEN BY YOU.YOU CAN FIND FULL TERMS AND CONDITION AND PRIVACY POLICY  HERE."),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                      onTap: () => showDialog(
                            context: context,
                            builder: (context) =>
                                PolicyDialog(mdFileName: "privacy_policy.md"),
                          ),
                      child: Text(
                        "View our privacy policy",
                        style: TextStyle(color: Colors.blue),
                      )),
                ),
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                      onTap: () => showDialog(
                            context: context,
                            builder: (context) =>
                                PolicyDialog(mdFileName: "terms_n_cond.md"),
                          ),
                      // Navigator.of(context).push(
                      // MaterialPageRoute(
                      //     builder: (context) => TermsAndConditions())),
                      child: Text(
                        "View Terms And Conditions",
                        style: TextStyle(color: Colors.blue),
                      )),
                ),
                SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      RaisedButton(
                        onPressed: () => Navigator.pop(context),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0)),
                        child: Text('Cancel'),
                      ),
                      RaisedButton(
                        onPressed: () {
                          setState(() {
                            agreed = true;
                          });
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => CreateAccount()));
                        },
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0)),
                        child: Text('Agree & Continue'),
                      ),
                    ],
                  ),
                ),
              ],
            ));
  }

  getCodes() async {
    QuerySnapshot snapshot = await codesRef.get();
    snapshot.docs.forEach((e) {
      if (DateTime.now().isBefore(e.data()['expiryDate'].toDate())) {
        allCodes.add(e.data()['code']);
      }
    });
    print(allCodes);
  }

  submit() {
    final form = _formKey.currentState;
    if (form.validate()) {
      code = _codeController.text;
      print("code:" + code);
      print(allCodes);
      for (int i = 0; i < allCodes.length; i++) {
        if (code == allCodes[i]) {
          setState(() {
            isValidCode = true;
          });
          break;
        } else {
          setState(() {
            isValidCode = false;
          });
        }
      }

      print(isValidCode);
      form.save();
      if (!isValidCode) {
        BotToast.showSimpleNotification(
            title: "Invalid Code!!",
            borderRadius: 20.0,
            backgroundColor: Colors.red);
      } else {
        buildWarning(parentContext: context);
      }
    }
  }

  @override
  Widget build(BuildContext parentContext) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text('INVITE CONFIRMATION'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
            8, MediaQuery.of(context).size.height * 0.2, 8, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 25.0),
              child: Center(
                child: Text(
                  "ENTER INVITATION CODE",
                  style: TextStyle(fontSize: 25.0),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Container(
                child: Form(
                  key: _formKey,
                  autovalidate: true,
                  child: TextFormField(
                    controller: _codeController,
                    // ignore: missing_return
                    validator: (val) {
                      allCodes.forEach((element) {
                        if (val != element) {
                          return "Wrong Code!";
                        } else {
                          return null;
                        }
                      });
                    },
                    onSaved: (val) => code = val,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Enter Code",
                      labelStyle: TextStyle(fontSize: 15.0),
                      hintText: "Code Must be Valid",
                    ),
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () => submit(),
              child: Container(
                height: 50.0,
                width: 350.0,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(7.0),
                ),
                child: Center(
                  child: Text(
                    "ENTER",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 15.0,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            GestureDetector(
              onTap: () {
                logout(context);
              },
              child: Center(
                child: Text(
                  "Change Account",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 15.0,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    //   WillPopScope(
    //   onWillPop: _onBackPressed,
    //   child: ,
    // );
  }

  // Future<bool> _onBackPressed() {
  //   _deleteCacheDir().then(
  //       (value) => _deleteAppDir().then((value) => Navigator.pop(context)));
  //   return null;
  // }

  // Future<void> _deleteCacheDir() async {
  //   final cacheDir = await getTemporaryDirectory();
  //
  //   if (cacheDir.existsSync()) {
  //     cacheDir.deleteSync(recursive: true);
  //   }
  // }

  // Future<void> _deleteAppDir() async {
  //   final appDir = await getApplicationSupportDirectory();
  //
  //   if (appDir.existsSync()) {
  //     appDir.deleteSync(recursive: true);
  //   }
  // }
}
