import 'package:chattingapp/apis/apis.dart';
import 'package:chattingapp/models/UserModel.dart';
import 'package:chattingapp/pages/Homepage.dart';
import 'package:chattingapp/pages/LoginPage.dart';
import 'package:chattingapp/pages/profile_page.dart';
import 'package:chattingapp/pages/side_drawer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MenuPage extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;
  const MenuPage(
      {super.key, required this.userModel, required this.firebaseUser});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white.withOpacity(0.9),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 50),
        children: [
          SizedBox(
            height: 50,
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: CircleAvatar(
              radius: 50,
              backgroundImage: (widget.userModel.profilepic == Null)
                  ? AssetImage("assets/profileavatar.png")
                  : NetworkImage(widget.userModel.profilepic.toString()),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Text(
            widget.userModel.fullName.toString(),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(
            height: 10,
          ),
          // creating a list with visible animations namely home profile settings logout
          ListTile(
            leading: Icon(Icons.home),
            title: Text("Home"),
            onTap: () {
              Navigator.pushReplacement(
                context,
                PageTransition(
                  child: SideDrawer(
                      userModel: widget.userModel,
                      firebaseUser: widget.firebaseUser),
                  type: PageTransitionType.rightToLeft,
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text("Profile"),
            onTap: () {
              Navigator.push(
                context,
                PageTransition(
                  child: ProfilePage(
                      userModel: widget.userModel,
                      firebaseUser: widget.firebaseUser),
                  type: PageTransitionType.rightToLeft,
                ),
              );
            },
          ),
          // ListTile(
          //   leading: Icon(Icons.settings),
          //   title: Text("Settings"),
          //   onTap: () {
          //     Navigator.pop(context);
          //   },
          // ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text("Logout"),
            onTap: () async {
              // showing the alert dialog
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text("Logout"),
                    content: Text("Are you sure you want to logout?"),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text("No"),
                      ),
                      TextButton(
                        onPressed: () async {
                          // setting the online status to false
                          APIs.updateActiveStatus(false);
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          prefs.setBool("login", false);
                          await FirebaseAuth.instance.signOut();
                          // sending the user back to the login page
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoginPage(),
                            ),
                          );
                        },
                        child: Text("Yes"),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
