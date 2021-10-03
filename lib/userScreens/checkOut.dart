import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kannapy/models/addressModel.dart';
import 'package:kannapy/models/fav_cart.dart';
import 'package:kannapy/models/mailTemplate.dart';
import 'package:kannapy/models/users.dart';
import 'package:kannapy/payment/showDialogToDismiss.dart';
import 'package:kannapy/tools/CommonFunctions.dart';
import 'package:kannapy/tools/notificationHandler.dart';
import 'package:kannapy/tools/productItems.dart';
import 'package:kannapy/tools/uiFunctions.dart';
import 'package:kannapy/userScreens/home.dart';
import 'package:kannapy/userScreens/profileScreens/address.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:uuid/uuid.dart';
import 'package:stripe_payment/stripe_payment.dart';
import 'package:bot_toast/bot_toast.dart';
import 'dart:io' show Platform;

class CheckOut extends StatefulWidget {
  final List<FavCart> cartItems;
  CheckOut({this.cartItems});
  @override
  _CheckOutState createState() => _CheckOutState();
}

class _CheckOutState extends State<CheckOut> {
  double totalPriceInCart = 0;
  List<String> totalProductIds = [];
  List<double> totalPricePerItem = [];
  List<Address> allAddresses = [];
  TextEditingController _cryptoController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  //double finalPayment = 0;
  double totalBuyingPrice = 0;
  String paymentMethodName;
  bool showSpinner = false;
  String cryptoEmail;
  String orderId = Uuid().v4();
  bool addressLoading = false;
  var orderMailCheckOut = orderMail;
  double finalTotalAmountAfterShipping;

  double totalAmountBeforeShipping;

  double shipCost;
  getTotalPrice() {
    double tempFinalPrice = 0;
    widget.cartItems.forEach((e) {
      tempFinalPrice += double.parse(e.productPrice) * e.quantitySelected;
      var tempPrice = double.parse(e.productPrice) * e.quantitySelected;
      String ttlProductPrice = "$tempPrice";
      var tempProductTable = productInTable
          .replaceAll('{{IMAGE_URL}}', e.mediaUrl)
          .replaceAll("{{PRODUCT_NAME}}", e.productName)
          .replaceAll("{{PRODUCT_PRICE}}", ttlProductPrice)
          .replaceAll("{{QTY}}", "${e.quantitySelected}");
      setState(() {
        orderMailCheckOut = orderMailCheckOut + tempProductTable;
      });
    });
    setState(() {
      totalBuyingPrice = tempFinalPrice;
    });
  }

