import 'package:cached_network_image/cached_network_image.dart';
import 'package:chattingapp/models/ChatRoomModel.dart';
import 'package:chattingapp/models/MessageModel.dart';
import 'package:chattingapp/models/UserModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MessageCard extends StatefulWidget {
  final MessageModel currmessage;
  final UserModel curruser;
  final ChatroomModel chatroom;
  const MessageCard(
      {super.key,
      required this.currmessage,
      required this.curruser,
      required this.chatroom});

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  void updateseen() async {
    // widget.currmessage.createdon = DateTime.now();
    FirebaseFirestore.instance
        .collection("chatroom")
        .doc(widget.chatroom.chatroomId)
        .collection("messages")
        .doc(widget.currmessage.messageId)
        .update({"seen": true});
  }

  @override
  Widget build(BuildContext context) {
    return (widget.currmessage.sender == widget.curruser.uid)
        ? _blueMessage(context, widget.currmessage, widget.curruser)
        : _greenMessage(context, widget.currmessage, widget.curruser);
  }

  Widget _blueMessage(
      BuildContext context, MessageModel currmessage, UserModel curruser) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // displaying the time of the message
        Container(
            margin: EdgeInsets.only(top: 10, left: 50),
            child: Text(
              currmessage.createdon!.hour.toString() +
                  ":" +
                  currmessage.createdon!.minute.toString(),
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            )
            // done displaying the time of the message
            // done icon for the message whether the user read it or not
            ),
        Container(
          margin: EdgeInsets.only(top: 10, right: 10),
          child: Icon(
            currmessage.seen! ? Icons.done_all_rounded : Icons.done_all_rounded,
            color: currmessage.seen! ? Colors.blue : Colors.grey,
            size: 15,
          ),
        ),
        Flexible(
          child: Container(
            padding: EdgeInsets.all(10),
            margin: EdgeInsets.only(right: 10, top: 10),
            decoration: BoxDecoration(
              color: Colors.blue[400],
              border: Border.all(color: Colors.blue[600]!),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(20),
              ),
            ),
            child: (currmessage.type == Type.text)
                ? Text(
                    currmessage.text.toString(),
                    style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
                  )
                : Container(
                    child: CachedNetworkImage(
                      imageUrl: currmessage.text.toString(),
                      placeholder: (context, url) =>
                          CircularProgressIndicator(),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _greenMessage(
      BuildContext context, MessageModel currmessage, UserModel curruser) {
    if (widget.currmessage.seen! == false) {
      updateseen();
    }
    return Row(
      children: [
        Flexible(
          child: Container(
            padding: EdgeInsets.all(10),
            margin: EdgeInsets.only(left: 10, right: 10, top: 10),
            decoration: BoxDecoration(
              color: Colors.green[400],
              border: Border.all(color: Colors.green[600]!),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: (currmessage.type == Type.text)
                ? Text(
                    currmessage.text.toString(),
                    style: TextStyle(color: Colors.white),
                  )
                : Container(
                    child: CachedNetworkImage(
                      imageUrl: currmessage.text.toString(),
                      placeholder: (context, url) =>
                          CircularProgressIndicator(),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
                  ),
          ),
        ),
        // displaying the time of the message
        Container(
          margin: EdgeInsets.only(top: 10, right: 50),
          child: Text(
            currmessage.createdon!.hour.toString() +
                ":" +
                currmessage.createdon!.minute.toString(),
            style: TextStyle(color: Colors.grey),
          ),
        ),
        // done displaying the time of the message
        // done icon for the message whether the user read it or not
        // Container(
        //   margin: EdgeInsets.only(top: 10, right: 45),
        //   child: Icon(
        //     currmessage.seen! ? Icons.done_all_rounded : Icons.done_all_rounded,
        //     color: currmessage.seen! ? Colors.green : Colors.grey,
        //     size: 15,
        //   ),
        // ),
      ],
    );
  }
}
