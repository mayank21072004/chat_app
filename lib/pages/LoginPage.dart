import 'package:chattingapp/helpers_app/WrongPassword.dart';
import 'package:chattingapp/helpers_app/alert_dialog.dart';
import 'package:chattingapp/helpers_app/password_weak.dart';
import 'package:chattingapp/models/UserModel.dart';
import 'package:chattingapp/pages/Homepage.dart';
import 'package:chattingapp/pages/SignUpPage.dart';
import 'package:chattingapp/pages/side_drawer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  bool isloggingin = false;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  late final AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void checkValues() {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      print("Please fill all the fields");
      showDialog(
        context: context,
        builder: (context) {
          return CustomDialogWidget();
        },
      );
    } else {
      logiIn(email, password);
    }
  }

  void logiIn(String email, String password) async {
    UserCredential? credentials;

    setState(() {
      isloggingin = true;
    });

    try {
      credentials = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      // print("User Logged in");
    } on FirebaseAuthException catch (e) {
      setState(() {
        isloggingin = false;
      });
      _showdialog('password is wrong');
      print(e);
    }

    if (credentials != null) {
      setvalue();
      String uid = credentials.user!.uid;

      DocumentSnapshot userData =
          await FirebaseFirestore.instance.collection("users").doc(uid).get();

      await Future.delayed(Duration(seconds: 6));

      UserModel userModel =
          UserModel.fromMap(userData.data() as Map<String, dynamic>);

      print("User Logged in");
      setState(() {
        isloggingin = false;
      });

      Navigator.pushReplacement(
          context,
          PageTransition(
            child: SideDrawer(
                userModel: userModel, firebaseUser: credentials.user!),
            type: PageTransitionType.rightToLeft,
          )).then((value) {});
    }
  }

  void setvalue() async {
    var sharedpref = await SharedPreferences.getInstance();
    sharedpref.setBool("login", true);
    print("Value set of the shared preference to true");
  }

  void _showdialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return Wrongpassword();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                isloggingin == true
                    ? LottieBuilder.asset("assets/animation3.json",
                        height: 200, width: 200, fit: BoxFit.cover)
                    : SvgPicture.asset("assets/chat.svg",
                        height: 250, width: 250),
                SizedBox(
                  height: 20,
                ),
                Text(
                  "Chat APP",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      floatingLabelAlignment: FloatingLabelAlignment.center,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      hintText: "Email",
                      prefixIcon: Icon(Icons.email),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hoverColor: Colors.blue,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      hintText: "Password",
                      prefixIcon: Icon(Icons.lock),
                    ),
                  ),
                ),
                SizedBox(height: 15),
                CupertinoButton(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(20),
                  onPressed: () {
                    checkValues();
                  },
                  child: isloggingin == true
                      ? CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : Text("Login"),
                ),
              ],
            ),
          ),
        ),
      ),
      // if u dont have and account then sign up
      bottomNavigationBar: Container(
        height: 100,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Don't have an account?",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 20,
              ),
            ),
            CupertinoButton(
              onPressed: () {
                Navigator.push(
                    context,
                    PageTransition(
                      child: SignUpPage(),
                      type: PageTransitionType.rotate,
                      alignment: Alignment.center,
                      duration: const Duration(milliseconds: 700),
                      reverseDuration: const Duration(milliseconds: 700),
                    ));
              },
              child: Text("Sign Up"),
            ),
          ],
        ),
      ),
    );
  }
}