  getAddresses() async {
    setState(() {
      addressLoading = true;
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
      addressLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    // StripeNative.setPublishableKey(
    //     "pk_test_51HEKkjIEmWkp6b7ScGJgzPctYP1DknJpw4c8ikwLRdBiDgZPHkq0GnGsNnSnqNtFlngW1oJftKzopNdMVqmUsaWb00J1DNBegr");
    // StripeNative.setMerchantIdentifier("merchant.rbii.stripe-example");
    StripePayment.setOptions(
      StripeOptions(
        publishableKey:
            "pk_live_51HEKkjIEmWkp6b7SCEidAWA9umIUI0rOFOLi4gKrP9DzPhVwjJGb0EuIhhMpYxNGtlfY0zFgPGJgWrlWECIFgW4w0071dzDfNm",
        merchantId: "Test",
        androidPayMode: "00279821960207430192",
      ),
    );
    // StripeOptions(
    //    publishableKey:"pk_test_51GxtPhGXrIPXXF3qyLJfrZK
    //                    WSlSIq6iQNCD2XiyGAimnCvv2kE9cmgCIMcO3uzId0L
    //                    S2vRKL7XHiAfoklrL5YEKU00GM0wkpdR",
    //                    //YOUR_PUBLISHABLE_KEY
    //     merchantId: "Test",//YOUR_MERCHANT_ID
    //     androidPayMode: 'test')
    //     );
    getAddresses();
    getTotalPrice();
  }

  // Map<String, double> receipt;

  // Future<String> get receiptPayment async {
  //   /* custom receipt w/ useReceiptNativePay */
  //   var aReceipt = Receipt(receipt, "Kannapy");
  //   return await StripeNative.useReceiptNativePay(aReceipt);
  // }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        body: SlidingUpPanel(
          borderRadius: BorderRadius.circular(20),
          minHeight: 180,
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView(
              shrinkWrap: true,
              physics: BouncingScrollPhysics(),
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Hero(
                      tag: "checkout",
                      child: Text(
                        "CHECKOUT",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 30),
                      ),
                    ),
                  ),
                ),
                //cartCheckOut(isCart: false),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Delivery Address",
                        style: TextStyle(
                            fontSize: 25, fontWeight: FontWeight.bold),
                      ),
                      InkWell(
                          onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DeliveryAddress(
                                    justViewing: false,
                                  ),
                                ),
                              ),
                          child: Icon(Icons.add)),
                    ],
                  ),
                ),
                Container(
                  height: 140,
                  child: ListView(
                    shrinkWrap: true,
                    physics: BouncingScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    children: addressLoading
                        ? [Center(child: Text("Loading Addresses"))]
                        : allAddresses
                            .map(
                              (e) => InkWell(
                                onTap: () {
                                  setState(() {
                                    deliveryAddress = e;
                                  });
                                  BotToast.showText(text: "Address Selected");
                                },
                                child: Card(
                                  elevation: 5,
                                  child: Stack(
                                    children: [
                                      Container(
                                        height: 120,
                                        width: 300,
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 20, top: 20),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                e.name,
                                                style: addressTextStyle(),
                                              ),
                                              Text(
                                                e.email,
                                                style: addressTextStyle(),
                                              ),
                                              Text(
                                                e.address,
                                                style: addressTextStyle(),
                                              ),
                                              Text(
                                                e.areaCode,
                                                style: addressTextStyle(),
                                              ),
                                              Text(
                                                e.city,
                                                style: addressTextStyle(),
                                              ),
                                              Text(
                                                e.country,
                                                style: addressTextStyle(),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 10,
                                        right: 10,
                                        child: Container(
                                          child: Text(
                                            "Delivery Address",
                                            style:
                                                TextStyle(color: Colors.grey),
                                          ),
                                        ),
                                      ),
                                      e == deliveryAddress
                                          ? Positioned(
                                              top: 10,
                                              right: 10,
                                              child: Container(
                                                child: Icon(Icons.done_rounded),
                                              ),
                                            )
                                          : Container(),
                                    ],
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Payment Type",
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              paymentMethodName = "crypto";
                            });
                            BotToast.showText(text: "Crypto Payment Selected");
                          },
                          child: Container(
                              decoration: BoxDecoration(
                                boxShadow: paymentMethodName == "crypto"
                                    ? []
                                    : bxShadow,
                                color: paymentMethodName == "crypto"
                                    ? Colors.black
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: FaIcon(
                                        FontAwesomeIcons.bitcoin,
                                        color: paymentMethodName == "crypto"
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Text(
                                        "Crypto",
                                        style: TextStyle(
                                          color: paymentMethodName == "crypto"
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: InkWell(
                          onTap: () async {
                            setState(() {
                              paymentMethodName = "card";
                            });

                            BotToast.showText(
                                text: "Credit Card Payment Selected");
                          },
                          child: Container(
                              decoration: BoxDecoration(
                                boxShadow:
                                    paymentMethodName == "card" ? [] : bxShadow,
                                color: paymentMethodName == "card"
                                    ? Colors.black
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Icon(
                                        Icons.credit_card,
                                        color: paymentMethodName == "card"
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Text(
                                        "Card",
                                        style: TextStyle(
                                          color: paymentMethodName == "card"
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: InkWell(
                          onTap: () async {
                            setState(() {
                              paymentMethodName = "native";
                            });

                            BotToast.showText(text: "Native Payment Selected");
                          },
                          child: Container(
                              decoration: BoxDecoration(
                                boxShadow: paymentMethodName == "native"
                                    ? []
                                    : bxShadow,
                                color: paymentMethodName == "native"
                                    ? Colors.black
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: FaIcon(
                                        Platform.isAndroid
                                            ? FontAwesomeIcons.googlePay
                                            : FontAwesomeIcons.applePay,
                                        color: paymentMethodName == "native"
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Text(
                                        "Native",
                                        style: TextStyle(
                                          color: paymentMethodName == "native"
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          panel: Container(
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "Order Summary",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 30),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: widget.cartItems.map((e) {
                              Map<String, double> _receipt = {
                                e.productName: double.parse(e.productPrice) *
                                    e.quantitySelected
                              };
                              _receipt[e.productName] =
                                  double.parse(e.productPrice) *
                                      e.quantitySelected;
                              if (mounted) {
                                // setState(() {
                                //TODO:reciept ko uncomment krna h agr zarurat pri
                                // receipt = _receipt;
                                // });
                              }
                              // print(receipt);
                              return Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                      child: orderSummaryListProducts(e),
                                    ),
                                  ),
                                  e.bonus != null
                                      ? Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Container(
                                            decoration: BoxDecoration(
                                                color: Colors.grey[200],
                                                borderRadius:
                                                    BorderRadius.circular(12)),
                                            child: orderSummaryListBonus(e),
                                          ),
                                        )
                                      : Container(),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 10,
                  //left: 20,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Total :  £$totalBuyingPrice",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 27),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: InkWell(
                              onTap: () {
                                if (deliveryAddress != null &&
                                    allAddresses.isNotEmpty) {
                                  if (paymentMethodName != null &&
                                          paymentMethodName == "card" ||
                                      paymentMethodName == "native") {
                                    buyingWarning(context);
                                  } else if (paymentMethodName != null &&
                                      paymentMethodName == "crypto") {
                                    print(deliveryAddress.address);
                                    enterCryptoWallet(context);
                                  } else {
                                    BotToast.showText(
                                        text: "Select payment Method");
                                  }
                                } else if (deliveryAddress != null &&
                                    allAddresses.isEmpty) {
                                  BotToast.showText(
                                      text:
                                          "Please Select Delivery Address First");
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => DeliveryAddress(
                                                justViewing: false,
                                              )));
                                } else {
                                  BotToast.showText(
                                      text:
                                          "Please Select Delivery Address First");
                                }
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(20)),
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Row(
                                    children: [
                                      Text(
                                        "CONFIRM",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Icon(
                                        Icons.done,
                                        color: Colors.white,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Row orderSummaryListProducts(FavCart e) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Container(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              e.productName,
              style: checkOutTextStyle(),
            ),
          ),
          width: 130,
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "£${e.productPrice}",
            style: checkOutTextStyle(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "Qty:${e.quantitySelected}",
            style: checkOutTextStyle(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "£${double.parse(e.productPrice) * e.quantitySelected}",
            style: checkOutTextStyle(),
          ),
        ),
      ],
    );
  }

  Row orderSummaryListBonus(FavCart e) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Container(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              e.bonus,
              style: checkOutTextStyle(),
            ),
          ),
          width: 130,
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "£0",
            style: checkOutTextStyle(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "Qty:${e.bonusQuantity}",
            style: checkOutTextStyle(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "£${double.parse(e.productPrice) * e.quantitySelected}",
            style: checkOutTextStyle(),
          ),
        ),
      ],
    );
  }

  buyingWarning(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: Center(child: Text("IMPORTANT INFORMATION")),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0)),
            //backgroundColor: Colors.black,
            elevation: 20.0,
            titlePadding: EdgeInsets.all(10.0),
            contentPadding: EdgeInsets.all(10.0),
            children: [
              Text(
                  "Warning Germination of Cannabis seeds is illegal in most countries.\n\nPlease note: You have to be at least 18 years old to order cannabis seeds from KANNAPY.\n\nBy section 6 of the Misuse of Drugs Act 1971 it is an offence to cultivate any plant of the genus Cannabis in the United Kingdom without a license from the Secretary of State. Anyone committing an offence contrary to this section may be imprisoned of fined, or both. Please note therefore that germination of cannabis seeds without an appropriate license is illegal in the United Kingdom.\n\nKANNAPY does not encourage anyone to break the law in their country.\n\nKANNAPY cannot be held responsible for the actions of persons who purchase our Cannabis seeds. KANNAPY can sell you cannabis seeds legally for the use of fishing bait additives or as adult souvenirs, or you may purchase to collect and store, incase the law changes.\n\nInternational Warning!\n\nWe dispatch our seeds on the condition that they will not be used by others in conflict with applicable local law. Unfortunately, regulation and implementation in respect of Cannabis seeds often differ from country to country. For this reason we advise you as a matter of urgency to make inquiries about the regulations to which you are subject. It is your responsibility to check with your local laws. As a KANNAPY company customer, you are prohibited from distributing seeds bought from KANNAPY to countries where possession of and/or trafficking in Cannabis seeds is illegal. This site is intended for those persons 18 years of age and older.\n\nFor your own protection we 'require' you to inquire about and comply with all local laws and international laws governing the purchase of marijuana seeds/cannabis seeds in your part of the world. In many countries, it is illegal to germinate these cannabis seeds. By ordering, 'you confirm that you checked your local and international law and it is safe to do so' and that the responsibility for that decision rests solely upon you.\n\nAll cannabis seeds / marijuana seeds are for sold educational and Souvenir purposes only."),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RaisedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("Cancel"),
                  ),
                  RaisedButton(
                    onPressed: () async {
                      setState(() {
                        totalAmountBeforeShipping = totalBuyingPrice *
                            100.0; // multipliying with 100 to change $ to cents
                        if (deliveryAddress.country == 'United Kingdom') {
                          totalBuyingPrice >= 250
                              ? shipCost = 0
                              : shipCost = 5.0;
                        } else {
                          totalBuyingPrice >= 250
                              ? shipCost = 0
                              : shipCost = 10.0;
                        }
                        finalTotalAmountAfterShipping =
                            totalBuyingPrice + shipCost;
                      });
                      if (paymentMethodName == "native") {
                        Navigator.pop(context);
                        //TODO: token ko uncomment krna h agr zarurat pri
                        createPaymentMethodNative();
                        // var token = await receiptPayment;
                        // widget.cartItems.forEach((e) async {
                        //   String userOrderHistoryId = Uuid().v4();
                        //   String adminOrderHistoryId = Uuid().v4();
                        //   await addPaymentDetailsToFirestore(
                        //       orderId: orderId,
                        //       user: currentUser,
                        //       address: deliveryAddress,
                        //       productPrice: double.parse(e.productPrice),
                        //       cart: e,
                        //       userOrderHistoryId: userOrderHistoryId,
                        //       adminOrderHistoryId: adminOrderHistoryId,
                        //       paymentType: "native",
                        //       productItems: null,
                        //       isCart: true);
                        //   updateProductQuantity(e);
                        //   updateProductBuyers(e);
                        //   mailFunction(
                        //       e: e,
                        //       orderId: orderId,
                        //       deliveryAddress: deliveryAddress);
                        // });

                        Navigator.pop(context);
                        setState(() {
                          totalBuyingPrice = 0;
                        });
                        //print(token);
                        //StripeNative.confirmPayment(true);
                      } else {
                        Navigator.pop(context);
                        return startPaymentProcess();
                      }
                    },
                    child: Text("Accept"),
                  ),
                ],
              ),
            ],
          );
        });
  }

  confirmDialog(String clientSecret, PaymentMethod paymentMethod,
      Address deliveryAddress) {
    double shipCost = 0;
    // if (deliveryAddress.country == 'United Kingdom') {
    //   totalBuyingPrice >= 250 ? shipCost = 0 : shipCost = 5;
    // } else {
    //   totalBuyingPrice >= 250 ? shipCost = 0 : shipCost = 10;
    // }
    // setState(() {
    //   finalPayment = totalBuyingPrice + shipCost;
    // });
    var confirm = AlertDialog(
      contentPadding: EdgeInsets.all(12),
      titlePadding: EdgeInsets.all(12),
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      actionsPadding: EdgeInsets.all(8),
      buttonPadding: EdgeInsets.all(8),
      title: Text("Confirm Payment"),
      content: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text("Product price: £$totalBuyingPrice"),
            deliveryAddress.country != "United Kingdom"
                ? Container(
                    child: totalBuyingPrice <= 250
                        ? Text("Shipping price: £10\$")
                        : Text("Shipping price: £0\$"),
                  )
                : Text(''),
            deliveryAddress.country == "United Kingdom"
                ? Container(
                    child: totalBuyingPrice <= 250
                        ? Text("Shipping price: £5\$")
                        : Text("Shipping price: £0\$"),
                  )
                : Text(''),
            Text("Total price:£$finalTotalAmountAfterShipping"),
          ],
        ),
      ),
      actions: <Widget>[
        new RaisedButton(
          child: new Text('CANCEL'),
          onPressed: () {
            Navigator.of(context).pop();
            BotToast.showText(text: "Payment Cancelled");
          },
        ),
        new RaisedButton(
          child: new Text('Confirm'),
          onPressed: () {
            Navigator.of(context).pop();
            setState(() {
              showSpinner = true;
            });

            confirmPayment(
                clientSecret: clientSecret,
                paymentMethod: paymentMethod); // function to confirm Payment
          },
        ),
      ],
    );
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return confirm;
        });
  }

  confirmPayment(
      {@required String clientSecret, @required PaymentMethod paymentMethod}) {
    StripePayment.confirmPaymentIntent(
      PaymentIntent(
          clientSecret: clientSecret, paymentMethodId: paymentMethod.id),
    ).then((val) async {
      widget.cartItems.forEach((e) async {
        String userOrderHistoryId = Uuid().v4();
        String adminOrderHistoryId = Uuid().v4();
        await addPaymentDetailsToFirestore(
            user: currentUser,
            address: deliveryAddress,
            orderId: orderId,
            productPrice: double.parse(e.productPrice),
            cart: e,
            userOrderHistoryId: userOrderHistoryId,
            adminOrderHistoryId: adminOrderHistoryId,
            productItems: null,
            isCart: true);
        updateProductQuantity(e);
        updateProductBuyers(e);
        print("name: " + e.productName);
        var tempPrice = double.parse(e.productPrice) * e.quantitySelected;
        String ttlProductPrice = "$tempPrice";
        var tempProductTable = productInTable
            .replaceAll('{{IMAGE_URL}}', "${e.mediaUrl}")
            .replaceAll('{{PRODUCT_NAME}}', "${e.quantitySelected}")
            .replaceAll("{{PRODUCT_PRICE}}", "$ttlProductPrice")
            .replaceAll("{{QTY}}", "${e.quantitySelected}");
        var tempBonusTable = productInTable
            .replaceAll('{{IMAGE_URL}}', "${e.mediaUrl}")
            .replaceAll('{{PRODUCT_NAME}}', "${e.bonus}")
            .replaceAll("{{PRODUCT_PRICE}}", "0")
            .replaceAll("{{QTY}}", "${e.bonusQuantity}");
        orderMailCheckOut = orderMail + tempProductTable + tempBonusTable;
      });
      mailFunction(
        orderId: orderId,
        deliveryAddress: deliveryAddress,
      );
      setState(() {
        showSpinner = false;
        totalBuyingPrice = 0;
      });
      orderMailCheckOut = orderMail;

      Navigator.pop(context);

      BotToast.showText(text: "Transaction Successful");
    });
  }

  mailFunction({String orderId, Address deliveryAddress}) {
    // var tempPrice = double.parse(e.productPrice) * e.quantitySelected;
    // String ttlProductPrice = "$tempPrice";
    // String quantitySelected = "e.quantitySelected";
    var templateEndingCheckOut = templateEnding;
    setState(() {
      orderMailCheckOut = orderMailCheckOut + templateEndingCheckOut;
    });
    var date = "${timestamp.day}/${timestamp.month}/${timestamp.year}";
    String mailType = paymentMethodName == "crypto"
        ? _cryptoController.text
        : deliveryAddress.email;

    var message;
    message = orderMailCheckOut
        .replaceAll("{{ORDER_ID}}", "$orderId")
        .replaceAll("{{ORDER_DATE}}", date)
        .replaceAll("{{SUBTOTAL}}", "$totalBuyingPrice")
        .replaceAll("{{ADDRESS_NAME}}", "${deliveryAddress.name}")
        .replaceAll("{{ADDRESS_LOCATION}}", deliveryAddress.address)
        .replaceAll("{{ADDRESS_COUNTRY}}", "${deliveryAddress.country}")
        .replaceAll("{{SHIPPING_RATE}}", "£10")
        .replaceAll("{{ORDER_TOTAL}}", "${totalBuyingPrice + 10}");
    orderMailCheckOut = orderMail;
    templateEndingCheckOut = templateEnding;
    sendMail(
        recipientEmail: mailType,
        text: "Thank You for Purchasing",
        subject: "Purchase",
        html: message);
  }

  // ignore: deprecated_member_use
  final HttpsCallable intent = CloudFunctions.instance
      // ignore: deprecated_member_use
      .getHttpsCallable(functionName: 'createPaymentIntent');

  Future<void> createPaymentMethodNative() async {
    print('started NATIVE payment...');
    StripePayment.setStripeAccount(null);
    List<ApplePayItem> items = [];
    List<LineItem> androidItems = [];
    widget.cartItems.forEach((e) {
      items.add(ApplePayItem(
        label: "${e.quantitySelected}x ${e.productName}",
        amount: "${double.parse(e.productPrice) * e.quantitySelected}",
      ));
      androidItems.add(LineItem(
        currencyCode: "GBP",
        quantity: e.quantitySelected.toString(),
        unitPrice: e.productPrice,
        description: e.productSubHeading,
        totalPrice: "${double.parse(e.productPrice) * e.quantitySelected}",
      ));
    });
    items.add(ApplePayItem(
      label: 'Total',
      amount: totalBuyingPrice.toString(),
    ));
    print(
        'amount in pence/cent which will be charged = $finalTotalAmountAfterShipping');
    //step 1: add card
    PaymentMethod paymentMethod = PaymentMethod();
    Token token = await StripePayment.paymentRequestWithNativePay(
      androidPayOptions: AndroidPayPaymentRequest(
        totalPrice: finalTotalAmountAfterShipping.toStringAsFixed(2),
        currencyCode: 'GBP',
        shippingAddressRequired: true,
        lineItems: androidItems,
      ),
      applePayOptions: ApplePayPaymentOptions(
        countryCode: 'GB',
        currencyCode: 'GBP',
        items: items,
      ),
    );
    paymentMethod = await StripePayment.createPaymentMethod(
      PaymentMethodRequest(
        card: CreditCard(
          token: token.tokenId,
        ),
      ),
    );
    paymentMethod != null
        ? intent.call(<String, dynamic>{
            'amount': finalTotalAmountAfterShipping,
            'currency': 'GBP'
          }).then((response) => confirmPayment(
            clientSecret: response.data["client_secret"],
            paymentMethod: paymentMethod))
        : showDialog(
            context: context,
            builder: (BuildContext context) => ShowDialogToDismiss(
                title: 'Error',
                content:
                    'It is not possible to pay with this card. Please try again with a different card',
                buttonText: 'CLOSE'));
  }

  startPaymentProcess() {
    StripePayment.paymentRequestWithCardForm(CardFormPaymentRequest())
        .then((paymentMethod) {
      setState(() {
        showSpinner = true;
      });
      BotToast.showText(text: "Wait for Confirmation Dialog!!");
      double finalPriceForStripe = finalTotalAmountAfterShipping * 100;
      intent.call(<String, dynamic>{
        'amount': finalPriceForStripe,
        'currency': 'gbp'
      }).then((response) {
        confirmDialog(response.data["client_secret"], paymentMethod,
            deliveryAddress); //function for confirmation for payment
      });
    });
  }

  selectLocation(BuildContext parentContext) async {
    BotToast.showText(text: "Select Delivery Address");
    return await Navigator.of(context)
        .push(MaterialPageRoute(
            builder: (context) => DeliveryAddress(
                  justViewing: false,
                )))
        .then((value) {
      if (deliveryAddress == null) {
        BotToast.showText(text: "Delivery Address Not Selected");
      } else {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => CheckOut(
                      cartItems: widget.cartItems,
                    )));
      }
    });
  }

  updateProductBuyers(FavCart cart) async {
    auctionTimelineRef.doc(cart.productId).get().then((value) {
      if (value.exists) {
        value.reference.update({
          "allBuyers": FieldValue.arrayUnion([currentUser.id])
        });
      }
    });
    // auctionVaultTimelineRef.doc(cart.productId).get().then((value) {
    //   if (value.exists) {
    //     value.reference.update({
    //       "allBuyers": FieldValue.arrayUnion([currentUser.id])
    //     });
    //   }
    // });
    seedVaultTimelineRef.doc(cart.productId).get().then((value) {
      if (value.exists) {
        value.reference.update({
          "allBuyers": FieldValue.arrayUnion([currentUser.id])
        });
      }
    });
    storeTimelineRef.doc(cart.productId).get().then((value) {
      if (value.exists) {
        value.reference.update({
          "allBuyers": FieldValue.arrayUnion([currentUser.id])
        });
      }
    });
  }

  updateProductQuantity(FavCart cart) async {
    int newQuantity = int.parse(cart.quantity) - cart.quantitySelected;

    await storeTimelineRef.doc(cart.productId).get().then((value) {
      if (value.exists) {
        value.reference.update({"quantity": newQuantity.toString()});
      }
    });
    await seedVaultTimelineRef.doc(cart.productId).get().then((value) {
      if (value.exists) {
        value.reference.update({"quantity": newQuantity.toString()});
      }
    });
  }

  enterCryptoWallet(BuildContext parentContext) {
    final _textFormKey = GlobalKey<FormState>();
    return showDialog(
        context: _scaffoldKey.currentContext,
        builder: (context) {
          return SimpleDialog(
            elevation: 6,
            title: Center(child: Text("Enter Your E-Mail Address")),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0)),
            titlePadding: EdgeInsets.all(12.0),
            contentPadding: EdgeInsets.all(12.0),
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                    "PLEASE PROCEED THROUGH CHECKOUT PROCESS TO CONFIRM ORDER AS USUAL.\nOUR SALES TEAM WILL EMAIL YOU A LINK TO MAKE PAYMENT FOR GOODS.UPON CONFIRMATION OF PAYMENT. WE WILL UPDATE THE STATUS OF THE ORDER TO REFLECT THIS AND DISPATCH ITEMS ACCORDINGLY.ALL PAYMENT MUST BE MADE ON RECEIPT OF CRYPTO INVOICE.ITEMS FOR WHICH PAYMENT IS NOT RECEIVED, WILL BE RE-ADVERTISED WITHIN 24 HOURS.\nWE RESERVE THE RIGHT TO CANCEL ANY ORDER IF WE DEEMED IN BREACH OF OUR TERMS AND CONDITIONS"),
              ),
              SizedBox(
                height: 10,
              ),
              Form(
                key: _textFormKey,
                child: TextFormField(
                  onSaved: (val) => _cryptoController.text = val,
                  validator: (val) {
                    if (val.isEmpty) {
                      return "Field is Empty";
                    } else if (!val.contains("@") || val.trim().length < 7) {
                      return "Invalid Email Address!";
                    } else {
                      return null;
                    }
                  },
                  // ignore: deprecated_member_use
                  autovalidate: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Enter Contact E-mail address",
                    hintText: "Must be valid address for contact",
                  ),
                  controller: _cryptoController,
                ),
              ),
              RaisedButton.icon(
                elevation: 6,
                padding: EdgeInsets.all(6),
                onPressed: () {
                  final _form = _textFormKey.currentState;
                  if (_form.validate()) {
                    setState(() {
                      cryptoEmail = _cryptoController.text;
                    });
                    Navigator.of(context).pop();
                    widget.cartItems.forEach((e) async {
                      await registerCryptoWallet(
                          cryptoEmail: cryptoEmail,
                          user: currentUser,
                          address: deliveryAddress,
                          orderId: orderId,
                          productPrice: double.parse(e.productPrice),
                          productItems: null,
                          cart: e,
                          isCart: true);
                      updateProductQuantity(e);
                      updateProductBuyers(e);
                    });
                    mailFunction(
                        deliveryAddress: deliveryAddress, orderId: orderId);
                    _cryptoController.clear();

                    //TODO:msg change krna pr skta h

                    BotToast.showText(
                        text: "Wallet SuccessFully Added",
                        onClose: () {
                          Navigator.pop(context);
                        });
                  } else {
                    _cryptoController.clear();
                    BotToast.showText(text: "Invalid input");
                  }
                },
                icon: FaIcon(FontAwesomeIcons.bitcoin),
                label: Text("Crypto Wallet"),
              ),
            ],
          );
        });
  }
}

