import 'package:bot_toast/bot_toast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kannapy/adminScreens/commentsNChat.dart';
import 'package:kannapy/models/card.dart';
import 'package:kannapy/tools/CommonFunctions.dart';
import 'package:kannapy/tools/uiFunctions.dart';
import 'package:kannapy/userScreens/home.dart';

class OrderDetails extends StatefulWidget {
  final CardDataNAdminOrderHistory orderHistory;
  OrderDetails(this.orderHistory);

  @override
  _OrderDetailsState createState() => _OrderDetailsState();
}

class _OrderDetailsState extends State<OrderDetails> {
  String status;
  bool paymentReceived = false;
  TextEditingController _trackingCompanyController = TextEditingController();
  TextEditingController _trackingController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    setState(() {
      status = widget.orderHistory.status;
      paymentReceived = widget.orderHistory.paymentReceived;
    });

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('ORDER DETAILS'),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildOrderSummary(context),
                  SizedBox(
                    height: 15.0,
                  ),
                  buildShippingDetails(context),
                  SizedBox(
                    height: 15.0,
                  ),
                  widget.orderHistory.deliveryService != null
                      ? buildDeliveryService(context)
                      : Container(),
                  SizedBox(
                    height: 40,
                  ),
                ],
              ),
            ),
          ),
        ),
        floatingActionButtonLocation:
            isAdmin ? FloatingActionButtonLocation.centerDocked : null,
        floatingActionButton: isAdmin
            ? FloatingActionButton(
                tooltip: "Edit Delivery Status",
                child: Icon(
                  Icons.edit,
                  color: Colors.white,
                ),
                backgroundColor: Colors.black,
                onPressed: () {
                  editOrderStatus(context);
                },
              )
            : null,
        bottomNavigationBar: isAdmin
            ? BottomAppBar(
                color: Theme.of(context).primaryColor,
                shape: CircularNotchedRectangle(),
                notchMargin: 5.0,
                elevation: 5.0,
                child: Container(
                  height: 50.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => CommentsNChat(
                                        isPostComment: false,
                                        isProductComment: false,
                                        chatId: widget.orderHistory.userId,
                                      )));
                        },
                        child: Container(
                          width: (MediaQuery.of(context).size.width - 20) / 2,
                          child: Text(
                            "SEND MESSAGE",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          cancelOrderDialog(context);
                        },
                        child: Container(
                          width: (MediaQuery.of(context).size.width - 20) / 2,
                          child: Text(
                            "CANCEL ORDER",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : null,
      ),
    );
  }

  Neumorphic buildShippingDetails(BuildContext context) {
    return neumorphicTile(
      padding: 16,
      anyWidget: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Shipping Details',
            style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.headline1.color),
          ),
          Divider(
            thickness: 2,
          ),
          Text(
            widget.orderHistory.enteredName != null
                ? "Name Provided: ${widget.orderHistory.enteredName}"
                : "Entered Name",
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 10),
          Text(
            "Phone No: ${widget.orderHistory.phoneNo}",
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 10),
          Text(
            "Email: ${widget.orderHistory.email}",
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 10),
          Text(
            "Address: ${widget.orderHistory.address}",
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 10),
          Text(
            "City: ${widget.orderHistory.city}",
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 10),
          Text(
            "Country: ${widget.orderHistory.country}",
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Neumorphic buildDeliveryService(BuildContext context) {
    return neumorphicTile(
      padding: 16,
      anyWidget: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Delivery Service',
            style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.headline1.color),
          ),
          Divider(
            thickness: 2,
          ),
          Text(
            widget.orderHistory.deliveryService != null
                ? "Delivery Service Name: ${widget.orderHistory.deliveryService}"
                : "Entered Name",
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 10),
          Text(
            "Order Tracking Token: ${widget.orderHistory.trackingToken}",
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  buildOrderSummary(BuildContext context) {
    return neumorphicTile(
      padding: 16,
      anyWidget: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Summary',
            style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.headline1.color),
          ),
          Divider(
            thickness: 1,
          ),
          Center(
            child: Image(
              image: CachedNetworkImageProvider(widget.orderHistory.mediaUrl),
              fit: BoxFit.fitHeight,
            ),
          ),
          SizedBox(
            height: 8.0,
          ),
          Text(
            "Name :${widget.orderHistory.productName}",
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(
            height: 8.0,
          ),
          Text(
            "Payment :\$${widget.orderHistory.amount}\$",
            style: TextStyle(fontSize: 20),
          ),
          SizedBox(
            height: 8.0,
          ),
          Text(
            "Delivery Status :$status",
            style: TextStyle(
                fontSize: 20,
                color: status == "Delivered" ? Colors.black : Colors.red),
          ),
          SizedBox(
            height: 8.0,
          ),
          widget.orderHistory.paymentType == "crypto"
              ? Text(
                  paymentReceived
                      ? "CryptoPayment Status : Payment Received"
                      : "CryptoPayment Status : Payment Pending",
                  style: TextStyle(
                      fontSize: 20,
                      color: paymentReceived ? Colors.black : Colors.red),
                )
              : SizedBox(
                  height: 0.1,
                ),
          SizedBox(
            height: 8.0,
          ),
          Text(
            "Payment Type :${widget.orderHistory.paymentType}",
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(
            height: 8.0,
          ),
          Text(
            "Quantity :${widget.orderHistory.quantity}",
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(
            height: 8.0,
          ),
          Text(
            "Estimated Delivery Days :${widget.orderHistory.deliveryTime} days",
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(
            height: 8.0,
          ),
          Text(
            "Date of Order Placement :\n ${widget.orderHistory.timestamp.toDate().day}/${widget.orderHistory.timestamp.toDate().month}/${widget.orderHistory.timestamp.toDate().year} (d/m/y)",
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(
            height: 8.0,
          ),
          Text(
            "Time of Order Placement : ${widget.orderHistory.timestamp.toDate().hour}h:${widget.orderHistory.timestamp.toDate().minute}m:${widget.orderHistory.timestamp.toDate().second}s",
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  cancelOrderDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            titlePadding: EdgeInsets.all(8),
            title: Center(child: Text("Warning")),
            contentPadding: EdgeInsets.all(8),
            children: [
              Text(
                "Do you want to Cancel Order!!",
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
              ),
              SimpleDialogOption(
                onPressed: () {
                  setState(() {
                    status = "Cancelled";
                  });
                  adminOrderHistoryRef
                      .doc(widget.orderHistory.adminOrderHistoryId)
                      .get()
                      .then((value) {
                    if (value.data()['status'] != status) {
                      value.reference.update({'status': status});

                      BotToast.showText(text: 'Order Cancelled');
                    } else {
                      BotToast.showText(text: 'Order Already Cancelled');
                    }
                  });
                  cardRef
                      .doc(widget.orderHistory.userOrderHistoryId)
                      .collection('payments')
                      .doc(widget.orderHistory.productId)
                      .get()
                      .then((value) {
                    if (value.exists && value.data()['status'] != status) {
                      value.reference.update({'status': status});
                    }
                  });
                  //TODO:msg change krna pr skta h
                  sendMail(
                      recipientEmail: widget.orderHistory.email,
                      subject: "Regarding Order Cancellation",
                      text:
                          "Your Order of ${widget.orderHistory.quantity} x ${widget.orderHistory.productName} has been cancelled");
                  BotToast.showText(text: "Order Cancelled");
                },
                child: neumorphicTile(
                    anyWidget: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [Icon(Icons.cancel), Text("Confirm Cancel")],
                )),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: neumorphicTile(
                    anyWidget: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [Icon(Icons.arrow_back), Text("Go back")],
                )),
              ),
            ],
          );
        });
  }

  editOrderStatus(BuildContext parentContext) {
    return showDialog(
        context: parentContext,
        builder: (context) {
          return SimpleDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            titlePadding: EdgeInsets.all(8),
            contentPadding: EdgeInsets.all(8),
            elevation: 6,
            title: Center(
              child: Text("Change Status"),
            ),
            children: <Widget>[
              Divider(),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context);
                  adminOrderHistoryRef
                      .doc(widget.orderHistory.adminOrderHistoryId)
                      .get()
                      .then((value) {
                    if (value.data()['status'] == "Currently Pending") {
                      value.reference.update({'status': "Delivered"});
                      BotToast.showText(text: 'Status Updated');
                      setState(() {
                        status = "Delivered";
                      });
                      //TODO:msg change krna pr skta h
                      sendMail(
                          recipientEmail: widget.orderHistory.email,
                          subject: "Delivery",
                          text: "Your product has been delivered");
                    } else {
                      BotToast.showText(text: 'Already Updated');
                    }
                  });
                  cardRef
                      .doc(widget.orderHistory.userOrderHistoryId)
                      .collection('payments')
                      .doc(widget.orderHistory.productId)
                      .get()
                      .then((value) {
                    if (value.exists &&
                        value.data()['status'] == "Currently Pending") {
                      value.reference.update({'status': "Delivered"});
                    }
                  });
                },
                child: neumorphicTile(
                  anyWidget: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Icon(Icons.local_shipping),
                      Text(
                        'Delivery Status Update',
                      ),
                    ],
                  ),
                ),
              ),
              widget.orderHistory.paymentReceived == true
                  ? Container()
                  : SimpleDialogOption(
                      onPressed: () {
                        Navigator.pop(context);
                        adminOrderHistoryRef
                            .doc(widget.orderHistory.adminOrderHistoryId)
                            .get()
                            .then((value) {
                          if (value.data()['paymentReceived'] == false) {
                            value.reference.update({'paymentReceived': true});
                            BotToast.showText(text: "Payment Status Updated");

                            setState(() {
                              paymentReceived = true;
                            });
                            //TODO:msg change krna pr skta h
                            sendMail(
                                recipientEmail: widget.orderHistory.email,
                                subject: "Regarding Crypto Payment",
                                text: "Your payment has been received");
                          } else {
                            BotToast.showText(text: 'Already Updated');
                          }
                        });
                        cardRef
                            .doc(widget.orderHistory.userOrderHistoryId)
                            .collection('payments')
                            .doc(widget.orderHistory.productId)
                            .get()
                            .then((value) {
                          if (value.exists &&
                              value.data()['paymentReceived'] == false) {
                            value.reference.update({'paymentReceived': true});
                          }
                        });
                      },
                      child: neumorphicTile(
                        padding: 8,
                        anyWidget: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            FaIcon(FontAwesomeIcons.wallet),
                            Text('Pending Payment Update'),
                          ],
                        ),
                      ),
                    ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context);
                  enterTrackingTicket(context);
                },
                child: neumorphicTile(
                  padding: 8,
                  anyWidget: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      FaIcon(FontAwesomeIcons.mapMarkedAlt),
                      Text('Update Tracking Token'),
                    ],
                  ),
                ),
              ),
              SimpleDialogOption(
                onPressed: () => Navigator.pop(context),
                child: neumorphicTile(
                  padding: 8,
                  anyWidget: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.cancel),
                      Text('Cancel'),
                    ],
                  ),
                ),
              )
            ],
          );
        });
  }

  enterTrackingTicket(BuildContext context) {
    final _textFormKey = GlobalKey<FormState>();
    return showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            elevation: 6,
            title: Center(child: Text("Enter Product's Tracking Ticket")),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0)),
            titlePadding: EdgeInsets.all(12.0),
            contentPadding: EdgeInsets.all(12.0),
            children: [
              SizedBox(
                height: 10,
              ),
              Form(
                key: _textFormKey,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        onSaved: (val) => _trackingCompanyController.text = val,
                        validator: (val) {
                          if (val.isEmpty) {
                            return "Field is Empty";
                          } else if (val.trim().length < 5) {
                            return "Invalid Name!";
                          } else {
                            return null;
                          }
                        },
                        // ignore: deprecated_member_use
                        autovalidate: true,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Delivery Service Name",
                          hintText: "Enter Delivery Service Name",
                        ),
                        controller: _trackingCompanyController,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        onSaved: (val) => _trackingController.text = val,
                        validator: (val) {
                          if (val.isEmpty) {
                            return "Field is Empty";
                          } else if (val.trim().length < 5) {
                            return "Invalid Tracking Ticket!";
                          } else {
                            return null;
                          }
                        },
                        // ignore: deprecated_member_use
                        autovalidate: true,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Enter Tracking Ticket ID",
                          hintText: "Must be valid ID",
                        ),
                        controller: _trackingController,
                      ),
                    ),
                  ],
                ),
              ),
              RaisedButton.icon(
                elevation: 6,
                padding: EdgeInsets.all(6),
                onPressed: () {
                  final _form = _textFormKey.currentState;
                  if (_form.validate()) {
                    adminOrderHistoryRef
                        .doc(widget.orderHistory.adminOrderHistoryId)
                        .get()
                        .then((value) {
                      value.reference.update({
                        'deliveryService': _trackingCompanyController.text,
                        "trackingToken": _trackingController.text,
                      });
                      BotToast.showText(text: 'Information Updated');
                      //TODO:msg change krna pr skta h
                      sendMail(
                          recipientEmail: widget.orderHistory.email,
                          subject: "Your Order is on its way",
                          text:
                              "You can track your order with this Tracking id ${_trackingController.text} on the website of ${_trackingCompanyController.text}");
                    });
                    cardRef
                        .doc(widget.orderHistory.userOrderHistoryId)
                        .collection('payments')
                        .doc(widget.orderHistory.productId)
                        .get()
                        .then((value) {
                      value.reference.update({
                        'deliveryService': _trackingCompanyController.text,
                        "trackingToken": _trackingController.text,
                      });
                      BotToast.showText(text: 'Information Updated');
                    }).then((value) => Navigator.pop(context));
                  } else {}
                },
                icon: FaIcon(FontAwesomeIcons.mapMarkedAlt),
                label: Text("Confirm"),
              ),
            ],
          );
        });
  }
}
