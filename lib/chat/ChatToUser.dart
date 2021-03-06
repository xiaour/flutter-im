import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bubble/bubble_widget.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
//import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xiaour_app/constants/System.dart';
import 'package:xiaour_app/constants/Tips.dart';
import 'package:xiaour_app/event/ChatEvent.dart';
import 'package:xiaour_app/model/MessageModel.dart';

class ChatToUser extends StatefulWidget {
  final String currentUser;
  final String toUser;
  ChatToUser({Key key, @required this.currentUser, @required this.toUser})
      : super(key: key);
  @override
  State<StatefulWidget> createState() => ChatToUserState();
}

class ChatToUserState extends State<ChatToUser> {
  //Tab页的控制器，可以用来定义Tab标签和内容页的坐标
  final TextEditingController _textController = new TextEditingController();
  //List<String> _messages = <String>[];
  List<MessageModel> _messageList = <MessageModel>[];
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    _loadMessage(widget.toUser);
    super.initState();
    _listen();
  }

  @override
  Widget build(BuildContext context) {
    //发送事件到子页面
    eventBus.fire(new JumpEvent(null, null));
    return new Scaffold(
      appBar: AppBar(
        title: Text(widget.toUser),
        actions: <Widget>[
          // 非隐藏的菜单
          new IconButton(
              icon: new Icon(Icons.info_outline),
              tooltip: '清理缓存',
              onPressed: () {
                clearMessageList();
              }),
        ],
      ),
      body: new Builder(builder: (BuildContext context) {
        return new Column(children: <Widget>[
          new Flexible(
            child: new ListView.builder(
              controller: _scrollController,
              physics: BouncingScrollPhysics(),
              itemCount: _messageList.length,
              itemBuilder: (context, i) {
                return _buildRow(_messageList[i]);
              },
            ),
          ),
          new Divider(height: 1.0),
          new Container(
            child: _buildComposer(),
            decoration:
                new BoxDecoration(color: Color.fromRGBO(241, 243, 244, 0.9)),
          ),
        ]);
      }),
      resizeToAvoidBottomPadding: true,
    );
  }

  Widget _buildComposer() {
    return new IconTheme(
      data: new IconThemeData(color: Color.fromRGBO(241, 243, 244, 0.9)),
      child: new Container(
        alignment: Alignment.center,
        height: 45.0,
        margin: const EdgeInsets.all(3.0),
        child: new Row(
          children: <Widget>[
            new Flexible(
              child: new TextField(
                textInputAction: TextInputAction.send,
                controller: _textController,
                onSubmitted: _submitMsg,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(10.0),
                  hintText: "想说点儿什么？",
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                  ),
                ),
              ),
            ),
            new IconButton(
              icon: new Icon(Icons.add_circle_outline),
              onPressed: openAction,
              color: Colors.black26,
            ),
          ],
        ),
      ),
    );
  }

  Future<Null> openAction() {
    return showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return new Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              new ListTile(
                leading: new Icon(Icons.photo_camera),
                title: new Text("相机拍摄"),
                onTap: () async {
                  var image = await ImagePicker.pickImage(source: ImageSource.camera);
                  Navigator.pop(context);
                },
              ),
              new ListTile(
                leading: new Icon(Icons.photo_library),
                title: new Text("照片库"),
                onTap: () async {
                  var image = await ImagePicker.pickImage(source: ImageSource.gallery);
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }

  Future<bool> clearMessageList() {
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(IS_CLEAR_CACHE),
              actions: <Widget>[
                FlatButton(
                  child: Text('暂不'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                FlatButton(
                  child: Text('立即清除'),
                  onPressed: () {
                    doClear();
                  },
                ),
              ],
            ));
  }

  /*图片控件*/
  Widget _imageView(imgPath) {
    if (imgPath == null) {
      return Center(
        child: Text("请选择图片或拍照"),
      );
    } else {
      return Image.file(
        imgPath,
      );
    }
  }

  void doClear() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.remove(WS_MSG + widget.toUser);
    Navigator.of(context).pop();
    setState(() {
      _messageList = new List();
    });
  }

  void _submitMsg(String text) async {
    if (text == null || text == "") {
      return;
    }
    _textController.clear();
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    Map<String, dynamic> map = {
      "fromUserName": widget.currentUser,
      "fromSessionId": "0",
      "msgId": new DateTime.now().millisecondsSinceEpoch.toString(),
      "msg": text,
      "to": widget.toUser,
      "type": 2
    };
    MessageModel messageModel = MessageModel.fromJson(map);
    List<String> list = sharedPreferences.getStringList(WS_MSG + widget.toUser);
    if (list == null) {
      list = [];
    } else if (list.length >= 100) {
      list.removeAt(0);
    }
    list.add(messageModel.toJsonString());
    sharedPreferences.setStringList(WS_MSG + widget.toUser, list);
    setState(() {
      _messageList.add(MessageModel.fromJson(map));
    });
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      curve: Curves.easeOut,
      duration: const Duration(milliseconds: 300),
    );
    //发送到服务器
    eventBus.fire(new SendChatEvent(messageModel));
  }

  //加载消息
  void _loadMessage(String currentUserName) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    List<String> list =
        sharedPreferences.getStringList(WS_MSG + currentUserName);

    List<MessageModel> modelList = new List();
    if (list == null) {
      print("没有消息！");
      return;
    }

    list.forEach((f) {
      Map<String, dynamic> jsonMap = jsonDecode(f);
      modelList.add(MessageModel.fromJson(jsonMap));
    });

    setState(() {
      _messageList = modelList;
    });
  }

  //监听主页事件
  void _listen() {
    eventBus.on<JumpEvent>().listen((event) {
      if (_scrollController.positions.isNotEmpty) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });

    eventBus.on<ChatListEvent>().listen((event) {
      setState(() {
        _messageList = event.msgList;
      });
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 100,
        curve: Curves.easeOut,
        duration: const Duration(milliseconds: 300),
      );
    });
  }

  Widget _buildRow(MessageModel messageModel) {
    //这个文本框长度并不能很好地自适应英文，还需要后期进行计算调整
    bool _isChoiceUser = widget.toUser != messageModel.fromUserName;
    //文本类型处理
    if(messageModel.msgType == null||messageModel.msgType ==1) {
      double bubbleWidth = messageModel.msg.length * 25.0 > 260.0
          ? 265
          : messageModel.msg.length * 30.0;
      double bubbleHeight = 50.0;
      if (messageModel.msg.length > 20 && messageModel.msg.length < 30) {
        bubbleHeight = 60.0 * 1.4;
      }
      if (messageModel.msg.length > 30 && messageModel.msg.length < 60) {
        bubbleHeight = messageModel.msg.length / 18 * 42.0;
      }
      if (messageModel.msg.length >= 60) {
        bubbleHeight = messageModel.msg.length / 18 * 33.0;
      }

      return new GestureDetector(
        child: Padding(
            padding: EdgeInsets.all(4.0),
            child: Container(
                alignment:
                    _isChoiceUser ? Alignment.centerRight : Alignment.centerLeft,
                child: BubbleWidget(
                    bubbleWidth,
                    bubbleHeight,
                    _isChoiceUser
                        ? Colors.green.withOpacity(0.7)
                        : Color.fromRGBO(71, 71, 71, 0.9),
                    _isChoiceUser
                        ? BubbleArrowDirection.right
                        : BubbleArrowDirection.left,
                    arrAngle: 65,
                    child: Text(messageModel.msg,
                        style: TextStyle(color: Colors.white, fontSize: 17.0))))),
        onLongPress: () {
          Clipboard.setData(ClipboardData(text: messageModel.msg));
          Fluttertoast.showToast(
            msg: CONTENT_COPY,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIos: 1,
          );
        },
      );
    }//文本类型处理

    /*if(messageModel.msgType == 2){
      new Column(
          children: <Widget>[
            new Image.file(messageModel.msg),
          ]
      );
    }*/

  }
}
