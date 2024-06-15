import 'package:cloud_firestore/cloud_firestore.dart';

enum Type { text, image, video, audio }

class MessageModel {
  String? messageId;
  String? sender;
  String? text;
  bool? seen;
  DateTime? createdon;
  late Type type;

  MessageModel(
      {this.messageId,
      this.sender,
      this.text,
      this.seen,
      this.createdon,
      required this.type});

  MessageModel.fromMap(Map<String, dynamic> map) {
    messageId = map["messageId"];
    sender = map["sender"];
    text = map["text"];
    seen = map["seen"];
    createdon = (map["createdon"] as Timestamp).toDate();
    // type = Type.values[map["type"]];
    type = map["type"] == 0
        ? Type.text
        : map["type"] == 1
            ? Type.image
            : map["type"] == 2
                ? Type.video
                : Type.audio;
  }

  Map<String, dynamic> toMap() {
    return {
      "messageId": messageId,
      "sender": sender,
      "text": text,
      "seen": seen,
      "createdon": createdon,
      "type": type.index,
    };
  }
}
