import 'package:flutter/material.dart';

class KannapyMessages extends StatefulWidget {
  @override
  _KannapyMessagesState createState() => _KannapyMessagesState();
}

class _KannapyMessagesState extends State<KannapyMessages> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Messages'),
      ),
      body: Text('My Messages'),
    );
  }
}
