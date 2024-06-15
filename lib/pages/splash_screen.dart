// import 'dart:nativewrappers/_internal/vm/lib/async_patch.dart';

import 'dart:async';
import 'package:chattingapp/models/UserModel.dart';
import 'package:chattingapp/pages/Homepage.dart';
import 'package:chattingapp/pages/LoginPage.dart';
import 'package:chattingapp/pages/side_drawer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  final UserModel? userModel;
  final User? firebaseUser;
  const SplashScreen(
      {super.key, required this.userModel, required this.firebaseUser});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    wheretogo();
    // _startSplashScreenTimer();
  }

  void wheretogo() async {
    var sharedpref = await SharedPreferences.getInstance();
    bool? isloggedIn = sharedpref.getBool("login");

    if (isloggedIn == null) {
      print("isloggedIn is null");
    } else {
      print("isloggedIn is not null");
      if (isloggedIn) {
        print("isloggedIn is true");
      } else {
        print("isloggedIn is false");
      }
    }

    // checking user model or firebase user is null or not
    if (widget.userModel == null) {
      print("userModel is null");
    } else {
      print("userModel is not null");
    }

    if (widget.firebaseUser == null) {
      print("firebaseUser is null");
    } else {
      print("firebaseUser is not null");
    }

    var duration = Duration(seconds: 5);
    Timer(duration, () {
      if (isloggedIn != null) {
        print("isloggedIn: $isloggedIn");
        if (isloggedIn &&
            widget.firebaseUser != null &&
            widget.userModel != null) {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) {
            return SideDrawer(
                userModel: widget.userModel!,
                firebaseUser: widget.firebaseUser!);
          }));
        } else {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) {
            return LoginPage();
          }));
        }
      } else {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) {
          return LoginPage();
        }));
      }
    });
  }

  // void _startSplashScreenTimer() async {
  //   // Set the duration for the splash screen
  //   var duration = Duration(seconds: 3);

  //   // Start a timer
  //   Timer(duration, _navigateToHomePage);
  // }

  // void _navigateToHomePage() {
  //   Navigator.pushReplacement(
  //     context,
  //     MaterialPageRoute(builder: (context) => LoginPage()),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Center(
            child: Lottie.asset(
          "assets/mylottie.json",
        )),
      ),
    );
  }
}
