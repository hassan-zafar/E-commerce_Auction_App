import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kannapy/models/card.dart';
import 'file:///C:/kannapy/lib/adminScreens/orderDetails.dart';
import 'package:kannapy/tools/progress.dart';
import 'package:kannapy/tools/uiFunctions.dart';
import 'package:kannapy/userScreens/home.dart';

class AdminOrders extends StatefulWidget {
  @override
  _AdminOrdersState createState() => _AdminOrdersState();
}

class _AdminOrdersState extends State<AdminOrders> {
  List<CardDataNAdminOrderHistory> allOrders = [];
  List<CardDataNAdminOrderHistory> allCompletedOrders = [];
  List<CardDataNAdminOrderHistory> allPendingOrders = [];
  List<CardDataNAdminOrderHistory> allReceivedPay = [];
  List<CardDataNAdminOrderHistory> allPendingPay = [];
  List<CardDataNAdminOrderHistory> allCryptoOrders = [];
  List<CardDataNAdminOrderHistory> allCardOrders = [];
  List<CardDataNAdminOrderHistory> allDifferentItems = [];
  List<CardDataNAdminOrderHistory> allCryptoPay = [];
  List<CardDataNAdminOrderHistory> allCardPay = [];
  List<CardDataNAdminOrderHistory> allLastWeekOrders = [];
  List<CardDataNAdminOrderHistory> allLastMonthOrders = [];
  bool _isLoading = false;

  String status = "every";

