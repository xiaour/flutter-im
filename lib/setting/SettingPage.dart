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
  var size = FontWeight.w500; // 定义一个字体类型
  var _isExpanded = false;

  TextEditingController domainController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    Future<String> domain = _getConnect(WS_DOMAIN);
    domain.then((String domain) {
      domainController.text = domain;
    });

    return Scaffold(

      appBar: AppBar(
        title: Text('设置'),
      ),
      body: Container(
          decoration: BoxDecoration(color: Colors.white),
          child:Column(
          children: <Widget>[
            new Text(""),
            ListTile(
              title: Text('设备名称：iPhone',style: TextStyle(fontWeight: size),),
              leading: Icon(Icons.account_circle,color: Colors.deepOrange),
            ),
            // 分割线
            new Divider(),
            ListTile(
              title: Text('在线帮助文档',style: TextStyle(fontWeight: size),),
              subtitle: Text("不清楚如何配置？点我试试！"),
              leading: Icon(Icons.assignment,color: Colors.teal),
              onTap: this.openHelp,
            ),
            new Divider(),
            SingleChildScrollView(

                child:ExpansionPanelList(

                  children : <ExpansionPanel>[

                    ExpansionPanel(

                      headerBuilder:(context, isExpanded){

                        return ListTile(
                          title: Text('服务器设置', style: TextStyle(fontWeight: size),),
                          leading: Icon(Icons.language,color: Colors.lightBlue),
                        );
                      },
                      body: Padding(
                        padding: EdgeInsets.fromLTRB(15, 0, 15, 15),
                        child: ListBody(
                          children: <Widget>[
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
                                //fillColor: Colors.lightBlue, filled: true,
                              ),

                            )
                            ,Text("")
                            ,RaisedButton(
                              splashColor:Colors.green,
                              onPressed: _saveConnect,
                              child: Text('保存连接'),
                            ),
                          ],
                        ),
                      ),
                      isExpanded: _isExpanded,
                      canTapOnHeader: true,
                    ),

                  ],
                  expansionCallback:(panelIndex, isExpanded){
                    setState(() {
                      _isExpanded = !isExpanded;
                    });
                  },
                  animationDuration : kThemeAnimationDuration,
                ),
            )
          ],
      ),
      )
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
