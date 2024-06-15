import 'dart:developer';

import 'package:chattingapp/models/ChatRoomModel.dart';
import 'package:chattingapp/models/UserModel.dart';
import 'package:chattingapp/pages/chat_roompage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

var uuid = Uuid();

class SearchPage extends StatefulWidget {
  final UserModel usermodel;
  final User firebaseUser;
  const SearchPage(
      {super.key, required this.usermodel, required this.firebaseUser});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController searchController = TextEditingController();

  Future<ChatroomModel?> getChatRoomModel(UserModel targetuser) async {
    ChatroomModel? chatroom;
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("chatroom")
        .where("participants.${widget.usermodel.uid}", isEqualTo: true)
        .where("participants.${targetuser.uid}", isEqualTo: true)
        .get();

    if (snapshot.docs.length > 0) {
      var docdata = snapshot.docs[0].data();
      ChatroomModel existingChatroom =
          ChatroomModel.fromMap(docdata as Map<String, dynamic>);
      chatroom = existingChatroom;
      print("Chatroom found already");
    } else {
      //create chatroom
      ChatroomModel newChatroom = ChatroomModel(
        chatroomId: uuid.v1(),
        lastMessage: "",
        participants: {
          widget.usermodel.uid.toString(): true,
          targetuser.uid.toString(): true,
        },
        lastMessageTime: DateTime.now(),
      );

      await FirebaseFirestore.instance
          .collection("chatroom")
          .doc(newChatroom.chatroomId)
          .set(newChatroom.toMap());
      print("Chatroom not found");
      print("Chatroom created");
      chatroom = newChatroom;
    }
    return chatroom;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 82, 26, 102),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Color.fromARGB(255, 104, 45, 138),
        title: Center(
            child: const Text(
          'Search Page',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        )),
      ),
      body: Expanded(
        child: Container(
          decoration: BoxDecoration(
              image: DecorationImage(
            image: AssetImage("assets/background.jpg"),
            fit: BoxFit.cover,
          )),
          child: Column(
            children: [
              SizedBox(
                height: 20,
              ),
              TextField(
                controller: searchController,
                autofocus: true,
                style: TextStyle(
                    color: Colors.white,
                    fontFamily: GoogleFonts.lato().fontFamily),
                decoration: InputDecoration(
                  hintText: 'Search for a user',
                  hintStyle: TextStyle(
                      color: Colors.white,
                      fontFamily: GoogleFonts.lato().fontFamily),
                  prefixIcon: Icon(Icons.search),
                ),
              ),
              SizedBox(height: 25),
              CupertinoButton(
                onPressed: () {
                  setState(() {});
                },
                child: Text('Search'),
                color: Theme.of(context).colorScheme.primary,
              ),
              SizedBox(
                height: 20,
              ),
              StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection("users")
                      .where("email", isEqualTo: searchController.text)
                      .where("email", isNotEqualTo: widget.usermodel.email)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.active) {
                      if (snapshot.hasData) {
                        QuerySnapshot datasnapshot =
                            snapshot.data as QuerySnapshot;

                        if (datasnapshot.docs.length > 0) {
                          print("user found");
                          Map<String, dynamic> userMap = datasnapshot.docs[0]
                              .data() as Map<String, dynamic>;
                          UserModel searcheduser = UserModel.fromMap(userMap);
                          return ListTile(
                              onTap: () async {
                                ChatroomModel? chatroommodel =
                                    await getChatRoomModel(searcheduser);
                                if (chatroommodel != null) {
                                  Navigator.pop(context);
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (context) {
                                    return ChatRoompage(
                                      chatroom: chatroommodel,
                                      targetUser: searcheduser,
                                      userModel: widget.usermodel,
                                      firebaseUser: widget.firebaseUser,
                                    );
                                  }));
                                }
                                // Navigator.pop(context);
                                // Navigator.push(context,
                                //     MaterialPageRoute(builder: (context) {
                                //   return ChatRoompage(
                                //     targetUser: searcheduser,

                                //     userModel: widget.usermodel,
                                //     firebaseUser: widget.firebaseUser,
                                //   );
                                // }
                                // )
                                // );
                                // print("User tapped");
                              },
                              leading: CircleAvatar(
                                backgroundImage:
                                    NetworkImage(searcheduser.profilepic!),
                              ),
                              title: Text(searcheduser.fullName!),
                              subtitle: Text(searcheduser.email!),
                              trailing: CupertinoButton(
                                onPressed: () {
                                  print("User added");
                                },
                                child: Text(
                                  'Add',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 12.2),
                                ),
                                color: Theme.of(context).colorScheme.primary,
                              ));
                        } else {
                          return Text("No user found");
                        }
                      } else if (snapshot.hasError) {
                        return Text("error occured");
                      } else {
                        return Text("No user found");
                      }
                    } else {
                      return CircularProgressIndicator();
                    }
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