registerCryptoWallet(
    {@required Address address,
    @required AppUser user,
    ProductItems productItems,
    FavCart cart,
    String orderId,
    @required bool isCart,
    @required double productPrice,
    @required String cryptoEmail}) async {
  var productOrCart;
  if (isCart) {
    productOrCart = cart;
  } else {
    productOrCart = productItems;
  }
  String userOrderHistoryId = Uuid().v4();
  String adminOrderHistoryId = Uuid().v4();

  await cardRef.doc(user.id).collection('payment').doc(userOrderHistoryId).set({
    "orderId": orderId,
    "paymentType": "crypto",
    "paymentReceived": false,
    "cryptoEmail": cryptoEmail,
    "adminOrderHistoryId": adminOrderHistoryId,
    "userOrderHistoryId": userOrderHistoryId,
    "userId": user.id,
    "userName": user.userName,
    "productId": productOrCart.productId,
    "quantity": quantitySelected.toString(),
    "currency": "GBP",
    'amount': productPrice,
    "timestamp": timestamp,
    "mediaUrl": isCart ? productOrCart.mediaUrl : productOrCart.mediaUrl[0],
    "productName": productOrCart.productName,
    "status": "Currently Pending",
    "deliveryTime": productOrCart.deliveryTime,
    "enteredName": address.name,
    "phoneNo": address.phone,
    "address": address.address,
    'email': address.email,
    'areaCode': address.areaCode,
    'country': address.country,
    "city": address.city,
    "trackingToken": null,
  });
  await adminOrderHistoryRef.doc(adminOrderHistoryId).set({
    "orderId": orderId,
    "paymentType": "crypto",
    "paymentReceived": false,
    "adminOrderHistoryId": adminOrderHistoryId,
    "userOrderHistoryId": userOrderHistoryId,
    "userId": user.id,
    "userName": currentUser.userName,
    "productId": productOrCart.productId,
    "quantity": quantitySelected.toString(),
    "currency": "GBP",
    'amount': productPrice,
    "timestamp": timestamp,
    "mediaUrl": isCart ? productOrCart.mediaUrl : productOrCart.mediaUrl[0],
    "productName": productOrCart.productName,
    "status": "Currently Pending",
    "deliveryTime": productOrCart.deliveryTime,
    "enteredName": address.name,
    "phoneNo": address.phone,
    "address": address.address,
    'email': address.email,
    'areaCode': address.areaCode,
    'country': address.country,
    "city": address.city,
    "trackingToken": null,
  });
  await activityFeedRef.doc(productOrCart.ownerId).collection('feedItems').add({
    "orderId": orderId,
    "type": "cryptoId",
    "commentData": "Purchase Intent through Crypto",
    "userName": currentUser.userName,
    "userId": currentUser.id,
    "userProfileImg": currentUser.photoUrl,
    "productOwnerId": productOrCart.ownerId,
    "mediaUrl": isCart ? productOrCart.mediaUrl : productOrCart.mediaUrl[0],
    "timestamp": timestamp,
    "rating": "",
    "productId": productOrCart.productId,
    "price": productPrice,
  });
  sendAndRetrieveMessage(
      token: currentUser.androidNotificationToken,
      message: "Purchase Intent through Crypto",
      title: "Item Purchase");
}

