import 'dart:developer' as developer;
import 'dart:io';
import 'dart:convert';
import 'package:chattingapp/models/MessageModel.dart';
import 'package:chattingapp/models/UserModel.dart';
import 'package:chattingapp/models/firebasehelper.dart';
import 'package:chattingapp/pages/CompleteProfile.dart';
import 'package:chattingapp/pages/Homepage.dart';
import 'package:chattingapp/pages/LoginPage.dart';
import 'package:chattingapp/pages/SignUpPage.dart';
import 'package:chattingapp/pages/splash_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class APIs {
  static Future<UserModel?> getUserModelById(String uid) async {
    UserModel? userModel;

    DocumentSnapshot docsnap =
        await FirebaseFirestore.instance.collection("users").doc(uid).get();

    if (docsnap.data() != null) {
      userModel = UserModel.fromMap(docsnap.data() as Map<String, dynamic>);
    }

    return userModel;
  }

  static Future<void> sendMessage(MessageModel message) async {
    await FirebaseFirestore.instance
        .collection("messages")
        .add(message.toMap());
  }

  static Future<List<MessageModel>> getMessages(String chatroomId) async {
    List<MessageModel> messages = [];
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("messages")
        .where("chatroomId", isEqualTo: chatroomId)
        .orderBy("createdon", descending: true)
        .get();

    for (QueryDocumentSnapshot doc in querySnapshot.docs) {
      messages.add(MessageModel.fromMap(doc.data() as Map<String, dynamic>));
    }

    return messages;
  }

  static Future<void> createChatroom(
      String chatroomId, Map<String, dynamic> participants) async {
    await FirebaseFirestore.instance
        .collection("chatrooms")
        .doc(chatroomId)
        .set({
      "chatroomId": chatroomId,
      "participants": participants,
      "lastMessage": "",
      "lastMessageTime": DateTime.now(),
    });
  }

  static Future<List<String>> getChatrooms(String uid) async {
    List<String> chatrooms = [];
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("chatrooms")
        .where("participants", arrayContains: uid)
        .get();

    for (QueryDocumentSnapshot doc in querySnapshot.docs) {
      chatrooms.add(doc["chatroomId"]);
    }

    return chatrooms;
  }

  static Future<void> updateLastMessage(
      String chatroomId, String lastMessage) async {
    await FirebaseFirestore.instance
        .collection("chatrooms")
        .doc(chatroomId)
        .update({
      "lastMessage": lastMessage,
      "lastMessageTime": DateTime.now(),
    });
  }

  static Future<void> updateProfilePic(String url) async {
    User? user = FirebaseAuth.instance.currentUser;
    await FirebaseFirestore.instance.collection("users").doc(user!.uid).update({
      "profilepic": url,
    });
  }

  static Future<void> updateProfile(String fullName) async {
    User? user = FirebaseAuth.instance.currentUser;
    await FirebaseFirestore.instance.collection("users").doc(user!.uid).update({
      "fullName": fullName,
    });
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(
      UserModel user) {
    return FirebaseFirestore.instance
        .collection("users")
        .where("uid", isEqualTo: user.uid)
        .snapshots();
  }

  static Future<void> updateActiveStatus(bool is_online) async {
    FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({
      "is_online": is_online,
      "last_active": DateTime.now().microsecondsSinceEpoch.toString(),
    });
  }
}