  @override
  void initState() {
    getOrdersHistory();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double totalEarning = 0;
    double totalPendingPaymentAmount = 0;
    int totalQuantitySold = 0;
    int totalCryptoPayments = 0;
    int totalCardPayments = 0;
    int totalDifferentItems = 0;
    int totalPendingPayments = 0;
    int totalReceivedPayments = 0;

    allOrders.forEach((e) {
      e.paymentReceived
          ? totalEarning += e.amount
          : totalPendingPaymentAmount += e.amount;
      e.paymentType == "card"
          ? totalCardPayments += 1
          : totalCryptoPayments += 1;
      e.paymentReceived
          ? totalReceivedPayments += 1
          : totalPendingPayments += 1;
      totalQuantitySold += int.parse(e.quantity.toString());
    });
    return Scaffold(
      appBar: AppBar(
        title: Text('Orders'),
      ),
      body: ListView(
        physics: BouncingScrollPhysics(),
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: neumorphicTile(
              padding: 8,
              anyWidget: Column(
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        status = "every";
                      });
                    },
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: neumorphicTile(
                        padding: 2,
                        anyWidget: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              "${allOrders.length} ",
                              style: TextStyle(fontSize: 25.0),
                            ),
                            Icon(
                              Icons.local_shipping,
                              size: 25.0,
                            ),
                            SizedBox(
                              width: 8.0,
                            ),
                            Text(
                              "Total Order",
                              style: TextStyle(fontSize: 25.0),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            status = "completedOrders";
                          });
                        },
                        child: Padding(
                          padding: EdgeInsets.all(8),
                          child: neumorphicTile(
                              padding: 12,
                              anyWidget: Text(
                                  "Completed Orders ${allCompletedOrders.length}")),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(12),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              status = "pending";
                            });
                          },
                          child: neumorphicTile(
                              padding: 12,
                              anyWidget: Text(
                                  "Pending Orders ${allPendingOrders.length}")),
                        ),
                      )
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            status = "lastWeek";
                          });
                        },
                        child: Padding(
                          padding: EdgeInsets.all(8),
                          child: neumorphicTile(
                              padding: 12,
                              anyWidget: Row(
                                children: [
                                  Icon(Icons.calendar_today),
                                  Text("Last Week ${allLastWeekOrders.length}"),
                                ],
                              )),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(12),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              status = "lastMonth";
                            });
                          },
                          child: neumorphicTile(
                              padding: 12,
                              anyWidget: Row(
                                children: [
                                  Icon(Icons.date_range),
                                  Text(
                                      "Last Month ${allLastMonthOrders.length}"),
                                ],
                              )),
                        ),
                      )
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        status = "every";
                      });
                    },
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: neumorphicTile(
                        padding: 2,
                        anyWidget: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              totalEarning.toString().length > 6
                                  ? "${totalEarning.toString().substring(0, 6)} "
                                  : "$totalEarning",
                              style: TextStyle(fontSize: 25.0),
                            ),
                            Icon(
                              Icons.attach_money,
                              size: 25.0,
                            ),
                            SizedBox(
                              width: 8.0,
                            ),
                            Text(
                              "Total Earned",
                              style: TextStyle(fontSize: 25.0),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        status = "pendingPay";
                      });
                    },
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: neumorphicTile(
                        padding: 2,
                        anyWidget: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              totalPendingPaymentAmount.toString().length > 6
                                  ? "${totalPendingPaymentAmount.toString().substring(0, 6)} "
                                  : "$totalPendingPaymentAmount",
                              style: TextStyle(fontSize: 25.0),
                            ),
                            Icon(
                              Icons.attach_money,
                              size: 25.0,
                            ),
                            SizedBox(
                              width: 8.0,
                            ),
                            Text(
                              "Total Pending",
                              style: TextStyle(fontSize: 25.0),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              status = "pendingPay";
                            });
                          },
                          child: neumorphicTile(
                              padding: 12,
                              anyWidget: Text(
                                  "Pending Payments $totalPendingPayments")),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              status = "receivedPay";
                            });
                          },
                          child: neumorphicTile(
                              padding: 12,
                              anyWidget:
                                  Text("Received Pays $totalReceivedPayments")),
                        ),
                      )
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              status = "cryptoPay";
                            });
                          },
                          child: neumorphicTile(
                              padding: 12,
                              anyWidget: Row(
                                children: [
                                  Text("$totalCryptoPayments"),
                                  SizedBox(
                                    width: 4,
                                  ),
                                  FaIcon(FontAwesomeIcons.bitcoin),
                                  SizedBox(
                                    width: 4,
                                  ),
                                  Text("payments"),
                                ],
                              )),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              status = "cardPay";
                            });
                          },
                          child: neumorphicTile(
                              padding: 12,
                              anyWidget: Row(
                                children: [
                                  Text("$totalCardPayments"),
                                  SizedBox(
                                    width: 4,
                                  ),
                                  FaIcon(FontAwesomeIcons.creditCard),
                                  SizedBox(
                                    width: 4,
                                  ),
                                  Text("payments"),
                                ],
                              )),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          status == "every" ? buildAdminOrderItem(allOrders) : Container(),
          status == "pending"
              ? buildAdminOrderItem(allPendingOrders)
              : Container(),
          status == "completedOrders"
              ? buildAdminOrderItem(allCompletedOrders)
              : Container(),
          status == "receivedPay"
              ? buildAdminOrderItem(allReceivedPay)
              : Container(),
          status == "pendingPay"
              ? buildAdminOrderItem(allPendingPay)
              : Container(),
          status == "cryptoPay"
              ? buildAdminOrderItem(allCryptoPay)
              : Container(),
          status == "cardPay" ? buildAdminOrderItem(allCardPay) : Container(),
          status == "lastWeek"
              ? buildAdminOrderItem(allLastWeekOrders)
              : Container(),
          status == "lastMonth"
              ? buildAdminOrderItem(allLastMonthOrders)
              : Container(),
          status == "differentItem"
              ? buildAdminOrderItem(allDifferentItems)
              : Container(),
        ],
      ),
    );
  }

  getOrdersHistory() async {
    _isLoading = true;
    QuerySnapshot historySnapshot = await adminOrderHistoryRef.get();

    allOrders = historySnapshot.docs
        .map((e) => CardDataNAdminOrderHistory.fromDocument(e))
        .toList();
    // for (int i = 0; i < allOrders.length; i++) {
    //   if (allDifferentItems == null || allDifferentItems.isEmpty) {
    //     allDifferentItems.add(allOrders[i]);
    //   } else if (allDifferentItems[i].productId != allOrders[i].productId) {
    //     allDifferentItems.add(allOrders[i]);
    //   }
    // }

    historySnapshot.docs.forEach((e) {
      if (e.data()["status"] == "Delivered") {
        CardDataNAdminOrderHistory deliveredOrders =
            CardDataNAdminOrderHistory.fromDocument(e);
        allCompletedOrders.add(deliveredOrders);
      } else {
        CardDataNAdminOrderHistory pendingOrders =
            CardDataNAdminOrderHistory.fromDocument(e);
        allPendingOrders.add(pendingOrders);
      }
    });
    historySnapshot.docs.forEach((e) {
      if (e.data()["paymentReceived"] == true) {
        CardDataNAdminOrderHistory receivedPay =
            CardDataNAdminOrderHistory.fromDocument(e);
        allReceivedPay.add(receivedPay);
      } else {
        CardDataNAdminOrderHistory pendingPay =
            CardDataNAdminOrderHistory.fromDocument(e);
        allPendingPay.add(pendingPay);
      }
    });
    historySnapshot.docs.forEach((e) {
      if (e.data()["paymentType"] == 'crypto') {
        CardDataNAdminOrderHistory cryptoOrders =
            CardDataNAdminOrderHistory.fromDocument(e);
        allCryptoOrders.add(cryptoOrders);
      } else {
        CardDataNAdminOrderHistory cardOrders =
            CardDataNAdminOrderHistory.fromDocument(e);
        allCardOrders.add(cardOrders);
      }
    });
    historySnapshot.docs.forEach((e) {
      if (e.data()["paymentType"] == 'crypto') {
        CardDataNAdminOrderHistory cryptoPayments =
            CardDataNAdminOrderHistory.fromDocument(e);
        allCryptoPay.add(cryptoPayments);
      } else {
        CardDataNAdminOrderHistory cardPayments =
            CardDataNAdminOrderHistory.fromDocument(e);
        allCardPay.add(cardPayments);
      }
    });
    historySnapshot.docs.forEach((e) {
      DateTime orderTime = e.data()["timestamp"].toDate();
      int daysFromNow = DateTime.now().difference(orderTime).inDays;
      print(daysFromNow);
      if (daysFromNow < 7) {
        CardDataNAdminOrderHistory lastWeek =
            CardDataNAdminOrderHistory.fromDocument(e);
        allLastWeekOrders.add(lastWeek);
      } else {
        CardDataNAdminOrderHistory lastMonth =
            CardDataNAdminOrderHistory.fromDocument(e);
        allLastMonthOrders.add(lastMonth);
      }
    });
    setState(() {
      this.allOrders = allOrders;
      _isLoading = false;
    });
  }

  buildCompletedOrders() {
    if (_isLoading) {
      return bouncingGridProgress();
    }
    if (allCompletedOrders.isEmpty && !_isLoading) {
      return Center(
        child: Text(
          "Currently no order has Delivered",
          style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
        ),
      );
    }
    return ListView.separated(
        shrinkWrap: true,
        physics: BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => OrderDetails(allCompletedOrders[index]))),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 4.0, left: 8, right: 8),
              child: neumorphicTile(
                padding: 1,
                anyWidget: ListTile(
                  leading: Image(
                    image: CachedNetworkImageProvider(
                      allCompletedOrders[index].mediaUrl,
                    ),
                    fit: BoxFit.fitHeight,
                  ),
                  title: Text(allCompletedOrders[index].productName),
                  trailing: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                          "Price: \$${allCompletedOrders[index].amount.toString()}"),
                      Text(
                          "Quantity: x${allCompletedOrders[index].quantity.toString()}"),
                    ],
                  ),
                  subtitle: Text(
                    "Address :${allCompletedOrders[index].address}",
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
        itemCount: allCompletedOrders.length);
  }

  buildAdminOrderItem(List<CardDataNAdminOrderHistory> orderItem) {
    if (_isLoading) {
      return bouncingGridProgress();
    }
    if (orderItem.isEmpty && !_isLoading) {
      return Center(
        child: Text(
          "Currently no order is Pending",
          style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
        ),
      );
    }
    return ListView.separated(
        shrinkWrap: true,
        physics: BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => OrderDetails(orderItem[index]))),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 4.0, left: 8, right: 8),
              child: neumorphicTile(
                padding: 1,
                anyWidget: ListTile(
                  leading: Image(
                    image: CachedNetworkImageProvider(
                      orderItem[index].mediaUrl,
                    ),
                    fit: BoxFit.fitHeight,
                  ),
                  title: Text(orderItem[index].productName),
                  trailing: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text("Price: \$${orderItem[index].amount.toString()}"),
                      Text(
                          "Quantity: x${orderItem[index].quantity.toString()}"),
                    ],
                  ),
                  subtitle: Text(
                    "Address :${orderItem[index].address}",
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
        itemCount: orderItem.length);
  }

  buildPendingOrders() {
    if (_isLoading) {
      return bouncingGridProgress();
    }
    if (allPendingOrders.isEmpty && !_isLoading) {
      return Center(
        child: Text(
          "Currently no order is Pending",
          style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
        ),
      );
    }
    return ListView.separated(
        shrinkWrap: true,
        physics: BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => OrderDetails(allPendingOrders[index]))),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 4.0, left: 8, right: 8),
              child: neumorphicTile(
                padding: 1,
                anyWidget: ListTile(
                  leading: Image(
                    image: CachedNetworkImageProvider(
                      allPendingOrders[index].mediaUrl,
                    ),
                    fit: BoxFit.fitHeight,
                  ),
                  title: Text(allPendingOrders[index].productName),
                  trailing: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                          "Price: \$${allPendingOrders[index].amount.toString()}"),
                      Text(
                          "Quantity: x${allPendingOrders[index].quantity.toString()}"),
                    ],
                  ),
                  subtitle: Text(
                    "Address :${allPendingOrders[index].address}",
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
        itemCount: allPendingOrders.length);
  }

  buildAllOrders() {
    if (_isLoading) {
      return bouncingGridProgress();
    }
    if (allOrders.isEmpty && !_isLoading) {
      return Center(
        child: Text(
          "Currently no order has been placed",
          style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
        ),
      );
    }
    return ListView.separated(
        shrinkWrap: true,
        physics: BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => OrderDetails(allOrders[index]))),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 4.0, left: 8, right: 8),
              child: neumorphicTile(
                padding: 1,
                anyWidget: ListTile(
                  leading: Image(
                    image: CachedNetworkImageProvider(
                      allOrders[index].mediaUrl,
                    ),
                    fit: BoxFit.fitHeight,
                  ),
                  title: Text(allOrders[index].productName),
                  trailing: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Price: \$${allOrders[index].amount.toString()}"),
                      Text(
                          "Quantity: x${allOrders[index].quantity.toString()}"),
                    ],
                  ),
                  subtitle: Text(
                    "Address :${allOrders[index].address}",
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          );
        },
        separatorBuilder: (context, index) {
          return SizedBox(
            height: 5,
          );
        },
        itemCount: allOrders.length);
  }
}
