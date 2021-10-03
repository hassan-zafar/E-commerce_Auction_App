import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:kannapy/tools/progress.dart';
import 'package:kannapy/userScreens/home.dart';

class RequestToBecomeMerc extends StatefulWidget {
  final String currentUserId;
  RequestToBecomeMerc({this.currentUserId});

  @override
  _RequestToBecomeMercState createState() => _RequestToBecomeMercState();
}

class _RequestToBecomeMercState extends State<RequestToBecomeMerc> {
  final _textFormkey = GlobalKey<FormState>();

  bool isUploading = false;

  String userName, email, userRequest;

  ScrollController _scrollController = ScrollController();

  TextEditingController userNameController = TextEditingController();

  TextEditingController emailController = TextEditingController();

  TextEditingController userRequestController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Request Admin',
          style: TextStyle(
              color: Theme.of(context).appBarTheme.textTheme.headline1.color),
        ),
      ),
      body: currentUser.type == 'merc' || currentUser.type == 'admin'
          ? buildAcceptMerc()
          : buildRequestMerc(context),
    );
  }

  buildRequestMerc(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      child: Column(
        children: [
          isUploading ? linearProgress() : Text(""),
          Form(
              key: _textFormkey,
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: 25.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 18.0, right: 18.0),
                    child: TextFormField(
                      onSaved: (val) => userName = val,
                      validator: (val) =>
                          val.trim().length < 3 ? 'Name Too Short' : null,
                      controller: userNameController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            // borderRadius: BorderRadius.all(Radius.circular(5.0)),
                            ),
                        labelText: "Your Name",
                        hintText: "Provide your real name",
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 25.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 18.0, right: 18.0),
                    child: TextFormField(
                      onSaved: (val) => email = val,
                      validator: (val) =>
                          val.trim().length < 3 ? 'Email Too short' : null,
                      controller: emailController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            // borderRadius: BorderRadius.all(Radius.circular(5.0)),
                            ),
                        labelText: "Your Business E-mail",
                        hintText: "Provide your contact E-mail",
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 25.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 18.0, right: 18.0),
                    child: TextFormField(
                      onSaved: (val) => userRequest = val,
                      validator: (val) => val.trim().length < 1
                          ? 'Please your your request message'
                          : null,
                      controller: userRequestController,
                      maxLines: 9,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Request Message",
                        hintText: "Enter your message for admin",
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 25.0,
                  ),
                  RaisedButton(
                    onPressed: isUploading ? null : () => handleSubmit(context),
                    padding: EdgeInsets.only(
                        left: 20.0, right: 20.0, bottom: 10.0, top: 10.0),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8.0))),
                    child: Text(
                      'Send Request',
                      style: TextStyle(fontSize: 20.0),
                    ),
                  )
                ],
              )),
        ],
      ),
    );
  }

  handleSubmit(context) async {
    final _form = _textFormkey.currentState;
    if (_form.validate()) {
      isUploading = true;
      _scrollController.animateTo(0.0,
          duration: Duration(milliseconds: 500), curve: Curves.easeOut);

      await mercReqRef.doc(widget.currentUserId).set({
        "userId": widget.currentUserId,
        "userName": userNameController.text,
        "requestMessage": userRequestController.text,
        "email": emailController.text,
        "requestStatus": "not Selected",
        "photoUrl": currentUser.photoUrl,
        "displayName": currentUser.displayName,
        "timestamp": timestamp,
      });
      userRequestController.clear();
      userNameController.clear();
      emailController.clear();
      isUploading = false;
      Navigator.pop(context);
      BotToast.showText(text: "Request Sent");
    }
  }

  buildAcceptMerc() {
    return Center(
      child: Text(
        "To access Admin panel\n -Go to Kannapy Store Page\n -Then long press on Kannapy Logo\nThat's it..:)",
        style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
      ),
    );
  }
}
