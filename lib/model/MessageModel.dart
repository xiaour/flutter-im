import 'package:json_annotation/json_annotation.dart';

@JsonSerializable(nullable: false)
class MessageModel {
  final String msg;//消息内容(如果内容是图片，这里就是URL)
  final String fromUserName;//发消息者
  final String fromSessionId;//发消息者sessionId
  final String to;//接收者
  final String msgId;//消息唯一ID
  final int    msgType;//消息类型（1：文本内容，2：图片）
  final int    type;//消息类型（1：群组，2：1对1）


  MessageModel(
      {this.msg,
      this.fromUserName,
      this.fromSessionId,
      this.to,
      this.type,
      this.msgType,
      this.msgId});
  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return new MessageModel(
      msg: json['msg'],
      msgId: json["msgId"],
      msgType: json["msgType"],
      fromUserName: json['fromUserName'],
      fromSessionId: json['fromSessionId'],
      to: json['to'],
      type: json['type'],
    );
  }

  String toJsonString() {
    return "{\"msg\":\"" +
        msg +
        "\",\"fromUserName\":\"" +
        fromUserName +
        "\",\"msgId\":\"" +
        msgId +
        "\""
            ",\"fromSessionId\":\"" +
        fromSessionId +
        "\",\"to\":\"" +
        to +
        "\",\"type\":" +
        type.toString() +
        "}";
  }
}
