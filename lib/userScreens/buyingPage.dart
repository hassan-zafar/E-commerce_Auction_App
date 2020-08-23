import 'package:bot_toast/bot_toast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:kannapy/tools/productItems.dart';
import 'package:kannapy/userScreens/address.dart';
import 'package:kannapy/userScreens/home.dart';
import 'package:stripe_payment/stripe_payment.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

double totalBuyingPrice = 0;

class BuyingPage extends StatefulWidget {
  final ProductItems productItems;
  final String userId;
  final int quantitySelected;
  BuyingPage({this.productItems, this.userId, this.quantitySelected});
  @override
  _BuyingPageState createState() => _BuyingPageState();
}

class _BuyingPageState extends State<BuyingPage> {
  String address;

  @override
  void initState() {
    StripePayment.setOptions(StripeOptions(
        publishableKey:
            "pk_test_51HHbHhIW5aSFUbq7MB1gAtW2KNZTcn3wUNXmYw9aJ6QHNakdIOLEQfigxJyXtuJv1ShhKX70msCLAy3z38jbSRyL00i5QGCZfC"));
    getBuyingPrice();
    super.initState();
  }

  getBuyingPrice() {
    setState(() {
      totalBuyingPrice =
          widget.quantitySelected * double.parse(widget.productItems.price);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Buy Product'),
      ),
      body: ListTile(
        leading: Image(
          image: CachedNetworkImageProvider(widget.productItems.mediaUrl[0]),
          fit: BoxFit.contain,
        ),
        title: Text(
          widget.productItems.productName,
          style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
        ),
        trailing: Text(
          "Price: \$${widget.productItems.price}",
          style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
              color: Colors.orange),
        ),
        subtitle: Text(
          "x ${widget.quantitySelected}",
          style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
        ),
      ),
      bottomSheet: GestureDetector(
        onTap: () async {
          selectLocation(context);
        },
        child: Container(
          height: 80.0,
          color: Theme.of(context).accentColor,
          child: Center(
            child: Text('Place Order \$$totalBuyingPrice'),
          ),
        ),
      ),
    );
  }

  confirmDialog(
    String clientSecret,
    PaymentMethod paymentMethod,
  ) {
    var confirm = AlertDialog(
      title: Text("Confirm Payment"),
      content: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              "Make Payment",
              // style: TextStyle(fontSize: 25),
            ),
            Text("Charge amount:\$$totalBuyingPrice")
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
            confirmPayment(
                clientSecret, paymentMethod); // function to confirm Payment
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

  confirmPayment(String sec, PaymentMethod paymentMethod) {
    StripePayment.confirmPaymentIntent(
      PaymentIntent(clientSecret: sec, paymentMethodId: paymentMethod.id),
    ).then((val) {
      addPaymentDetailsToFirestore(
          address); //Function to add Payment details to firestore
      setState(() {
        totalBuyingPrice = 0;
      });
      Navigator.pop(context);
      BotToast.showText(text: "Transaction Successful");
    });
  }

  void addPaymentDetailsToFirestore(String address) {
    cardRef.document(widget.userId).collection('payments').add({
      "userId": widget.userId,
      "productId": widget.productItems.productId,
      "quantity": widget.quantitySelected,
      "currency": "USD",
      'amount': totalBuyingPrice,
      "address": deliveryAddress,
      "timestamp": timestamp,
      "mediaUrl": widget.productItems.mediaUrl[0],
      "productName": widget.productItems.productName,
      "timestamp": timestamp,
    });
  }

  final HttpsCallable INTENT = CloudFunctions.instance
      .getHttpsCallable(functionName: 'createPaymentIntent');

  startPaymentProcess() {
    StripePayment.paymentRequestWithCardForm(CardFormPaymentRequest())
        .then((paymentMethod) {
      double amount = totalBuyingPrice *
          100.0; // multipliying with 100 to change $ to cents
      INTENT.call(<String, dynamic>{'amount': amount, 'currency': 'usd'}).then(
          (response) {
        confirmDialog(response.data["client_secret"],
            paymentMethod); //function for confirmation for payment
      });
    });
  }

  selectLocation(BuildContext parentContext) async {
    return await Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => DeliveryAddress()))
        .then((value) => startPaymentProcess());
  }
}
