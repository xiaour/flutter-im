import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:xiaour_app/constants/Tips.dart';

class SettingPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SettingPageState();
}

class SettingPageState extends State<SettingPage> {

  final String WS_DOMAIN = "msg_ws_url_domain";

  TextEditingController domainController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    Future<String> domain = _getConnect(WS_DOMAIN);
    domain.then((String domain) {
      domainController.text = domain;
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('连接设置'),
      ),
      body: Column(
        children: <Widget>[
          new Text(''),
          new TextField(
            textInputAction:TextInputAction.done,
            controller: domainController,
            decoration:InputDecoration(
              contentPadding: EdgeInsets.all(8.0),
              hintText: '请输入域名或IP地址',
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.transparent),
                borderRadius: BorderRadius.all(Radius.circular(6)),
              ),
              fillColor: Colors.black12, filled: true,

            ),

          )
          ,RaisedButton(
            splashColor:Colors.green,
            onPressed: _saveConnect,
            child: Text('保存连接'),
          )
          ,new Divider()
          ,new Text('提示：服务器连接地址需要配置正确的WebSocket链接URL，如果不清楚如何配置，请打开此地址！',
              textAlign:TextAlign.left,
              style: TextStyle(color: Colors.black26,fontSize: 14.0))
          ,new IconButton(
              icon: Icon(Icons.help_outline),
              onPressed: () {
                this.openHelp();
              }),
        ],
      ),
    );
  }

  Future<String> _getConnect(String key) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.get(key);
  }

  void _saveConnect() {

    if (domainController.text.length == 0) {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(WS_SERVER_IS_ERROR),
          ));
    }

      this._saveWsConnect(domainController.text);

      Fluttertoast.showToast(
          msg: SAVE_SERVER_SUCCESS,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIos: 1,
      );
      domainController.clear();
      Navigator.pop(context,"EVENT_SUCCESS");
  }

  //保存WebService连接串
  void _saveWsConnect(String domain) async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString(WS_DOMAIN, domain);
  }

  void openHelp() async{
    // url
    const url = "https://github.com/xiaour/flutter-im/blob/master/README.md";
    await launch(url);
  }

}
