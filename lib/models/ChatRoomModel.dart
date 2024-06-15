import 'package:cloud_firestore/cloud_firestore.dart';

class ChatroomModel {
  String? chatroomId;
  Map<String, dynamic>? participants;
  String? lastMessage;
  DateTime? lastMessageTime;

  ChatroomModel({
    this.chatroomId,
    this.participants,
    this.lastMessage,
    this.lastMessageTime,
  });
  ChatroomModel.fromMap(Map<String, dynamic> map) {
    chatroomId = map["chatroomId"];
    participants = map["participants"];
    lastMessage = map["lastMessage"];
    lastMessageTime = (map["lastMessageTime"] as Timestamp).toDate();
  }

  Map<String, dynamic> toMap() {
    return {
      "chatroomId": chatroomId,
      "participants": participants,
      "lastMessage": lastMessage,
      "lastMessageTime": lastMessageTime,
    };
  }
}
