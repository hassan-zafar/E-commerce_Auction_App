import 'package:bot_toast/bot_toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kannapy/models/users.dart';
import 'dart:io';

import 'package:kannapy/tools/progress.dart';
import 'package:kannapy/userScreens/home.dart';
import 'package:uuid/uuid.dart';
//import 'package:image/image.dart' as Im;

class AddProducts extends StatefulWidget {
  final User currentUser;
  AddProducts({this.currentUser});
  @override
  _AddProductsState createState() => _AddProductsState();
}

class _AddProductsState extends State<AddProducts> {
  String productName, productDescription;
  String productPrice;
  String productQuantity;
  File file;
  String productId = Uuid().v4();
  TextEditingController productNameController = TextEditingController();
  TextEditingController productPriceController = TextEditingController();
  TextEditingController productDescriptionController = TextEditingController();
  TextEditingController productSubNameController = TextEditingController();
  TextEditingController productQuantityController = TextEditingController();
  TextEditingController startingDeliveryDayController = TextEditingController();
  TextEditingController endingDeliveryDayController = TextEditingController();

  final _textFormkey = GlobalKey<FormState>();

  bool isUploading = false;
  DateTime auctionDate;
  ScrollController _scrollController = ScrollController();
  String productSubName;

  String itemType = "storeItem";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Products"),
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.all(10.0),
            child: RaisedButton.icon(
              onPressed: () => pickImages(),
              icon: isUploading
                  ? Text('')
                  : Icon(
                      Icons.add_a_photo,
                      size: 20.0,
                    ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8.0))),
              label: Text(
                'Add Images',
                style: TextStyle(fontSize: 10.0),
              ),
            ),
          )
        ],
      ),
      body: WillPopScope(
        child: addProductBody(),
        onWillPop: _onBackPressed,
      ),
    );
  }

  SingleChildScrollView addProductBody() {
    return SingleChildScrollView(
      controller: _scrollController,
      child: Column(
        children: <Widget>[
          isUploading ? linearProgress() : Text(""),
          isUploading
              ? Text('')
              : multiImagePickerList(
                  imageList: imageList,
                  removeNewImage: (index) => removeImage(index)),
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
                      onSaved: (val) => productName = val,
                      validator: (val) => val.trim().length < 3
                          ? 'Product Name Too Short'
                          : null,
                      controller: productNameController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            // borderRadius: BorderRadius.all(Radius.circular(5.0)),
                            ),
                        labelText: "Product Name",
                        hintText: "Min length 3",
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 25.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 18.0, right: 18.0),
                    child: TextFormField(
                      onSaved: (val) => productSubName = val,
                      validator: (val) => val.trim().length < 3
                          ? 'Product Sub Name Too Short'
                          : null,
                      controller: productSubNameController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            // borderRadius: BorderRadius.all(Radius.circular(5.0)),
                            ),
                        labelText: "Product Sub Name",
                        hintText: "Min length 3",
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 25.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 18.0, right: 18.0),
                    child: TextFormField(
                      onSaved: (val) => productDescription = val,
                      validator: (val) => val.trim().length < 1
                          ? 'Please add Product description'
                          : null,
                      controller: productDescriptionController,
                      maxLines: 7,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Product Description",
                        hintText: "Add description of the Product",
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 25.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 18.0, right: 18.0),
                    child: TextFormField(
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                      onSaved: (val) => productPrice = val,
                      validator: (val) =>
                          val.trim().length < 1 || val.trim().contains("-")
                              ? "Enter valid Price"
                              : null,
                      controller: productPriceController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            // borderRadius: BorderRadius.all(Radius.circular(5.0)),
                            ),
                        labelText: "Product Price",
                        hintText: "Enter price",
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 25.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 18.0, right: 18.0),
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      onSaved: (val) => productQuantity = val,
                      validator: (val) =>
                          val.trim().length < 1 || int.parse(val) < 1
                              ? "Product Quantity field can't be left empty"
                              : null,
                      controller: productQuantityController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            // borderRadius: BorderRadius.all(Radius.circular(5.0)),
                            ),
                        labelText: "Product quantity",
                        hintText: "Enter the quantity of the product",
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 25.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 18.0, right: 18.0),
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      onSaved: (val) =>
                          startingDeliveryDayController.text = val,
                      validator: (val) => val.trim().length < 1 ||
                              int.parse(val) < 1 ||
                              int.parse(val) > 60
                          ? "Select From 1 to 60 days"
                          : null,
                      controller: startingDeliveryDayController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Delivery days lower limit",
                        hintText:
                            "Enter lower limit of estimated delivery time",
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 25.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 18.0, right: 18.0),
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      onSaved: (val) => endingDeliveryDayController.text = val,
                      validator: (val) => val.trim().length < 1 ||
                              int.parse(val) <
                                  int.parse(
                                      startingDeliveryDayController.text) ||
                              val.trim().length > 60
                          ? "Select From 1 to 60 days"
                          : null,
                      controller: endingDeliveryDayController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Delivery days upper limit",
                        hintText:
                            "Enter upper limit of estimated delivery time",
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 25.0,
                  ),
                  RaisedButton(
                    onPressed: isUploading
                        ? null
                        : () {
                            setState(() {
                              itemType = 'storeItem';
                            });
                            handleSubmit();
                          },
                    padding: EdgeInsets.only(
                        left: 20.0, right: 20.0, bottom: 10.0, top: 10.0),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8.0))),
                    child: Text(
                      'Add Product to Store',
                      style: TextStyle(fontSize: 20.0),
                    ),
                  ),
                  SizedBox(
                    height: 25.0,
                  ),
                  RaisedButton(
                    onPressed: isUploading
                        ? null
                        : () {
                            setState(() {
                              itemType = "auctionItem";
                            });
                            showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime(2024))
                                .then((value) {
                              setState(() {
                                auctionDate = value;
                              });
                            });
                            handleSubmit();
                          },
                    padding: EdgeInsets.only(
                        left: 20.0, right: 20.0, bottom: 10.0, top: 10.0),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8.0))),
                    child: Text(
                      'Add Product For Auction',
                      style: TextStyle(fontSize: 20.0),
                    ),
                  ),
                ],
              )),
        ],
      ),
    );
  }

  List<File> imageList;
  pickImages() async {
    var picker = await ImagePicker().getImage(source: ImageSource.gallery);
    File file;
    print(file.toString());
    file = File(picker.path);
    setState(() {
      this.file = file;
    });
    if (file != null) {
      //imagesMap[imagesMap.length] = file;
      List<File> imageFile = List();
      imageFile.add(file);
      //imageList = new List.from(imageFile);
      if (imageList == null) {
        imageList = new List.from(imageFile, growable: true);
      } else {
        // for (int s = 0; s < imageFile.length; s++) {
        setState(() {
          imageList.add(file);
        });
        // }
      }
    }
  }

  removeImage(int index) {
    setState(() {
      imageList.removeAt(index);
    });
  }

  handleSubmit() async {
    final _form = _textFormkey.currentState;
    if (imageList == null) {
      BotToast.showText(text: 'You must select an Image!');
    } else {
      if (_form.validate()) {
        _form.save();
        setState(() {
          isUploading = true;
          List<String> mediaUrl = [];
          createPostInFirestore(
            productName: productNameController.text,
            mediaUrl: mediaUrl,
            auctionEndTime: auctionDate,
            description: productDescriptionController.text,
            subName: productSubNameController.text,
            price: productPriceController.text,
            quantity: productQuantityController.text,
            type: itemType,
            deliveryTime:
                "${startingDeliveryDayController.text}-${endingDeliveryDayController.text}",
          );
        });
        _scrollController.animateTo(0.0,
            duration: Duration(milliseconds: 300), curve: Curves.easeOut);

        productQuantityController.clear();
        productPriceController.clear();
        productSubNameController.clear();
        productDescriptionController.clear();
        productNameController.clear();
        startingDeliveryDayController.clear();
        endingDeliveryDayController.clear();
        await uploadMultipleImages();

        setState(() {
          file = null;
          isUploading = false;
          productId = Uuid().v4();
        });
        Navigator.pop(context);
        BotToast.showText(text: "Product Successfully Added");
      }
    }
  }

  Future<String> uploadImage(imageFile, int c) async {
    StorageUploadTask uploadTask =
        storageRef.child("$c post_$productId.jpg ").putFile(imageFile);
    StorageTaskSnapshot storageSnap = await uploadTask.onComplete;
    String downloadUrl = await storageSnap.ref.getDownloadURL();
    return downloadUrl;
  }

  //Future<List<String>>
  uploadMultipleImages() async {
    for (int i = 0; i < imageList.length; i++) {
      String ui = await uploadImage(imageList[i], i);
      print(imageList[i]);
      productRef
          .document(currentUser.id)
          .collection('productItems')
          .document(productId)
          .updateData({
        'mediaUrl': FieldValue.arrayUnion([ui])
      });
      storeTimelineRef.document(productId).updateData({
        'mediaUrl': FieldValue.arrayUnion([ui])
      });

      auctionTimelineRef.document(productId).updateData({
        'mediaUrl': FieldValue.arrayUnion([ui])
      });
    }
  }

  createPostInFirestore(
      {List<String> mediaUrl,
      String productName,
      DateTime auctionEndTime,
      String subName,
      String description,
      String price,
      String type,
      String deliveryTime,
      String quantity}) {
    productRef
        .document(widget.currentUser.id)
        .collection("productItems")
        .document(productId)
        .setData({
      "productId": productId,
      "ownerId": widget.currentUser.id,
      "userName": widget.currentUser.userName,
      "mediaUrl": mediaUrl,
      "productName": productName,
      "description": description,
      "subName": subName,
      "auctionEndTime": auctionEndTime,
      "price": price,
      "quantity": quantity,
      "rating": "0",
      "timestamp": timestamp,
      "carts": {},
      "type": type,
      "deliveryTime": deliveryTime,
      "favourites": {},
    });
    if (itemType == 'auctionItem') {
      auctionTimelineRef.document(productId).setData({
        "productId": productId,
        "ownerId": widget.currentUser.id,
        "userName": widget.currentUser.userName,
        "mediaUrl": mediaUrl,
        "productName": productName,
        "description": description,
        "subName": subName,
        "price": price,
        "quantity": quantity,
        "rating": "0",
        "type": type,
        "auctionEndTime": auctionEndTime,
        "deliveryTime": deliveryTime,
        "timestamp": timestamp,
        "carts": {},
        "bids": {},
        "favourites": {},
      });
    } else {
      storeTimelineRef.document(productId).setData({
        "productId": productId,
        "ownerId": widget.currentUser.id,
        "userName": widget.currentUser.userName,
        "mediaUrl": mediaUrl,
        "productName": productName,
        "description": description,
        "subName": subName,
        "price": price,
        "quantity": quantity,
        "rating": "0",
        "deliveryTime": deliveryTime,
        "timestamp": timestamp,
        "carts": {},
        "favourites": {},
      });
    }
  }

  Widget multiImagePickerList(
      {List<File> imageList, VoidCallback removeNewImage(int position)}) {
    return new Padding(
      padding: const EdgeInsets.only(left: 15.0, right: 15.0),
      child: imageList == null || imageList.length == 0
          ? new Container()
          : new SizedBox(
              height: 150.0,
              child: new ListView.builder(
                  itemCount: imageList.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    return new Padding(
                      padding: new EdgeInsets.only(left: 3.0, right: 3.0),
                      child: new Stack(
                        children: <Widget>[
                          new Container(
                            width: 150.0,
                            height: 150.0,
                            decoration: new BoxDecoration(
                                color: Colors.grey.withAlpha(100),
                                borderRadius: new BorderRadius.all(
                                    new Radius.circular(15.0)),
                                image: new DecorationImage(
                                    fit: BoxFit.cover,
                                    image: new FileImage(imageList[index]))),
                          ),
                          new Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: CircleAvatar(
                              backgroundColor: Colors.red[600],
                              child: new IconButton(
                                  icon: new Icon(
                                    Icons.clear,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    removeNewImage(index);
                                  }),
                            ),
                          )
                        ],
                      ),
                    );
                  }),
            ),
    );
  }

  Future<bool> _onBackPressed() {
    isUploading
        ? BotToast.showText(
            text: "Sorry can't go back as product is been added")
        : Navigator.of(context).pop();
  }
}
