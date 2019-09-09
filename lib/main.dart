import 'package:flutter/material.dart';
import 'package:xiaour_app/ChatListState.dart';


void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '妙传',
      theme: new ThemeData(
        primaryColor: Colors.white,
      ),
      home: new ChatList(),
    );
  }
}

class ChatList extends StatefulWidget {
  @override
  createState() => new ChatListState();
}

