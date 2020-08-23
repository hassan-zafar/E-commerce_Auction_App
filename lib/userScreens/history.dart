import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kannapy/models/card.dart';
import 'package:kannapy/tools/progress.dart';
import 'package:kannapy/userScreens/home.dart';

class OrderHistory extends StatefulWidget {
  @override
  _OrderHistoryState createState() => _OrderHistoryState();
}

class _OrderHistoryState extends State<OrderHistory> {
  List<CardData> orderHistory = [];
  @override
  void initState() {
    getOrdersHistory();
    super.initState();
  }

  getOrdersHistory() async {
    QuerySnapshot historySnapshot = await cardRef
        .document(currentUser.id)
        .collection("payments")
        .getDocuments();
    orderHistory =
        historySnapshot.documents.map((e) => CardData.fromDocument(e)).toList();
    setState(() {
      this.orderHistory = orderHistory;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Order History'),
        ),
        body: ListView.separated(
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => handleHistoryDetails(context, index),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Image(
                      image: CachedNetworkImageProvider(
                        orderHistory[index].mediaUrl,
                      ),
                      fit: BoxFit.fitHeight,
                    ),
                  ),
                  title: Text(orderHistory[index].productName),
                  trailing:
                      Text("Price: \$${orderHistory[index].amount.toString()}"),
                  subtitle: Text(
                    "Address :${orderHistory[index].address}",
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              );
            },
            separatorBuilder: (context, index) {
              return Divider();
            },
            itemCount: orderHistory.length));
  }

  handleHistoryDetails(BuildContext parentContext, int index) {
    return showDialog(
        context: parentContext,
        builder: (context) {
          return SimpleDialog(
            children: <Widget>[
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      child: Image(
                          image: CachedNetworkImageProvider(
                              orderHistory[index].mediaUrl)),
                      radius: 50.0,
                    ),
                    SizedBox(
                      height: 8.0,
                    ),
                    Text(
                      "Name :${orderHistory[index].productName}",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 8.0,
                    ),
                    Text(
                      "Price :${orderHistory[index].amount}",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 8.0,
                    ),
                    Text(
                      "address :${orderHistory[index].address}",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 8.0,
                    ),
                    Text(
                      "Time :${orderHistory[index].timestamp.toString()}",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          );
        });
  }
}
