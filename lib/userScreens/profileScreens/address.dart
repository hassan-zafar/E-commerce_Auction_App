import 'package:bot_toast/bot_toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_list_pick/country_list_pick.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:kannapy/models/addressModel.dart';
import 'package:kannapy/tools/progress.dart';
import 'package:kannapy/tools/uiFunctions.dart';
import 'package:kannapy/userScreens/home.dart';
import 'package:uuid/uuid.dart';

class DeliveryAddress extends StatefulWidget {
  final bool justViewing;
  DeliveryAddress({@required this.justViewing});
  @override
  _DeliveryAddressState createState() => _DeliveryAddressState();
}

class _DeliveryAddressState extends State<DeliveryAddress> {
  String address;
  String name;
  String email;
  String phoneNo;
  String areaCode;
  String country;
  String cityName;

  bool _disposed = false;
  final _textFormKey = GlobalKey<FormState>();
  TextEditingController _addressController = TextEditingController();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _areaCodeController = TextEditingController();
  //TextEditingController _countryController = TextEditingController();
  TextEditingController _cityController = TextEditingController();

  ScrollController _scrollController = ScrollController();

  bool isUpdating = false;
  List<Address> allAddresses = [];

  bool _isLoading = false;

  bool showMailText = false;

  bool showTextFieldsBool = false;
  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  void initState() {
    getAddresses();
    super.initState();
  }

