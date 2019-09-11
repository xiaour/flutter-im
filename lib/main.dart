import 'package:flutter/material.dart';
import 'package:xiaour_app/ChatListState.dart';
import 'package:xiaour_app/constants/System.dart';


void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      title: APP_NAME,
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

