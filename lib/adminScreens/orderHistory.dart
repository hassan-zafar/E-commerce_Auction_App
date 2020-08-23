import 'package:flutter/material.dart';

class AdminOrdersHistory extends StatefulWidget {
  @override
  _AdminOrdersHistoryState createState() => _AdminOrdersHistoryState();
}

class _AdminOrdersHistoryState extends State<AdminOrdersHistory> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Order History"),
      ),
    );
  }
}
