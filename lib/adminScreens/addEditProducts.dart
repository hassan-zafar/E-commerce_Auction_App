import 'dart:io';
import 'package:bot_toast/bot_toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kannapy/models/users.dart';
import 'package:kannapy/tools/progress.dart';
import 'package:kannapy/tools/uiFunctions.dart';
import 'package:kannapy/userScreens/home.dart';
import 'package:uuid/uuid.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:kannapy/models/vendorsModel.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:kannapy/tools/productItems.dart';

class AddEditProducts extends StatefulWidget {
  final AppUser currentUser;
  final ProductItems productItems;
  final bool isEdit;
  AddEditProducts({this.currentUser, this.productItems, this.isEdit});
  @override
  _AddEditProductsState createState() => _AddEditProductsState();
}

class _AddEditProductsState extends State<AddEditProducts> {
  String productName, productDescription;
  String productPrice;
  String productQuantity;
  File file;
  String productId;
  String vendorsId = Uuid().v4();
  TextEditingController _productNameController = TextEditingController();
  TextEditingController productPriceController = TextEditingController();
  TextEditingController productDescriptionController = TextEditingController();
  TextEditingController productSubNameController = TextEditingController();
  TextEditingController productQuantityController = TextEditingController();
  TextEditingController startingDeliveryDayController = TextEditingController();
  TextEditingController endingDeliveryDayController = TextEditingController();
  TextEditingController liveSaleDateController = TextEditingController();
  TextEditingController productReservePriceController = TextEditingController();
  TextEditingController videoUrlController = TextEditingController();
  TextEditingController sexController = TextEditingController();
  TextEditingController bonusQuantityController = TextEditingController();
  TextEditingController bonusController = TextEditingController();
  List allMediaUrls = [];
  getValuesInController() {
    setState(() {
      bonusController.text = widget.productItems.bonus;
      bonusQuantityController.text = widget.productItems.bonusQuantity;
      _productNameController.text = widget.productItems.productName;
      productPriceController.text = widget.productItems.price;
      productDescriptionController.text = widget.productItems.description;
      productSubNameController.text = widget.productItems.subName;
      productQuantityController.text = widget.productItems.quantity;
      liveSaleDate = widget.productItems.liveSaleDate.toDate();
      productReservePriceController.text = widget.productItems.reservePrice;
      videoUrlController.text = widget.productItems.videoUrl;
      sexController.text = widget.productItems.sex;
      imageUrlList = widget.productItems.mediaUrl.toList();
      type = widget.productItems.type;
      allMediaUrls = widget.productItems.mediaUrl;
    });
  }

  final _textFormKey = GlobalKey<FormState>();

  bool isUploading = false;
  DateTime auctionDate;
  DateTime liveSaleDate;
  ScrollController _scrollController = ScrollController();
  String productSubName;
  List imageUrlList;
  String itemType = "";
  bool isSelected = false;
  String selectedVendorMediaUrl;
  bool liveDateSelected = false;
  String reservePrice;
  String sex;
  List<VendorsModel> allVendors = [];
  String videoUrl;
  String type;
  @override
  void initState() {
    super.initState();

    startingDeliveryDayController.text = "7";
    endingDeliveryDayController.text = "21";
    widget.isEdit
        ? productId = widget.productItems.productId
        : productId = Uuid().v4();
    getVendors();
    // ignore: unnecessary_statements
    widget.isEdit ? getValuesInController() : null;
  }

