import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xiaour_app/chat/ChatToUser.dart';
import 'package:xiaour_app/constants/System.dart';
import 'package:xiaour_app/main.dart';
import 'package:xiaour_app/model/MessageModel.dart';
import 'package:xiaour_app/model/UserModel.dart';
import 'package:xiaour_app/setting/SettingPage.dart';
import 'package:web_socket_channel/io.dart';
import 'package:badges/badges.dart';
import 'package:device_info/device_info.dart';
import 'dart:convert';
import 'constants/Tips.dart';
import 'event/ChatEvent.dart';


class ChatListState extends State<ChatList> {
  final _biggerFont = const TextStyle(fontSize: 18.0);
  final _saved = new Map<String, int>();

  bool connectionFlag = false;
  UserModel userModel;
  String device;

  @override
  void initState() {
    super.initState();
    _getDeviceInfo();
    _connectServerAndReceive();
  }

  @override
  Widget build(BuildContext context) {
    UserModel model = this.userModel;
    if (this.connectionFlag) {
      return new Scaffold(
        appBar: new AppBar(
          title: new Text(APP_NAME),
          actions: <Widget>[
            // 非隐藏的菜单
            new IconButton(
                icon: new Icon(Icons.settings),
                tooltip: '设置',
                onPressed: () {
                  Navigator.push(
                      context,
                      new MaterialPageRoute(
                          builder: (context) => new SettingPage(deviceName:this.device)));
                }),
          ],
        ),
        body: _buildSuggestions(model),
      );
    } else {
      return new Scaffold(
        appBar: new AppBar(
          title: new Text(APP_NAME),
          actions: <Widget>[
            // 非隐藏的菜单
            new IconButton(
                icon: new Icon(Icons.settings),
                tooltip: '设置',
                onPressed: () {
                  Navigator.push(
                      context,
                      new MaterialPageRoute(
                          builder: (context) => new SettingPage(deviceName:this.device)));
                }),
          ],
        ),
        body: _buildNotConnect(),
      );
    }
  }

