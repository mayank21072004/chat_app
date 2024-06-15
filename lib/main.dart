import 'package:chattingapp/models/UserModel.dart';
import 'package:chattingapp/models/firebasehelper.dart';
import 'package:chattingapp/pages/CompleteProfile.dart';
import 'package:chattingapp/pages/Homepage.dart';
import 'package:chattingapp/pages/LoginPage.dart';
import 'package:chattingapp/pages/SignUpPage.dart';
import 'package:chattingapp/pages/profile_page.dart';
import 'package:chattingapp/pages/splash_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as developer;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  User? curruser = FirebaseAuth.instance.currentUser;
  UserModel? usermodel;

  @override
  void initState() {
    super.initState();
    getmodel();
  }

  void getmodel() async {
    print("Getting user model");
    if (curruser != null) {
      print("User is not null");
      DocumentSnapshot docsnap = await FirebaseFirestore.instance
          .collection("users")
          .doc(curruser!.uid)
          .get();
      print("docsnap is getted");
      if (docsnap.data() != null) {
        setState(() {
          usermodel = UserModel.fromMap(docsnap.data() as Map<String, dynamic>);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(userModel: usermodel, firebaseUser: curruser),
      // home: LoginPage(),
      // home: ProfilePage(),
    );
  }
}
