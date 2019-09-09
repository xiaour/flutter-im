import 'package:event_bus/event_bus.dart';
import 'package:xiaour_app/model/MessageModel.dart';

//Bus初始化
EventBus eventBus = EventBus();

class ChatListEvent {
  List<MessageModel> msgList;
  ChatListEvent(List<MessageModel> msgList){
    this.msgList = msgList;
  }
}

//发送消息
class SendChatEvent {
  MessageModel messageModel;
  SendChatEvent(MessageModel model){
    this.messageModel = model;
  }
}


//跳转事件
class JumpEvent {
  String toUser ;
  String currentUser;

  JumpEvent( String currentUser,String toUser){
    this.toUser = toUser;
    this.currentUser = currentUser;
  }
}