  getAddresses() async {
    setState(() {
      _isLoading = true;
    });
    QuerySnapshot snapshot =
        await addressRef.doc(currentUser.id).collection('addresses').get();
    snapshot.docs.forEach((doc) {
      Address userAddress = Address.fromDocument(doc);
      if (!allAddresses.contains(userAddress)) {
        allAddresses.add(userAddress);
      }
    });
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Delivery Address',
          style: TextStyle(
              color: Theme.of(context).appBarTheme.textTheme.headline1.color),
        ),
      ),
      body: ListView(
        controller: _scrollController,
        children: [
          isUpdating ? linearProgress() : Text(""),
          Column(
            children: [
              Divider(),
              Padding(
                padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
                child: Center(
                  child: Text(
                    "SAVED ADDRESSES",
                    style: TextStyle(fontSize: 25.0),
                  ),
                ),
              ),
              Divider(),
              buildAddresses(),
              Divider(),
              Padding(
                padding: EdgeInsets.only(top: 25.0),
                child: Center(
                  child: GestureDetector(
                    onTap: showTextFields,
                    child: Text(
                      "Enter New Address",
                      style: TextStyle(fontSize: 25.0),
                    ),
                  ),
                ),
              ),
              Divider(),
              SizedBox(
                height: 10,
              ),
              showTextFieldsBool
                  ? Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Container(
                        child: Form(
                          key: _textFormKey,
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _nameController,
                                validator: (val) {
                                  if (val.trim().length < 5 || val.isEmpty) {
                                    return "Name too short";
                                  } else {
                                    return null;
                                  }
                                },
                                onSaved: (val) => name = val,
                                autofocus: true,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: "Name",
                                  labelStyle: TextStyle(fontSize: 15.0),
                                  hintText: "Please enter your Name Correctly",
                                ),
                              ),
                              SizedBox(
                                height: 10.0,
                              ),
                              showMailText
                                  ? Padding(
                                      padding: EdgeInsets.all(15.0),
                                      child: Center(
                                        child: Text(
                                          "Please provide your functional e-mail for further communication",
                                          //style: TextStyle(fontSize: 25.0),
                                        ),
                                      ),
                                    )
                                  : Text(''),
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                validator: (val) {
                                  if (val.trim().length < 5 || val.isEmpty) {
                                    return "Invalid Email";
                                  } else {
                                    return null;
                                  }
                                },
                                onSaved: (val) => email = val,
                                autofocus: true,
                                onTap: () {
                                  setState(() {
                                    showMailText = true;
                                  });
                                },
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: "E-mail",
                                  labelStyle: TextStyle(fontSize: 15.0),
                                  hintText:
                                      "Please provide your functional e-mail",
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: [
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.3,
                                    child: CountryListPick(
                                      appBar: AppBar(
                                        backgroundColor: Colors.black,
                                        title: Text('Choose a country'),
                                      ),
                                      initialSelection: "+44",
                                      theme: CountryTheme(
                                        showEnglishName: true,
                                        isShowTitle: true,
                                        isDownIcon: true,
                                        isShowCode: false,
                                        isShowFlag: true,
                                        initialSelection: "+44",
                                      ),
                                      onChanged: (code) {
                                        setState(() {
                                          phoneNo = code.dialCode;
                                        });
                                        print(code.code);
                                        print(code.dialCode);
                                        print(phoneNo);
                                      },
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.7,
                                      child: TextFormField(
                                        controller: _phoneController,
                                        keyboardType: TextInputType.phone,
                                        validator: (val) {
                                          if (val.trim().length < 7 ||
                                              val.isEmpty) {
                                            return "Phone number too short";
                                          } else {
                                            return null;
                                          }
                                        },
                                        onSaved: (val) => phoneNo = val,
                                        autofocus: true,
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(),
                                          labelText: "Phone Number",
                                          labelStyle: TextStyle(fontSize: 15.0),
                                          hintText:
                                              "Please enter your Phone Number",
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 10.0,
                              ),
                              TextFormField(
                                controller: _areaCodeController,
                                validator: (val) {
                                  if (val.trim().length < 3 || val.isEmpty) {
                                    return "Postal Code too short";
                                  } else {
                                    return null;
                                  }
                                },
                                onTap: () {
                                  setState(() {
                                    showMailText = false;
                                  });
                                },
                                onSaved: (val) => areaCode = val,
                                autofocus: true,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: "Postal Code",
                                  labelStyle: TextStyle(fontSize: 15.0),
                                  hintText:
                                      "Please enter your Postal Code Correctly",
                                ),
                              ),
                              SizedBox(
                                height: 10.0,
                              ),
                              TextFormField(
                                controller: _cityController,
                                keyboardType: TextInputType.streetAddress,
                                validator: (val) {
                                  if (val.trim().length < 3 || val.isEmpty) {
                                    return "Enter valid City name";
                                  } else {
                                    return null;
                                  }
                                },
                                onSaved: (val) => cityName = val,
                                autofocus: true,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: "City",
                                  labelStyle: TextStyle(fontSize: 15.0),
                                  hintText: "Please enter name of your City",
                                ),
                              ),
                              SizedBox(
                                height: 10.0,
                              ),
                              Row(
                                children: [
                                  Text("Select Your country : "),
                                  CountryListPick(
                                    appBar: AppBar(
                                      backgroundColor: Colors.black,
                                      title: Text('Choose a country'),
                                    ),
                                    initialSelection: "+44",
                                    theme: CountryTheme(
                                      showEnglishName: true,
                                      isShowTitle: true,
                                      isShowFlag: true,
                                      isDownIcon: true,
                                      isShowCode: false,
                                    ),
                                    onChanged: (code) {
                                      setState(() {
                                        country = code.name;
                                      });
                                      print(code.name);
                                    },
                                  ),
                                ],
                              ),
                              TextFormField(
                                controller: _addressController,
                                keyboardType: TextInputType.streetAddress,
                                validator: (val) {
                                  if (val.trim().length < 10 || val.isEmpty) {
                                    return "Address too short";
                                  } else {
                                    return null;
                                  }
                                },
                                onSaved: (val) => address = val,
                                autofocus: true,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: "Address",
                                  labelStyle: TextStyle(fontSize: 15.0),
                                  hintText:
                                      "Please enter your address Correctly",
                                ),
                              ),
                              SizedBox(
                                height: 10.0,
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : Container(),
              Divider(),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: registerLocation,
        child: CircleAvatar(
          backgroundColor: Colors.black,
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
                      "REGISTER ->",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                  Container(
                    width: (screenSize.width - 20) / 2,
                    child: Text(
                      "<- ADDRESS",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          )),
    );
  }

  buildAddresses() {
    allAddresses = allAddresses.toSet().toList();
    if (_isLoading) {
      return bouncingGridProgress();
    }
    if (allAddresses == null || allAddresses.isEmpty && !_isLoading) {
      return Center(
        child: Text(
          "Currently no address has been added",
          style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
        ),
      );
    }
    print(allAddresses.length);
    return ListView.separated(
        physics: BouncingScrollPhysics(),
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return Dismissible(
            child: GestureDetector(
              onTap: () {
                if (!_disposed) {
                  setState(() {
                    deliveryAddress = allAddresses[index];
                    print(deliveryAddress.phone);
                    if (widget.justViewing) {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return SimpleDialog(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                              titlePadding: EdgeInsets.all(8),
                              contentPadding: EdgeInsets.all(8),
                              elevation: 6,
                              title: Center(
                                child: Text("Address"),
                              ),
                              children: <Widget>[
                                Divider(),
                                addressTextField(
                                    index: index,
                                    text1: "Name",
                                    text2: allAddresses[index].name),
                                addressTextField(
                                    index: index,
                                    text1: "Phone",
                                    text2: allAddresses[index].phone),
                                addressTextField(
                                    index: index,
                                    text1: "E-mail",
                                    text2: allAddresses[index].email),
                                addressTextField(
                                    index: index,
                                    text1: "Area Code",
                                    text2: allAddresses[index].areaCode),
                                addressTextField(
                                    index: index,
                                    text1: "Address",
                                    text2: allAddresses[index].address),
                                addressTextField(
                                    index: index,
                                    text1: "City",
                                    text2: allAddresses[index].city),
                                addressTextField(
                                    index: index,
                                    text1: "Country",
                                    text2: allAddresses[index].country),
                                allAddresses[index].timestamp != null
                                    ? addressTextField(
                                        index: index,
                                        text1: "Time of Creation",
                                        text2: allAddresses[index].timestamp)
                                    : Container(),
                              ],
                            );
                          });
                    } else {
                      BotToast.showText(text: 'Address Selected');
                      Navigator.pop(context);
                    }
                  });
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: neumorphicTile(
                  padding: 2,
                  anyWidget: ListTile(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    leading: Icon(Icons.location_on),
                    title: Text(allAddresses[index].name),
                    subtitle: Text(
                        "${allAddresses[index].city}\ ${allAddresses[index].country}"),
                  ),
                ),
              ),
            ),
            background: Container(
              alignment: Alignment.centerRight,
              color: Colors.red,
              child: Text('DELETE'),
            ),
            key: UniqueKey(),
            onDismissed: (direction) {
              setState(() {
                deleteAddress(allAddresses[index]);
              });
              BotToast.showText(text: "Deleted From Database");
            },
          );
        },
        separatorBuilder: (context, index) {
          return SizedBox(
            height: 1,
          );
        },
        itemCount: allAddresses.length);
    // });
  }

  Row addressTextField({int index, String text1, String text2}) {
    return Row(
      children: [
        Text(
          "$text1: ",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(text2),
      ],
    );
  }

  registerLocation() async {
    print(currentUser.id);
    String addressId = Uuid().v4();
    final _formKey = _textFormKey.currentState;
    if (_formKey.validate()) {
      setState(() {
        isUpdating = true;
        _scrollController.animateTo(0.0,
            duration: Duration(milliseconds: 300), curve: Curves.easeOut);
      });
      await addressRef
          .doc(currentUser.id)
          .collection("addresses")
          .doc(addressId)
          .set({
        "addressId": addressId,
        'name': _nameController.text,
        'email': _emailController.text,
        'phone': "$phoneNo${_phoneController.text}",
        'areaCode': _areaCodeController.text,
        'country': country,
        'city': _cityController.text,
        'address': _addressController.text,
      }).then((value) async {
        DocumentSnapshot snapshot = await addressRef
            .doc(currentUser.id)
            .collection('addresses')
            .doc(_addressController.text)
            .get();
        Address newAddress = Address.fromDocument(snapshot);
        setState(() {
          deliveryAddress = newAddress;
          isUpdating = false;
        });
        Navigator.pop(context);
        BotToast.showText(text: "Address added Successfully");
      });
    }
  }

  deleteAddress(Address allAddress) async {
    await addressRef
        .doc(currentUser.id)
        .collection("addresses")
        .doc(allAddress.address)
        .delete();
    BotToast.showText(text: "Address Deleted");
  }

  void showTextFields() {
    setState(() {
      showTextFieldsBool = true;
    });
  }
}
