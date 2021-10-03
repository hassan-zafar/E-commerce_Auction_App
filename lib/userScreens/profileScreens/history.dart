import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:kannapy/models/card.dart';
import 'file:///C:/kannapy/lib/adminScreens/orderDetails.dart';
import 'package:kannapy/tools/progress.dart';
import 'package:kannapy/tools/uiFunctions.dart';
import 'package:kannapy/userScreens/home.dart';

class OrderHistory extends StatefulWidget {
  @override
  _OrderHistoryState createState() => _OrderHistoryState();
}

class _OrderHistoryState extends State<OrderHistory> {
  List<CardDataNAdminOrderHistory> orderHistory = [];

  bool _isLoading = false;
  @override
  void initState() {
    getOrdersHistory();
    super.initState();
  }

  getOrdersHistory() async {
    _isLoading = true;
    QuerySnapshot historySnapshot =
        await cardRef.doc(currentUser.id).collection("payments").get();
    orderHistory = historySnapshot.docs
        .map((e) => CardDataNAdminOrderHistory.fromDocument(e))
        .toList();
    QuerySnapshot cryptoHistorySnapshot =
        await cardRef.doc(currentUser.id).collection("crypto").get();
    cryptoHistorySnapshot.docs.forEach((e) {
      CardDataNAdminOrderHistory cryptoOrderHistory =
          CardDataNAdminOrderHistory.fromDocument(e);
      orderHistory.add(cryptoOrderHistory);
    });
    setState(() {
      this.orderHistory = orderHistory;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Order History',
          style: TextStyle(
              color: Theme.of(context).appBarTheme.textTheme.headline1.color),
        ),
      ),
      body: buildOrderHistory(),
    );
  }

  buildOrderHistory() {
    if (_isLoading) {
      return bouncingGridProgress();
    }
    if (orderHistory.isEmpty && !_isLoading) {
      return Center(
        child: Text(
          "Currently no order has been placed",
          style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
        ),
      );
    }
    return ListView.separated(
        physics: BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => OrderDetails(orderHistory[index]))),
            child: Padding(
              padding:
                  const EdgeInsets.only(bottom: 4.0, left: 8, right: 8, top: 4),
              child: neumorphicTile(
                padding: 1,
                anyWidget: ListTile(
                  leading: Image(
                    image: CachedNetworkImageProvider(
                      orderHistory[index].mediaUrl,
                    ),
                    fit: BoxFit.fitHeight,
                  ),
                  title: Text(orderHistory[index].productName),
                  trailing:
                      Text("Price: \$${orderHistory[index].amount.toString()}"),
                  subtitle: Text(
                    "Address :${orderHistory[index].address}",
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          );
        },
        separatorBuilder: (context, index) {
          return SizedBox(
            height: 1,
          );
        },
        itemCount: orderHistory.length);
  }
}
