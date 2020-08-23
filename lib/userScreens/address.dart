import 'package:bot_toast/bot_toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kannapy/models/users.dart';
import 'package:kannapy/tools/progress.dart';
import 'package:kannapy/userScreens/home.dart';
import 'package:stripe_payment/stripe_payment.dart';

class DeliveryAddress extends StatefulWidget {
  @override
  _DeliveryAddressState createState() => _DeliveryAddressState();
}

class _DeliveryAddressState extends State<DeliveryAddress> {
  String address;

  final _textFormKey = GlobalKey<FormState>();
  ScrollController _scrollController = ScrollController();
  TextEditingController _addressController = TextEditingController();
  bool isUpdating = false;
  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text('Delivery Address'),
      ),
      body: ListView(
        shrinkWrap: true,
        children: [
          Form(
            key: _textFormKey,
            child: Column(
              children: [
                isUpdating ? linearProgress() : Text(""),
                TextFormField(
                  controller: _addressController,
                  validator: (val) {
                    if (val.trim().length < 15 || val.isEmpty) {
                      return "Address too short";
                    } else {
                      return null;
                    }
                  },
                  onSaved: (val) => address = val,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Address",
                    labelStyle: TextStyle(fontSize: 15.0),
                    hintText: "Please enter your address Correctly",
                  ),
                ),
              ],
            ),
          ),
          Divider(),
          buildAddresses(),
          // BillingAddress()
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: registerLocation,
        child: CircleAvatar(
          child: Icon(Icons.add_location),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
          color: Theme.of(context).primaryColor,
          shape: CircularNotchedRectangle(),
          notchMargin: 5.0,
          elevation: 0.0,
          child: GestureDetector(
            onTap: registerLocation,
            child: Container(
              height: 50.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    width: (screenSize.width - 20) / 2,
                    child: Text(
                      "REGISTER",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    width: (screenSize.width - 20) / 2,
                    child: Text(
                      "ADDRESS",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          )),
    );
  }

  buildAddresses() {
    return ListView.separated(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              setState(() {
                deliveryAddress = currentUser.address[index];
                Navigator.pop(context);
              });
            },
            child: ListTile(
              leading: Icon(Icons.location_on),
              title: Text(currentUser.address[index]),
            ),
          );
        },
        separatorBuilder: (context, index) {
          return Divider();
        },
        itemCount: currentUser.address.length);
  }

  registerLocation() {
    setState(() {
      isUpdating = true;
    });
    address = _addressController.text;
    userRef.document(currentUser.id).updateData({
      "address": FieldValue.arrayUnion([address])
    }).then((value) {
      print("in address page: " + address);
      setState(() {
        isUpdating = false;
      });
      _scrollController.animateTo(0.0,
          duration: Duration(milliseconds: 300), curve: Curves.easeOut);
    });
    Navigator.pop(context, address);
    BotToast.showText(text: "Address added Successfully");
  }
}
