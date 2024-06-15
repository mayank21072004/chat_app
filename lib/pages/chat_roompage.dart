import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chattingapp/apis/apis.dart';
import 'package:chattingapp/helpers_app/my_data_util.dart';
import 'package:chattingapp/models/ChatRoomModel.dart';
import 'package:chattingapp/models/MessageModel.dart';
import 'package:chattingapp/models/UserModel.dart';
import 'package:chattingapp/pages/Message_card.dart';
import 'package:chattingapp/pages/search_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class ChatRoompage extends StatefulWidget {
  final UserModel targetUser;
  final ChatroomModel chatroom;
  final UserModel userModel;
  final User firebaseUser;
  const ChatRoompage(
      {super.key,
      required this.targetUser,
      required this.chatroom,
      required this.userModel,
      required this.firebaseUser});

  @override
  State<ChatRoompage> createState() => _ChatRoompageState();
}

class _ChatRoompageState extends State<ChatRoompage> {
  TextEditingController messageController = TextEditingController();
  bool _showemoji = false;
  bool _cameraloading = false;

  void sendMessage() async {
    String message = messageController.text.trim();
    messageController.clear();
    if (message.isNotEmpty) {
      // send message
      MessageModel newMessage = MessageModel(
        messageId: uuid.v1(),
        sender: widget.userModel.uid,
        createdon: DateTime.now(),
        text: message,
        seen: false,
        type: Type.text,
      );

      FirebaseFirestore.instance
          .collection("chatroom")
          .doc(widget.chatroom.chatroomId)
          .collection("messages")
          .doc(newMessage.messageId)
          .set(newMessage.toMap());

      widget.chatroom.lastMessage = message;
      widget.chatroom.lastMessageTime = DateTime.now();
      FirebaseFirestore.instance
          .collection("chatroom")
          .doc(widget.chatroom.chatroomId)
          .update(widget.chatroom.toMap());

      print("Message sent");
    }
  }

