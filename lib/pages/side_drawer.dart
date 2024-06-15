import 'package:chattingapp/models/UserModel.dart';
import 'package:chattingapp/pages/Homepage.dart';
import 'package:chattingapp/pages/Menu_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:flutter/cupertino.dart';

class SideDrawer extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;
  const SideDrawer(
      {super.key, required this.userModel, required this.firebaseUser});

  @override
  State<SideDrawer> createState() => _SideDrawerState();
}

class _SideDrawerState extends State<SideDrawer> {
  @override
  Widget build(BuildContext context) {
    return ZoomDrawer(
      menuBackgroundColor: const Color.fromARGB(255, 70, 67, 70)!,
      borderRadius: 24.0,
      menuScreen: MenuPage(
        userModel: widget.userModel,
        firebaseUser: widget.firebaseUser,
      ),
      mainScreen: Homepage(
          userModel: widget.userModel, firebaseUser: widget.firebaseUser),
      angle: 0.0,
      slideWidth: MediaQuery.of(context).size.width * 0.8,
    );
  }
}
