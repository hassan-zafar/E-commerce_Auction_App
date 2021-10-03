import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kannapy/tools/policy_Dialog.dart';
import 'package:kannapy/userScreens/home.dart';

class CreateAccount extends StatefulWidget {
  final user;
  CreateAccount({this.user});
  @override
  _CreateAccountState createState() => _CreateAccountState();
}

bool agreed = false;

class _CreateAccountState extends State<CreateAccount> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  TextEditingController _userNameController = TextEditingController();

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
                        onPressed: () => SystemNavigator.pop(),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0)),
                        child: Text('Cancel'),
                      ),
                      RaisedButton(
                        onPressed: () {
                          setState(() {
                            agreed = true;
                          });
                          submit();
                          Navigator.pop(context);
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

  popIfSignedIn() async {
    final GoogleSignInAccount user = googleSignIn.currentUser;
    DocumentSnapshot doc = await userRef.doc(user.id).get();
    if (doc.exists) Navigator.pop(context);
  }

  submit() {
    final form = _formKey.currentState;
    if (form.validate() && agreed) {
      setState(() {
        userName = _userNameController.text;
      });
    }
    form.save();
    SnackBar snackBar = SnackBar(content: Text("Welcome $userName!"));
    _scaffoldKey.currentState.showSnackBar(snackBar);
    Timer(Duration(seconds: 1), () {
      Navigator.pop(context);
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (BuildContext context) => Home()));
    });
  }

  @override
  Widget build(BuildContext parentContext) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text('Create User'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
            8, MediaQuery.of(context).size.height * 0.2, 8, 8),
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 25.0),
                child: Center(
                  child: Text(
                    "Create a username ",
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
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _userNameController,
                          validator: (val) {
                            if (val.trim().length < 3 || val.isEmpty) {
                              return "Username too short";
                            } else if (val.trim().length > 12) {
                              return "Username too long";
                            } else {
                              return null;
                            }
                          },
                          onSaved: (val) => userName = val,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: "Username",
                            labelStyle: TextStyle(fontSize: 15.0),
                            hintText: "Must be at least 3 characters",
                          ),
                        ),
                        SizedBox(
                          height: 20.0,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: submit,
                child: Container(
                  height: 50.0,
                  width: 350.0,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(7.0),
                  ),
                  child: Center(
                    child: Text(
                      "Submit",
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
                        color: Colors.blue,
                        fontSize: 15.0,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
