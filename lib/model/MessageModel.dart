import 'package:json_annotation/json_annotation.dart';

@JsonSerializable(nullable: false)
class MessageModel {
  final String msg;
  final String fromUserName;
  final String fromSessionId;
  final String to;
  final int type;

  MessageModel({this.msg, this.fromUserName, this.fromSessionId,this.to,this.type});
  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return new MessageModel(
        msg: json['msg'],
        fromUserName: json['fromUserName'],
        fromSessionId: json['fromSessionId'],
        to: json['to'],
        type:json['type'],
    );
  }

  String toJsonString(){
    return "{\"msg\":\""+msg+"\",\"fromUserName\":\""+fromUserName+"\""
        ",\"fromSessionId\":\""+fromSessionId+"\",\"to\":\""+to+"\",\"type\":"+type.toString()+"}";
  }

}