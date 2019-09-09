import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';


class SettingPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SettingPageState();
}

class SettingPageState extends State<SettingPage> {

  final String WS_DOMAIN = "msg_ws_url_domain";
  final String WS_PORT = "msg_ws_url_port";

  TextEditingController domainController = TextEditingController();

  TextEditingController portController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    Future<String> domain = _getConnect(WS_DOMAIN);
    domain.then((String domain) {
      domainController.text = domain;
    });

    Future<String> port = _getConnect(WS_PORT);
    port.then((String port) {
      portController.text = port;
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('连接设置'),
      ),
      body: Column(
        children: <Widget>[
          TextField(
            controller: domainController,
            keyboardType: TextInputType.text,
            textInputAction:TextInputAction.next,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.all(10.0),
              icon: Icon(Icons.filter_drama),
              labelText: '服务器连接地址',
              helperText: '请输入域名或IP地址',

            ),
            autofocus: false,
          ),
          TextField(
              controller: portController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.all(10.0),
                icon: Icon(Icons.language),
                labelText: '服务器端口',
              )),
          RaisedButton(
            onPressed: _saveConnect,
            child: Text('保存连接'),
          ),
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
            title: Text('服务地址填写不正确！'),
          ));
    } else if (portController.text.length == 0) {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('服务端口填写不正确'),
          ));
    } else {
      this._saveWsConnect(domainController.text,portController.text);

      Fluttertoast.showToast(
          msg: "服务器地址连接保存成功！",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIos: 1,
      );
      portController.clear();
      domainController.clear();
      Navigator.pop(context,"EVENT_SUCCESS");
    }
  }

  //保存WebService连接串
  _saveWsConnect(String domain,String port) async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString(WS_DOMAIN, domain);
    sharedPreferences.setString(WS_PORT, port);
  }

}
