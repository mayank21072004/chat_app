import 'package:chattingapp/helpers_app/alert_dialog.dart';
import 'package:chattingapp/helpers_app/alert_dialog_2.dart';
import 'package:chattingapp/helpers_app/email_already_exist.dart';
import 'package:chattingapp/helpers_app/password_weak.dart';
import 'package:chattingapp/models/UserModel.dart';
import 'package:chattingapp/pages/CompleteProfile.dart';
import 'package:chattingapp/pages/LoginPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:page_transition/page_transition.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool isloading = false;
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _cPasswordController = TextEditingController();

  void checkPassword() {
    if (_passwordController.text != _cPasswordController.text) {
      showDialog(
        context: context,
        builder: (context) {
          return CustomDialogWidgetss();
        },
      );
    }
  }

  void checkValues() {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String cPassword = _cPasswordController.text.trim();

    if (email.isEmpty || password.isEmpty || cPassword.isEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return CustomDialogWidget();
        },
      );
    } else if (_passwordController.text != _cPasswordController.text) {
      checkPassword();
    } else {
      Signup(email, password);
    }
  }

  void Signup(String email, String password) async {
    setState(() {
      isloading = true;
    });

    UserCredential? credentials;
    try {
      credentials = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        setState(() {
          isloading = false;
        });
        print('The password provided is too weak.');
        _showDialog2('The password provided is too weak.');
        // show dialog that the password is weak
      } else if (e.code == 'email-already-in-use') {
        setState(() {
          isloading = false;
        });
        print('The account already exists for that email.');
        _showDialog('The account already exists for that email.');
      }
    } catch (e) {
      print(e);
    }
    if (credentials != null) {
      String uid = credentials.user!.uid;
      UserModel newUser = UserModel(
        uid: uid,
        fullName: "",
        email: email,
        profilepic: "",
        is_online: true,
        last_active: "not yet active",
      );
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set(newUser.toMap())
          .then((value) {
        setState(() {
          isloading = false;
        });
        Navigator.pushReplacement(
          context,
          PageTransition(
            child: CompleteProfile(
              userModel: newUser,
              firebaseUser: credentials!.user!,
            ),
            type: PageTransitionType.rightToLeft,
          ),
        );
        print("User Added");
      });
    }
  }

  void _showDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return MyDialogue2();
      },
    );
  }

  void _showDialog2(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return MyDialogue3();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: isloading == true
              ? Lottie.asset(
                  "assets/animation3.json",
                )
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      SvgPicture.asset("assets/signup.svg",
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
                          controller: _emailController,
                          decoration: InputDecoration(
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
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            hintText: "Password",
                            prefixIcon: Icon(Icons.lock),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: TextField(
                          controller: _cPasswordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            hintText: "confirm Password",
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
                        child: Text("Sign Up"),
                      ),
                    ],
                  ),
                ),
        ),
      ),
      // if u dont have and account then sign up
      bottomNavigationBar: isloading == true
          ? Text("Please Wait...")
          : Container(
              height: 100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already Have an account?",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 20,
                    ),
                  ),
                  CupertinoButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("Sign In"),
                  ),
                ],
              ),
            ),
    );
  }
}
