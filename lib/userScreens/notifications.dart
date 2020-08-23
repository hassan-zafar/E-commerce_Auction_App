import 'package:flutter/material.dart';

class KannapyNotifications extends StatefulWidget {
  @override
  _KannapyNotificationsState createState() => _KannapyNotificationsState();
}

class _KannapyNotificationsState extends State<KannapyNotifications> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Notifications'),
      ),
      body: Text('Order Notifications'),
    );
  }
}