  getVendors() async {
    QuerySnapshot snapShot = await vendorsRef.get();
    List<VendorsModel> tempAllVendors = [];

    snapShot.docs.forEach((e) {
      tempAllVendors.add(VendorsModel.fromDocument(e));
    });
    setState(() {
      allVendors = tempAllVendors;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Products"),
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.all(10.0),
            child: RaisedButton.icon(
              onPressed: () => pickImages(isProductImage: true),
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
    var btnWidth = MediaQuery.of(context).size.width * 0.5;
    return SingleChildScrollView(
      controller: _scrollController,
      child: Column(
        children: <Widget>[
          isUploading ? linearProgress() : Text(""),
          isUploading
              ? Text('')
              : widget.isEdit
                  ? editPageImages()
                  : _multiImagePickerFileList(
                      imageList: imageList,
                      removeNewImage: (index) => removeFileImage(index)),
          Form(
              key: _textFormKey,
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
                      controller: _productNameController,
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
                      onSaved: (val) => sex = val,
                      controller: sexController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            // borderRadius: BorderRadius.all(Radius.circular(5.0)),
                            ),
                        labelText: "Plant Sex",
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
                      onSaved: (val) => productDescription = val,
                      validator: (val) => val.trim().length < 1
                          ? 'Please add Bonus Item Name'
                          : null,
                      controller: bonusController,
                      maxLines: 7,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Bonus Item",
                        hintText: "Add Name of the Bonus Item",
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 25.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 18.0, right: 18.0),
                    child: TextFormField(
                      onSaved: (val) => bonusQuantityController.text = val,
                      validator: (val) => val.trim().length < 1
                          ? 'Please add Bonus Item Quantity'
                          : null,
                      controller: bonusQuantityController,
                      maxLines: 7,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Bonus Item Quantity",
                        hintText: "Add quantity of bonus Item",
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 25.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 18.0, right: 18.0),
                    child: TextFormField(
                      onTap: getSaleLiveDate,
                      //enabled: liveDateSelected ? false : true,
                      controller: liveSaleDateController,
                      readOnly: liveDateSelected ? true : false,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: liveDateSelected
                            ? "$liveSaleDate"
                            : "Product Live Sale Date",
                        hintText: "Select Date for Live Sale of Product",
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
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                      onSaved: (val) => reservePrice = val,
                      // validator: (val) =>
                      //     val.trim().length < 1 || val.trim().contains("-")
                      //         ? "Enter valid Price"
                      //         : null,
                      controller: productReservePriceController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Auction Product Reserve Price",
                        hintText: "Enter reserve price",
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
                      keyboardType: TextInputType.url,
                      onSaved: (val) => videoUrl = val,
                      // validator: (val) =>
                      // val.trim().length < 1 || int.parse(val) < 1
                      //     ? "Product Quantity field can't be left empty"
                      //     : null,
                      controller: videoUrlController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Product Video Url",
                        hintText: "Enter the Url from Youtube only",
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
                  isUploading
                      ? Container()
                      : GestureDetector(
                          onTap: () => pickImages(isProductImage: false),
                          child: neumorphicTile(
                            padding: 15,
                            anyWidget: Container(
                              width: btnWidth,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: Icon(Icons.add_a_photo_outlined),
                                  ),
                                  Text(
                                    "Vendor's Logo",
                                    style: TextStyle(fontSize: 20.0),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                  SizedBox(
                    height: 25.0,
                  ),
                  showVendorsImage(),
                  vendorImage != null
                      ? SizedBox(
                          height: 25.0,
                        )
                      : Container(),
                  !widget.isEdit || type == 'storeItem'
                      ? GestureDetector(
                          onTap: isUploading
                              ? null
                              : () async {
                                  setState(() {
                                    itemType = 'storeItem';
                                  });
                                  auctionDate = DateTime.now();
                                  await handleSubmit();
                                },
                          child: neumorphicTile(
                            padding: 15,
                            anyWidget: Container(
                              width: btnWidth,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(Icons.add),
                                  Text(
                                    'Store Merc',
                                    style: TextStyle(fontSize: 20.0),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      : Container(),
                  SizedBox(
                    height: 25.0,
                  ),
                  !widget.isEdit || type == 'vaultItem'
                      ? GestureDetector(
                          onTap: isUploading
                              ? null
                              : () async {
                                  setState(() {
                                    itemType = 'vaultItem';
                                  });
                                  auctionDate = DateTime.now();
                                  await handleSubmit();
                                },
                          child: neumorphicTile(
                            padding: 15,
                            anyWidget: Container(
                              width: btnWidth,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(Icons.add),
                                  Text(
                                    'Store Vault',
                                    style: TextStyle(fontSize: 20.0),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      : Container(),
                  SizedBox(
                    height: 15.0,
                  ),
                  !widget.isEdit || type == 'auctionItem'
                      ? GestureDetector(
                          onTap: isUploading
                              ? null
                              : () async {
                                  setState(() {
                                    itemType = "auctionItem";
                                  });
                                  await getDate();
                                },
                          child: neumorphicTile(
                            padding: 15,
                            anyWidget: Container(
                              width: btnWidth,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(Icons.add),
                                  Text(
                                    'Auction Merc',
                                    style: TextStyle(fontSize: 20.0),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      : Container(),
                  SizedBox(
                    height: 25,
                  ),
                ],
              )),
        ],
      ),
    );
  }

  List<File> imageList;
  File vendorImage;
  pickImages({bool isProductImage = true}) async {
    var picker = await ImagePicker().getImage(source: ImageSource.gallery);
    File file;
    print(file.toString());
    file = File(picker.path);
    setState(() {
      this.file = file;
    });
    if (file != null) {
      if (isProductImage) {
        List<File> imageFile = List();
        imageFile.add(file);
        if (imageList == null) {
          imageList = new List.from(imageFile, growable: true);
        } else {
          setState(() {
            imageList.add(file);
          });
        }
      } else {
        setState(() {
          vendorImage = file;
        });
      }
    }
  }

  removeFileImage(int index) {
    setState(() {
      imageList.removeAt(index);
    });
  }

  getSaleLiveDate() {
    DatePicker.showDateTimePicker(
      context,
      showTitleActions: true,
      minTime: DateTime.now(),
      maxTime: DateTime(2022, 1, 1, 1),
      onChanged: (date) {
        print('change $date in time zone ' +
            date.timeZoneOffset.inHours.toString());
      },
      onConfirm: (date) {
        liveSaleDate = date;
        liveDateSelected = true;
        if (liveSaleDate != null) {
        } else {
          BotToast.showText(text: "Date was not selected correctly");
        }
      },
      currentTime: DateTime.now(),
    );
  }

  getDate() async {
    DatePicker.showDateTimePicker(context,
        showTitleActions: true,
        minTime: DateTime.now(),
        maxTime: DateTime(2022, 1, 1, 1), onChanged: (date) {
      print('change $date in time zone ' +
          date.timeZoneOffset.inHours.toString());
    }, onConfirm: (date) async {
      setState(() {
        auctionDate = date;
      });
      if (auctionDate == null && auctionDate == DateTime.now()) {
        BotToast.showText(text: "Auction End Date was not selected correctly");
      } else {
        await handleSubmit();
      }
    }, currentTime: DateTime.now());
  }

//TODO:storrageRef k kuch krna h bcz as user just add images app adds them to firebase directly...Ye data zya ho skta h easily aur space brha skta h moreover
//TODO:auction waly k rola h thora boht
  handleSubmit() async {
    print(vendorImage);
    print(selectedVendorMediaUrl);
    selectedVendorMediaUrl == null && widget.isEdit
        ? selectedVendorMediaUrl = widget.productItems.ownerMediaUrl
        // ignore: unnecessary_statements
        : null;
    final _form = _textFormKey.currentState;
    if (vendorImage == null && selectedVendorMediaUrl == null) {
      BotToast.showText(text: "You must select Vendor's logo!");
    } else if (imageList == null && imageUrlList == null) {
      BotToast.showText(text: 'You must select an Image!');
    } else if (_form.validate() || auctionDate != null) {
      _form.save();
      setState(() {
        isUploading = true;
        _scrollController.animateTo(0.0,
            duration: Duration(milliseconds: 300), curve: Curves.easeOut);
      });
      print(videoUrlController.text);
      videoUrl =
          videoUrlController.text == null || videoUrlController.text == ""
              ? null
              : YoutubePlayer.convertUrlToId(videoUrlController.text);
      List<String> mediaUrl = [];
      String vendorMediaUrl = selectedVendorMediaUrl != null
          ? selectedVendorMediaUrl
          : await uploadImage(
              itemType: "vendorLogo",
              c: 1,
              type: "vendors",
              imageFile: vendorImage,
              id: vendorsId);
      if (liveSaleDate == null) liveSaleDate = DateTime.now();
      createPostInFirestore(
        productName: _productNameController.text,
        mediaUrl: widget.isEdit ? allMediaUrls : mediaUrl,
        sex: sexController.text,
        videoUrl: videoUrl,
        auctionEndTime: auctionDate,
        description: productDescriptionController.text,
        subName: productSubNameController.text,
        price: productPriceController.text,
        quantity: productQuantityController.text,
        liveSaleDate: liveSaleDate,
        type: itemType,
        vendorMediaUrl: vendorMediaUrl,
        reservePrice: reservePrice,
        deliveryTime:
            "${startingDeliveryDayController.text}-${endingDeliveryDayController.text}",
        bonus: bonusController.text,
        bonusQuantity: bonusQuantityController.text,
      );
      imageList == null ? null : await uploadMultipleImages();

      vendorsRef.doc(vendorsId).set({
        "vendorMediaUrl": vendorMediaUrl,
        "vendorsId": vendorsId,
      });
      productQuantityController.clear();
      productPriceController.clear();
      productSubNameController.clear();
      productDescriptionController.clear();
      _productNameController.clear();
      startingDeliveryDayController.clear();
      endingDeliveryDayController.clear();
      productReservePriceController.clear();
      liveSaleDateController.clear();
      videoUrlController.clear();
      setState(() {
        file = null;
        isUploading = false;
        productId = Uuid().v4();
        vendorsId = Uuid().v4();
      });
      if (widget.isEdit) {
        Navigator.pop(context);
        BotToast.showText(text: "Product Successfully Updated ");
      }
      Navigator.pop(context);
      BotToast.showText(text: "Product Successfully Added");
    } else {
      BotToast.showText(text: 'Be sure Data is added correctly!!');
    }
  }

  Future<String> uploadImage(
      {imageFile,
      int c,
      @required String type,
      @required String itemType,
      @required String id}) async {
    Reference firebaseStorageRef =
        FirebaseStorage.instance.ref().child('$type-$itemType/$c-$id.jpg');
    UploadTask uploadTask = firebaseStorageRef.putFile(imageFile);
    // UploadTask uploadTask =
    //     storageRef.child("${c}_product_$productId.jpg").putFile(imageFile);
    // TaskSnapshot storageSnap = await uploadTask.onComplete;
    // String downloadUrl = await storageSnap.ref.getDownloadURL();
    // return downloadUrl;
    String downloadUrl;
    await uploadTask.whenComplete(() async {
      downloadUrl = await firebaseStorageRef.getDownloadURL();
    });
    print(downloadUrl);
    return downloadUrl;
  }

  //Future<List<String>>
  uploadMultipleImages() async {
    for (int i = 0; i < imageList.length; i++) {
      print(imageList[i]);
      String ui = await uploadImage(
          type: "products",
          imageFile: imageList[i],
          c: i,
          itemType: itemType,
          id: productId);
      productRef
          .doc(currentUser.id)
          .collection('productItems')
          .doc(productId)
          .update({
        'mediaUrl': FieldValue.arrayUnion([ui])
      });
      storeTimelineRef.doc(productId).get().then((value) {
        if (value.exists) {
          value.reference.update({
            'mediaUrl': FieldValue.arrayUnion([ui])
          });
        }
      });

      // auctionVaultTimelineRef.doc(productId).get().then((value) {
      //   if (value.exists) {
      //     value.reference.update({
      //       'mediaUrl': FieldValue.arrayUnion([ui])
      //     });
      //   }
      // });
      auctionTimelineRef.doc(productId).get().then((value) {
        if (value.exists) {
          value.reference.update({
            'mediaUrl': FieldValue.arrayUnion([ui])
          });
        }
      });
      seedVaultTimelineRef.doc(productId).get().then((value) {
        if (value.exists) {
          value.reference.update({
            'mediaUrl': FieldValue.arrayUnion([ui])
          });
        }
      });
    }
  }

  editPageImages() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "Uploaded Images:",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
                color: Theme.of(context).appBarTheme.textTheme.headline1.color),
          ),
        ),
        Container(
          height: 180,
          child: ListView.builder(
            physics: BouncingScrollPhysics(),
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            itemCount: allMediaUrls.length,
            itemBuilder: (context, index) {
              return Stack(
                alignment: Alignment.topRight,
                children: [
                  new Container(
                    width: 150.0,
                    height: 150.0,
                    decoration: new BoxDecoration(
                      color: Colors.grey.withAlpha(100),
                      borderRadius:
                          new BorderRadius.all(new Radius.circular(15.0)),
                      image: new DecorationImage(
                        fit: BoxFit.cover,
                        image:
                            new CachedNetworkImageProvider(allMediaUrls[index]),
                      ),
                    ),
                  ),
                  GestureDetector(
                      onTap: () async {
                        print(allMediaUrls);
                        print(allMediaUrls);
                        setState(() {
                          allMediaUrls.removeAt(index);
                        });
                        storeTimelineRef
                            .doc(widget.productItems.productId)
                            .get()
                            .then((doc) {
                          if (doc.exists) {
                            // doc.reference.delete();
                          }
                        });
                        auctionTimelineRef
                            .doc(widget.productItems.productId)
                            .get()
                            .then((doc) {
                          if (doc.exists) {
                            //    doc.reference.update(data);
                          }
                        });
                        seedVaultTimelineRef
                            .doc(widget.productItems.productId)
                            .get()
                            .then((doc) {
                          if (doc.exists) {
                            //   doc.reference.delete();
                          }
                        });
                        // await storageRef
                        //     .child(
                        //         "products-${widget.productItems.type}/1-${widget.productItems.productId}.jpg")
                        //     .delete();
                      },
                      child: CircleAvatar(
                        child: Icon(Icons.clear),
                        backgroundColor: Colors.red,
                      )),
                ],
              );
            },
          ),
        ),
        imageList == null || imageList.isEmpty
            ? Container()
            : Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "New Images to be added:",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                      color: Theme.of(context)
                          .appBarTheme
                          .textTheme
                          .headline1
                          .color),
                ),
              ),
        imageList == null || imageList.isEmpty
            ? Container()
            : _multiImagePickerFileList(
                imageList: imageList,
                removeNewImage: (index) => removeFileImage(index)),
      ],
    );
  }

  Widget showVendorsImage() {
    return vendorImage == null
        ? allVendors.length > 0
            ? Container(
                height: 180,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: allVendors.length,
                  itemBuilder: (context, index) {
                    print(allVendors[index].vendorsId);
                    print(allVendors[index].vendorMediaUrl);
                    return Stack(
                      alignment: Alignment.topRight,
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              isSelected = true;
                              selectedVendorMediaUrl =
                                  allVendors[index].vendorMediaUrl;
                            });
                          },
                          child: new Container(
                            width: 150.0,
                            height: 150.0,
                            decoration: new BoxDecoration(
                              color: Colors.grey.withAlpha(100),
                              borderRadius: new BorderRadius.all(
                                  new Radius.circular(15.0)),
                              image: new DecorationImage(
                                fit: BoxFit.cover,
                                image: new CachedNetworkImageProvider(
                                    allVendors[index].vendorMediaUrl),
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                            onTap: () async {
                              await vendorsRef
                                  .doc(allVendors[index].vendorsId)
                                  .delete()
                                  .then((value) =>
                                      BotToast.showText(text: "Deleted"));
                              storageRef
                                  .child(
                                      "vendors-vendorLogo/${allVendors[index].vendorsId}.jpg")
                                  .delete();
                              getVendors();
                            },
                            child: CircleAvatar(
                              child: Icon(Icons.clear),
                              backgroundColor: Colors.red,
                            )),
                        selectedVendorMediaUrl ==
                                allVendors[index].vendorMediaUrl
                            ? Positioned(
                                left: 2,
                                top: 2,
                                child: CircleAvatar(
                                    child: Icon(Icons.done_outlined)),
                              )
                            : Container(),
                      ],
                    );
                  },
                ),
              )
            : Container()
        : new Container(
            width: 150.0,
            height: 150.0,
            decoration: new BoxDecoration(
              color: Colors.grey.withAlpha(100),
              borderRadius: new BorderRadius.all(new Radius.circular(15.0)),
              image: new DecorationImage(
                fit: BoxFit.cover,
                image: new FileImage(vendorImage),
              ),
            ),
          );
  }

  createPostInFirestore({
    List mediaUrl,
    String productName,
    DateTime auctionEndTime,
    String subName,
    String description,
    String price,
    String type,
    String videoUrl,
    String deliveryTime,
    String quantity,
    String vendorMediaUrl,
    DateTime liveSaleDate,
    String reservePrice,
    String sex,
    String bonus,
    String bonusQuantity,
  }) {
    productRef
        .doc(widget.currentUser.id)
        .collection("productItems")
        .doc(productId)
        .set({
      "productId": productId,
      "ownerId": widget.currentUser.id,
      "userName": widget.currentUser.userName,
      "ownerMediaUrl": vendorMediaUrl,
      "mediaUrl": mediaUrl,
      "videoUrl": videoUrl,
      "productName": productName,
      "description": description,
      "subName": subName,
      "auctionEndTime": auctionEndTime,
      "price": price,
      "reservePrice": reservePrice,
      "quantity": quantity,
      "rating": "0",
      "liveSaleDate": liveSaleDate,
      "timestamp": timestamp,
      "carts": {},
      "type": type,
      "sex": sex,
      "deliveryTime": deliveryTime,
      "favourites": {},
      "allBuyers": [],
      "userLiveNotification": {},
      "setOnLiveNotification": false,
      "bonus": bonus,
      "bonusQuantity": bonusQuantityController,
    });
    var _varRef;
    if (itemType == 'auctionItem') {
      _varRef = auctionTimelineRef;
    }
    // else if (itemType == 'auctionItemVault') {
    //   _varRef = auctionVaultTimelineRef;
    // }
    else if (itemType == 'storeItem') {
      _varRef = storeTimelineRef;
    } else if (itemType == 'vaultItem') {
      _varRef = seedVaultTimelineRef;
    }
    _varRef.doc(productId).set({
      "productId": productId,
      "ownerId": widget.currentUser.id,
      "userName": widget.currentUser.userName,
      "ownerMediaUrl": vendorMediaUrl,
      "mediaUrl": mediaUrl,
      "videoUrl": videoUrl,
      "productName": productName,
      "description": description,
      "subName": subName,
      "auctionEndTime": auctionEndTime,
      "price": price,
      "reservePrice": reservePrice,
      "quantity": quantity,
      "rating": "0",
      "liveSaleDate": liveSaleDate,
      "timestamp": timestamp,
      "carts": {},
      "favourites": {},
      "bids": {},
      "type": type,
      "sex": sex,
      "deliveryTime": deliveryTime,
      "allBuyers": [],
      "userLiveNotification": {},
      "setOnLiveNotification": false,
    });
  }

  Widget _multiImagePickerFileList(
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
    return null;
  }
}
// storeTimelineRef.doc(productId).set({
// "productId": productId,
// "ownerId": widget.currentUser.id,
// "userName": widget.currentUser.userName,
// "mediaUrl": mediaUrl,
// "productName": productName,
// "ownerMediaUrl": widget.currentUser.photoUrl,
// "description": description,
// "subName": subName,
// "price": price,
// "quantity": quantity,
// "rating": "0",
// "type": type,
// "liveSaleDate":liveSaleDate,
// "deliveryTime": deliveryTime,
// "timestamp": timestamp,
// "carts": {},
// "favourites": {},
// "allBuyers": [],
// });
// seedVaultTimelineRef.doc(productId).set({
// "productId": productId,
// "ownerId": widget.currentUser.id,
// "userName": widget.currentUser.userName,
// "mediaUrl": mediaUrl,
// "ownerMediaUrl": widget.currentUser.photoUrl,
// "productName": productName,
// "description": description,
// "subName": subName,
// "price": price,
// "quantity": quantity,
// "rating": "0",
// "liveSaleDate":liveSaleDate,
// "type": type,
// "deliveryTime": deliveryTime,
// "timestamp": timestamp,
// "carts": {},
// "favourites": {},
// "allBuyers": [],
// });
// auctionVaultTimelineRef.doc(productId).set({
// "productId": productId,
// "ownerId": widget.currentUser.id,
// "userName": widget.currentUser.userName,
// "mediaUrl": mediaUrl,
// "liveSaleDate":liveSaleDate,
// "ownerMediaUrl": widget.currentUser.photoUrl,
// "productName": productName,
// "description": description,
// "subName": subName,
// "price": price,
// "quantity": quantity,
// "rating": "0",
// "type": type,
// "auctionEndTime": auctionEndTime,
// "deliveryTime": deliveryTime,
// "timestamp": timestamp,
// "carts": {},
// "bids": {},
// "favourites": {},
// "allBuyers": [],
// });
// auctionTimelineRef.doc(productId).set({
// "productId": productId,
// "ownerId": widget.currentUser.id,
// "userName": widget.currentUser.userName,
// "mediaUrl": mediaUrl,
// "liveSaleDate":liveSaleDate,
// "ownerMediaUrl": widget.currentUser.photoUrl,
// "productName": productName,
// "description": description,
// "subName": subName,
// "price": price,
// "quantity": quantity,
// "rating": "0",
// "type": type,
// "auctionEndTime": auctionEndTime,
// "deliveryTime": deliveryTime,
// "timestamp": timestamp,
// "carts": {},
// "bids": {},
// "favourites": {},
// "allBuyers": [],
// });