  void selectImage(ImageSource source) async {
    XFile? pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      print("Image selected");
      sendimage(pickedFile);
    }
  }

  void selectMultiimage(ImageSource source) async {
    List<XFile>? pickedFiles = await ImagePicker().pickMultiImage();
    if (pickedFiles != null) {
      print("Image selected");
      for (XFile file in pickedFiles) {
        sendimage(file);
      }
    }
  }

  void sendimage(XFile file) async {
    UploadTask task = FirebaseStorage.instance
        .ref("images")
        .child(widget.chatroom.chatroomId.toString())
        .child(uuid.v1())
        .putFile(File(file.path));

    setState(() {
      _cameraloading = true;
    });

    TaskSnapshot snapshot = await task;
    String imageUrl = await snapshot.ref.getDownloadURL();

    setState(() {
      _cameraloading = false;
    });

    MessageModel newMessages = MessageModel(
      messageId: uuid.v1(),
      sender: widget.userModel.uid,
      createdon: DateTime.now(),
      text: imageUrl,
      seen: false,
      type: Type.image,
    );

    FirebaseFirestore.instance
        .collection("chatroom")
        .doc(widget.chatroom.chatroomId)
        .collection("messages")
        .doc(newMessages.messageId)
        .set(newMessages.toMap());

    widget.chatroom.lastMessage = "Image";
    widget.chatroom.lastMessageTime = DateTime.now();

    FirebaseFirestore.instance
        .collection("chatroom")
        .doc(widget.chatroom.chatroomId)
        .update(widget.chatroom.toMap());
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: SafeArea(
        child: WillPopScope(
          onWillPop: () {
            if (_showemoji) {
              setState(() {
                _showemoji = false;
              });
            } else {
              Navigator.pop(context);
            }
            return Future.value(false);
          },
          child: Scaffold(
            appBar: AppBar(
              toolbarHeight: 60,
              automaticallyImplyLeading: false,
              flexibleSpace: _appbar(context, widget.targetUser),
            ),
            body: SafeArea(
              child: Container(
                decoration: BoxDecoration(
                    image: DecorationImage(
                  image: AssetImage("assets/backgroundui.jpg"),
                  fit: BoxFit.cover,
                )),
                child: Column(
                  children: [
                    Expanded(
                      child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: StreamBuilder(
                              stream: FirebaseFirestore.instance
                                  .collection("chatroom")
                                  .doc(widget.chatroom.chatroomId)
                                  .collection("messages")
                                  .orderBy("createdon", descending: true)
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.active) {
                                  if (snapshot.hasData) {
                                    QuerySnapshot datasnapshot =
                                        snapshot.data as QuerySnapshot;
                                    return ListView.builder(
                                      reverse: true,
                                      itemCount: datasnapshot.docs.length,
                                      itemBuilder: (context, index) {
                                        MessageModel currmessage =
                                            MessageModel.fromMap(
                                                datasnapshot.docs[index].data()
                                                    as Map<String, dynamic>);
                                        return MessageCard(
                                          currmessage: currmessage,
                                          curruser: widget.userModel,
                                          chatroom: widget.chatroom,
                                        );

                                        // Row(
                                        //   mainAxisAlignment: currmessage.sender ==
                                        //           widget.userModel.uid
                                        //       ? MainAxisAlignment.end
                                        //       : MainAxisAlignment.start,
                                        //   children: [
                                        //     Column(
                                        //       crossAxisAlignment:
                                        //           currmessage.sender ==
                                        //                   widget.userModel.uid
                                        //               ? CrossAxisAlignment.end
                                        //               : CrossAxisAlignment.start,
                                        //       children: [
                                        //         Container(
                                        //             margin: EdgeInsets.symmetric(
                                        //                 vertical: 2),
                                        //             padding: EdgeInsets.symmetric(
                                        //                 horizontal: 10,
                                        //                 vertical: 5),
                                        //             decoration: BoxDecoration(
                                        //               color: currmessage.sender ==
                                        //                       widget.userModel.uid
                                        //                   ? Colors.blue[100]
                                        //                   : Colors.grey[200],
                                        //               borderRadius:
                                        //                   BorderRadius.circular(20),
                                        //             ),
                                        //             child: Text(
                                        //                 style: TextStyle(
                                        //                   fontFamily:
                                        //                       GoogleFonts.roboto()
                                        //                           .fontFamily,
                                        //                   fontSize: 17,
                                        //                 ),
                                        //                 currmessage.text
                                        //                     .toString())),
                                        //         SizedBox(
                                        //           height: 2,
                                        //         ),
                                        //         // container for time of message
                                        //         Container(
                                        //           alignment: Alignment.bottomRight,
                                        //           child: Text(
                                        //             // displaying only time in 24 hour format
                                        //             currmessage.createdon!.hour
                                        //                     .toString() +
                                        //                 ":" +
                                        //                 currmessage
                                        //                     .createdon!.minute
                                        //                     .toString(),
                                        //             style: TextStyle(
                                        //               fontSize: 10,
                                        //               color: Colors.grey,
                                        //             ),
                                        //           ),
                                        //         ),
                                        //       ],
                                        //     ),
                                        //   ],
                                        // );
                                      },
                                    );
                                  } else if (snapshot.hasError) {
                                    return Center(
                                      child: Text("Error occured"),
                                    );
                                  } else {
                                    return Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  }
                                } else {
                                  return Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }
                              })),
                    ),
                    if (_cameraloading)
                      CircularProgressIndicator(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    Container(
                        // color: Colors.grey[200],
                        padding: EdgeInsets.only(top: 7, bottom: 1),
                        child: _chatinput(context, messageController)
                        // Row(
                        //   children: [
                        //     Flexible(
                        //       child: TextField(
                        //         controller: messageController,
                        //         maxLines: null,
                        //         decoration: InputDecoration(
                        //           hintText: 'Type a message',
                        //           // border: OutlineInputBorder(
                        //           //   borderRadius: BorderRadius.circular(20),
                        //           // ),
                        //         ),
                        //       ),
                        //     ),
                        //     IconButton(
                        //       onPressed: () {
                        //         sendMessage();
                        //       },
                        //       icon: Icon(
                        //         Icons.send,
                        //         color: Theme.of(context).colorScheme.primary,
                        //       ),
                        //     )
                        //   ],
                        // ),
                        ),
                    if (_showemoji)
                      SizedBox(
                        height: 300,
                        child: EmojiPicker(
                          textEditingController: messageController,
                          config: Config(
                              emojiViewConfig: EmojiViewConfig(
                            backgroundColor: Colors.grey[200]!,
                            columns: 7,
                            emojiSizeMax: 32,
                          )),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _chatinput(
      BuildContext context, TextEditingController messagecontroller) {
    return Row(
      children: [
        Expanded(
          child: Card(
            child: Row(
              children: [
                // emoji button
                IconButton(
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    setState(() {
                      _showemoji = !_showemoji;
                    });
                  },
                  icon: Icon(Icons.emoji_emotions, color: Colors.yellow[700]),
                ),
                // text input field
                Expanded(
                  child: TextField(
                    onTap: () {
                      if (_showemoji) {
                        setState(() {
                          _showemoji = false;
                        });
                      }
                    },
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    controller: messagecontroller,
                    decoration: InputDecoration(
                      hintText: "Type a message",
                      hintStyle: TextStyle(color: Colors.grey),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                // gallery button
                IconButton(
                  onPressed: () {
                    // open gallery
                    print("Gallery button pressed");
                    selectMultiimage(ImageSource.gallery);
                  },
                  icon: Icon(Icons.photo, color: Colors.purple[700]),
                ),
                // camera button
                IconButton(
                  onPressed: () {
                    // open camera
                    print("Camera button pressed");
                    selectImage(ImageSource.camera);
                  },
                  icon: Icon(Icons.camera_alt, color: Colors.blue[700]),
                ),
              ],
            ),
          ),
        ),
        // send button
        MaterialButton(
          minWidth: 1,
          onPressed: () {
            // send message
            sendMessage();
          },
          child: Icon(
            Icons.send,
            color: Colors.green[700],
          ),
        )
      ],
    );
  }

  Widget _appbar(BuildContext context, UserModel targetUser) {
    return Container(
      color: Color.fromARGB(255, 161, 160, 154),
      margin: EdgeInsets.symmetric(vertical: 5),
      child: InkWell(
        onTap: () {},
        child: StreamBuilder(
            stream: APIs.getUserInfo(widget.targetUser),
            builder: (context, snapshot) {
              final data = snapshot.data?.docs;
              final list = data?.map((doc) {
                    return UserModel.fromMap(doc.data());
                  }).toList() ??
                  [];
              print("I am printing the list of users");
              // print("is online: ${list[0].is_online}");
              // print("last active: ${list[0].last_active}");
              // printing the name
              // print("Name: ${list[0].fullName}");
              if (list == null) {
                return CircularProgressIndicator();
              }
              return Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.arrow_back),
                  ),
                  // SizedBox(
                  //   width: 10,
                  // ),
                  // Container(
                  //   child: CircleAvatar(
                  //     // minRadius: 20,
                  //     radius: 25,
                  //     backgroundImage: NetworkImage(
                  //         targetUser.profilepic.toString(),
                  //         scale: 0.9),
                  //   ),
                  // ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: CachedNetworkImage(
                      width: 50,
                      height: 50,
                      imageUrl: list.isNotEmpty
                          ? list[0].profilepic.toString()
                          : targetUser.profilepic.toString(),
                      errorWidget: (context, url, error) => const CircleAvatar(
                        // radius: 25,
                        child: Icon(Icons.person),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Column(
                    children: [
                      Text(
                        list.isNotEmpty
                            ? list[0].fullName.toString()
                            : targetUser.fullName.toString(),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          // fontStyle: GoogleFonts.oswald().fontStyle,
                          fontFamily: GoogleFonts.oswald().fontFamily,
                        ),
                      ),
                      Text(
                        list.isNotEmpty
                            ? (list[0].is_online)
                                ? 'online'
                                : MyDateUtil.getLastActiveTime(
                                    context: context,
                                    lastActive: list[0].last_active.toString())
                            : MyDateUtil.getLastActiveTime(
                                context: context,
                                lastActive: targetUser.last_active.toString()),
                        style: TextStyle(
                          fontSize: 12,
                        ),
                      ),
                    ],
                  )
                ],
              );
            }),
      ),
    );
  }
}