  //获取设备信息
  void _getDeviceInfo() async {
    String tempDevice = "UNKONW";
    DeviceInfoPlugin deviceInfo = new DeviceInfoPlugin();
    if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      tempDevice = iosInfo.model + "_" + iosInfo.name;
    } else if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      tempDevice = androidInfo.brand + "_" + androidInfo.id;
    }
    setState(() {
      device = tempDevice;
    });
  }

  //连接或接收消息
  void _connectServerAndReceive() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.get(WS_DOMAIN) == null) {
      setState(() {
        connectionFlag = false;
      });
      return;
    }

    String wsUrl = sharedPreferences.get(WS_DOMAIN) + "/echo";

    Map<String, dynamic> myHeaders = {"device": device};

    final channel = new IOWebSocketChannel.connect(wsUrl, headers: myHeaders);
    channel.stream.listen((message) {
      print(message);
      _listen(channel);
      Map<String, dynamic> jsonMap = jsonDecode(message);
      //是否是登录的返回
      if (jsonMap.containsKey("userList")) {
        setState(() {
          connectionFlag = true;
          userModel = UserModel.fromJson(jsonMap);
        });
      } else {
        //如果是针对用户的消息
        MessageModel messageModel = MessageModel.fromJson(jsonMap);
        List<String> list =
            sharedPreferences.getStringList(WS_MSG + messageModel.fromUserName);
        if (list == null) {
          list = [];
        } else if (list.length >= 100) {
          list.removeAt(0);
        }
        list.add(messageModel.toJsonString());
        //修剪List长度存储到缓存
        int count = 1;
        if (_saved.containsKey(messageModel.fromUserName)) {
          count += _saved[messageModel.fromUserName];
        }
        Map<String, int> countMap = {messageModel.fromUserName: count};
        sharedPreferences.setStringList(
            WS_MSG + messageModel.fromUserName, list);

        List<MessageModel> msgList = new List();
        if (list == null) {
          print("没有消息！");
          return;
        }
        print(messageModel.toJsonString());
        list.forEach((f) {
          Map<String, dynamic> jsonMap = jsonDecode(f);
          msgList.add(MessageModel.fromJson(jsonMap));
        });

        setState(() {
          _saved.addAll(countMap);
          //发送事件到子页面
          eventBus.fire(new ChatListEvent(msgList));
        });
      }
    });

    Fluttertoast.showToast(
      msg: DEVICE_REFRESH,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIos: 1,
    );
  }

  //监听事件
  void _listen(IOWebSocketChannel socketChannel) {
    eventBus.on<SendChatEvent>().listen((event) {
      print(event.messageModel.toJsonString());
      socketChannel.sink.add(event.messageModel.toJsonString());
    });
  }

  Future<Null> _refresh() async {
    _connectServerAndReceive();
    return;
  }

  Widget _buildNotConnect() {
    return new MaterialApp(
      title: APP_NAME,
      debugShowCheckedModeBanner: false,
      home: new RefreshIndicator(
        onRefresh: _refresh,
        child: Container(
          child: new Column(children: <Widget>[
            new Text(WS_SERVER_NOT_CONNECT,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.orangeAccent, fontSize: 18.0)),
            new IconButton(
                icon: Icon(Icons.refresh),
                onPressed: () {
                  this._connectServerAndReceive();
                }),
          ]),
          alignment: Alignment.center,
          margin: EdgeInsets.only(top: 200.0),
        ),
      ),
    );
  }

  Widget _buildSuggestions(UserModel model) {
    if (model.count > 0) {
      return new RefreshIndicator(
          onRefresh: _refresh,
          //backgroundColor: Colors.blue,
          child: new ListView.separated(
            itemCount: model.userList.length,
            padding: const EdgeInsets.all(15.0),
            // 注意，在小屏幕上，分割线看起来可能比较吃力。
            itemBuilder: (context, i) {
              // 在每一列之前，添加一个1像素高的分隔线widget
              //if (i.isOdd) return new Divider();
              return _buildRow(model.userList[i]);
            },
            separatorBuilder: (BuildContext context, int index) =>
                new Divider(),
          ));
    } else {
      return new MaterialApp(
        title: APP_NAME,
        debugShowCheckedModeBanner: false,
        home: new Scaffold(
          body: Center(
            child: Container(
              child: new Column(children: <Widget>[
                new Text(DEVICE_NOT_FOUND,
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(color: Colors.orangeAccent, fontSize: 18.0)),
                new IconButton(
                    icon: Icon(Icons.refresh),
                    onPressed: () {
                      this._connectServerAndReceive();
                    }),
              ]),
              alignment: Alignment.center,
              margin: EdgeInsets.only(top: 200.0),
            ),
          ),
        ),
      );
    }
  }

  Widget _buildRow(String userName) {
    final alreadySaved = _saved.containsKey(userName);
    final count = alreadySaved == true ? _saved[userName] : 0;
    return new ListTile(
      leading: CircleAvatar(
        backgroundImage:
            NetworkImage("https://static.suiyueyule.com/user_icon.png"),
      ),
      title: new Text(
        userName,
        style: _biggerFont,
      ),
      trailing: new Badge(
        showBadge: alreadySaved,
        badgeContent: Text(count.toString(),
            style: new TextStyle(
              decorationColor: const Color(0xffffffff), //线的颜色
              decorationStyle: TextDecorationStyle
                  .solid, //文字装饰的风格  dashed,dotted虚线(简短间隔大小区分)  double三条线  solid两条线
              color: const Color(0xffffffff), //文字颜色
            )),
        animationType: BadgeAnimationType.scale,
      ),
      onTap: () {
        //点击事件
        setState(() {
          _saved.remove(userName);
        });

        Navigator.push(
            context,
            new MaterialPageRoute(
                builder: (context) => ChatToUser(
                    currentUser: userModel.currentUserName, toUser: userName)));
      },
    );
  }
}