addPaymentDetailsToFirestore(
    {@required Address address,
    @required AppUser user,
    @required ProductItems productItems,
    @required FavCart cart,
    String userOrderHistoryId,
    String orderId,
    String adminOrderHistoryId,
    String paymentType = "card",
    @required double productPrice,
    @required bool isCart}) async {
  var productOrCart;
  if (isCart) {
    productOrCart = cart;
  } else {
    productOrCart = productItems;
  }

  await cardRef
      .doc(user.id)
      .collection('payments')
      .doc(userOrderHistoryId)
      .set({
    "orderId": orderId,
    "paymentType": paymentType,
    "paymentReceived": true,
    "adminOrderHistoryId": adminOrderHistoryId,
    "userOrderHistoryId": userOrderHistoryId,
    "userId": user.id,
    "userName": user.userName,
    "productId": productOrCart.productId,
    "quantity": quantitySelected.toString(),
    "currency": "GBP",
    'amount': productPrice,
    "timestamp": timestamp,
    "mediaUrl": isCart ? productOrCart.mediaUrl : productOrCart.mediaUrl[0],
    "productName": productOrCart.productName,
    "status": "Currently Pending",
    "deliveryTime": productOrCart.deliveryTime,
    "enteredName": address.name,
    "phoneNo": address.phone,
    "address": address.address,
    'email': address.email,
    'areaCode': address.areaCode,
    'country': address.country,
    "city": address.city,
    "trackingToken": null,
  });
  await adminOrderHistoryRef.doc(adminOrderHistoryId).set({
    "orderId": orderId,
    "paymentType": paymentType,
    "paymentReceived": true,
    "adminOrderHistoryId": adminOrderHistoryId,
    "userOrderHistoryId": userOrderHistoryId,
    "userId": user.id,
    "userName": currentUser.userName,
    "productId": productOrCart.productId,
    "quantity": quantitySelected.toString(),
    "currency": "GBP",
    'amount': productPrice,
    "timestamp": timestamp,
    "mediaUrl": isCart ? productOrCart.mediaUrl : productOrCart.mediaUrl[0],
    "productName": productOrCart.productName,
    "status": "Currently Pending",
    "deliveryTime": productOrCart.deliveryTime,
    "enteredName": address.name,
    "phoneNo": address.phone,
    "address": address.address,
    'email': address.email,
    'areaCode': address.areaCode,
    'country': address.country,
    "city": address.city,
    "trackingToken": null,
  });
  await activityFeedRef.doc(productOrCart.ownerId).collection('feedItems').add({
    "orderId": orderId,
    "type": "order",
    "commentData": "",
    "userName": currentUser.userName,
    "userId": currentUser.id,
    "userProfileImg": currentUser.photoUrl,
    "productOwnerId": productOrCart.ownerId,
    "mediaUrl": isCart ? productOrCart.mediaUrl : productOrCart.mediaUrl[0],
    "timestamp": timestamp,
    "rating": "",
    "productId": productOrCart.productId,
    "price": productPrice,
  });
  sendAndRetrieveMessage(
      token: currentUser.androidNotificationToken,
      message:
          "You have Purchased ${productOrCart.productName}. Await for its Delivery ",
      title: "Item Purchase");
}
