import 'package:bot_toast/bot_toast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:kannapy/models/fav_cart.dart';
import 'package:kannapy/tools/productItems.dart';
import 'package:kannapy/tools/progress.dart';
import 'package:kannapy/userScreens/address.dart';
import 'package:kannapy/userScreens/home.dart';
import 'package:stripe_payment/stripe_payment.dart';

double totalPriceInCart = 0;
List<String> totalProductIds = [];
List<double> totalPricePerItem = [];

class KannapyCart extends StatefulWidget {
  ProductItems productItems;
  String userId;
  KannapyCart({this.productItems, this.userId});
  @override
  _KannapyCartState createState() => _KannapyCartState();
}

class _KannapyCartState extends State<KannapyCart> {
  List<FavCart> cartList = [];

  @override
  void initState() {
    super.initState();
    StripePayment.setOptions(StripeOptions(
        publishableKey:
            "pk_test_51HHbHhIW5aSFUbq7MB1gAtW2KNZTcn3wUNXmYw9aJ6QHNakdIOLEQfigxJyXtuJv1ShhKX70msCLAy3z38jbSRyL00i5QGCZfC"));
    getCartItems();
  }

  getCartItems() async {
    QuerySnapshot cartSnapshot = await cartRef
        .document(widget.userId)
        .collection("cartItems")
        .getDocuments();
    List<FavCart> cartList =
        cartSnapshot.documents.map((doc) => FavCart.fromDocument(doc)).toList();
    setState(() {
      this.cartList = cartList;
    });
  }

  Future<bool> onBackPressed() {
    totalPricePerItem.clear();
    totalProductIds.clear();
    totalPriceInCart = 0;
    Navigator.of(context).pop(true);
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Cart'),
      ),
      body: WillPopScope(child: buildCart(), onWillPop: onBackPressed),
      bottomSheet: GestureDetector(
        onTap: () async {
          cartList.forEach((element) async {
            totalPriceInCart += element.productPrice;
          });
          selectLocation(context);
        },
        child: Container(
          height: 80.0,
          color: Theme.of(context).accentColor,
          child: Center(
            child: Text('Place Order'),
          ),
        ),
      ),
    );
  }

  buildCart() {
    return ListView.separated(
        itemBuilder: (BuildContext context, index) {
          return Dismissible(
            child: ListTile(
              leading: Image(
                image: CachedNetworkImageProvider(cartList[index].mediaUrl),
                fit: BoxFit.contain,
              ),
              title: Text(
                cartList[index].productName,
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
              trailing: Text(
                "Price: \$${cartList[index].productPrice.toString()}",
                style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange),
              ),
              subtitle: Text(
                "x1",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            key: UniqueKey(),
            onDismissed: (direction) {
              setState(() {
                cartRef
                    .document(currentUser.id)
                    .collection("cartItems")
                    .document(cartList[index].productId)
                    .delete();
                cartList.removeAt(index);
              });
              BotToast.showText(text: "Deleted To Cart");
            },
            background: Container(
              alignment: Alignment.centerRight,
              color: Colors.red,
              child: Text('DELETE'),
            ),
            direction: DismissDirection.horizontal,
          );
        },
        separatorBuilder: (BuildContext context, index) {
          return Divider();
        },
        itemCount: cartList.length);
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
            Text("Charge amount:\$$totalPriceInCart")
          ],
        ),
      ),
      actions: <Widget>[
        new RaisedButton(
          child: new Text('CANCEL'),
          onPressed: () {
            totalPriceInCart = 0;
            Navigator.of(context).pop();
            BotToast.showText(text: 'Payment Cancelled');
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
      addPaymentDetailsToFirestore(); //Function to add Payment details to firestore
      BotToast.showText(text: "Payment Successful!");
      setState(() {
        totalPriceInCart = 0;
      });
      Navigator.pop(context);
    });
  }

  void addPaymentDetailsToFirestore() {
    //TODO:
    cartList.forEach((element) {
      cardRef.document(currentUser.id).collection('payments').add({
        "userId": currentUser.id,
        "productId": element.productId,
        "quantity": 1,
        "currency": "USD",
        'amount': element.productPrice,
        "address": currentUser.address.last,
        "timestamp": timestamp,
        "mediaUrl": element.mediaUrl,
        "productName": element.productName,
        "timestamp": timestamp,
      });
    });
  }

  final HttpsCallable INTENT = CloudFunctions.instance
      .getHttpsCallable(functionName: 'createPaymentIntent');

  startPaymentProcess() {
    StripePayment.paymentRequestWithCardForm(CardFormPaymentRequest())
        .then((paymentMethod) {
      double amount = totalPriceInCart *
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
