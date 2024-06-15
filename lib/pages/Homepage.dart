import 'package:chattingapp/apis/apis.dart';
import 'package:chattingapp/models/ChatRoomModel.dart';
import 'package:chattingapp/models/UserModel.dart';
import 'package:chattingapp/models/firebasehelper.dart';
import 'package:chattingapp/pages/chat_roompage.dart';
import 'package:chattingapp/pages/search_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';

class Homepage extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;
  const Homepage(
      {super.key, required this.userModel, required this.firebaseUser});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  @override
  void initState() {
    super.initState();
    //for updating user active status according to lifecycle events
    //resume -- active or online
    //pause  -- inactive or offline
    //inactive -- offline
    //detached -- offline
    SystemChannels.lifecycle.setMessageHandler((message) {
      print('Message: $message');

      if (FirebaseAuth.instance.currentUser != null) {
        if (message.toString().contains('resume')) {
          APIs.updateActiveStatus(true);
        }
        if (message.toString().contains('pause')) {
          APIs.updateActiveStatus(false);
        }
      }

      return Future.value(message);
    });
  }

  Future<void> getSelfInfo() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userModel.uid)
        .get()
        .then((user) async {
      if (user.exists) {
        APIs.updateActiveStatus(true);
        print('My Data: ${user.data()}');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 224, 162, 230),
          // removig the back button
          automaticallyImplyLeading: false,
          title: Center(child: const Text('Homepage')),
          leading: IconButton(
            onPressed: () {
              ZoomDrawer.of(context)!.toggle();
            },
            icon: Icon(Icons.menu),
          ),
          actions: [
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.refresh),
            ),
          ],
        ),
        body: SafeArea(
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                opacity: 1,
                image: AssetImage("assets/chattingbackground.jpg"),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Color.fromARGB(255, 179, 193, 173).withOpacity(0.5),
                  BlendMode.lighten,
                ),
              ),
            ),
            // color: Colors.white,
            child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("chatroom")
                    .where("participants.${widget.userModel.uid}",
                        isEqualTo: true)
                    .orderBy("lastMessageTime", descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.active) {
                    if (snapshot.hasData) {
                      QuerySnapshot chatroomsnapshot =
                          snapshot.data as QuerySnapshot;

                      return ListView.builder(
                          physics: BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 2, vertical: 7),
                          itemCount: chatroomsnapshot.docs.length,
                          itemBuilder: (context, index) {
                            ChatroomModel chatroommodel = ChatroomModel.fromMap(
                                chatroomsnapshot.docs[index].data()
                                    as Map<String, dynamic>);

                            Map<String, dynamic> participants =
                                chatroommodel.participants!;
                            List<String> participantskeys =
                                participants.keys.toList();
                            participantskeys.remove(widget.userModel.uid);

                            return FutureBuilder(
                                future: Firebasehelper.getUserModelById(
                                    participantskeys[0]),
                                builder: (context, userData) {
                                  if (userData.connectionState ==
                                      ConnectionState.done) {
                                    UserModel? targetUser =
                                        userData.data as UserModel;
                                    return InkWell(
                                      // focusColor: Colors.blue,
                                      radius: 80,
                                      onLongPress: () {
                                        // also changes the color of listtile
                                        showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                title: Text("Delete Chatroom"),
                                                content: Text(
                                                    "Are you sure you want to delete this chatroom?"),
                                                actions: [
                                                  TextButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                      child: Text("No")),
                                                  TextButton(
                                                      onPressed: () {
                                                        FirebaseFirestore
                                                            .instance
                                                            .collection(
                                                                "chatroom")
                                                            .doc(chatroommodel
                                                                .chatroomId)
                                                            .delete();
                                                        Navigator.pop(context);
                                                      },
                                                      child: Text("Yes"))
                                                ],
                                              );
                                            });
                                      },
                                      child: ListTile(
                                        shape: CircleBorder(
                                            side: BorderSide(
                                                color: Colors.black, width: 1)),
                                        style: ListTileStyle.drawer,
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              PageTransition(
                                                child: ChatRoompage(
                                                  chatroom: chatroommodel,
                                                  targetUser: targetUser,
                                                  userModel: widget.userModel,
                                                  firebaseUser:
                                                      widget.firebaseUser,
                                                ),
                                                type: PageTransitionType.fade,
                                                duration: const Duration(
                                                    milliseconds: 300),
                                              ));
                                        },
                                        leading: CircleAvatar(
                                          radius: 30,
                                          backgroundImage: NetworkImage(
                                              targetUser.profilepic.toString()),
                                        ),
                                        title: Text(
                                          targetUser.fullName.toString(),
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            fontStyle:
                                                GoogleFonts.poppins().fontStyle,
                                          ),
                                        ),
                                        subtitle: Container(
                                          height: 25,
                                          child: Text(chatroommodel.lastMessage
                                              .toString()),
                                        ),
                                      ),
                                    );
                                  } else {
                                    return Container();
                                  }
                                });
                          });
                    } else if (snapshot.hasError) {
                      return Center(child: Text("Error: ${snapshot.error}"));
                    } else {
                      return Center(child: Text("No chatrooms found"));
                    }
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                }),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
                context,
                PageTransition(
                  child: SearchPage(
                    usermodel: widget.userModel,
                    firebaseUser: widget.firebaseUser,
                  ),
                  type: PageTransitionType.fade,
                  duration: const Duration(milliseconds: 300),
                ));
          },
          child: const Icon(Icons.search),
        )
        // floatingActionButton: ,
        );
  }
}
