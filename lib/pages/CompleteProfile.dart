import 'dart:io';
// import 'dart:nativewrappers/_internal/vm/lib/developer.dart';
// import 'dart:math';

import 'package:chattingapp/models/UserModel.dart';
import 'package:chattingapp/pages/Homepage.dart';
import 'package:chattingapp/pages/side_drawer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';

class CompleteProfile extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;
  const CompleteProfile(
      {super.key, required this.userModel, required this.firebaseUser});

  @override
  State<CompleteProfile> createState() => _CompleteProfileState();
}

class _CompleteProfileState extends State<CompleteProfile> {
  bool isloading = false;
  File? imageFile;
  TextEditingController fullNameController = TextEditingController();

  void selectImage(ImageSource source) async {
    XFile? pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      cropImage(pickedFile);
    }
  }

  void cropImage(XFile file) async {
    CroppedFile? croppedImage = await ImageCropper().cropImage(
      sourcePath: file.path,
      // aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
      compressQuality: 20,
      cropStyle: CropStyle.circle,
    );

    if (croppedImage != null) {
      setState(() {
        imageFile = File(croppedImage.path);
      });
    }
  }

  void showPhotoOptions() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          title: Text('Choose Profile Photo'),
          actions: [
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
                selectImage(ImageSource.camera);
              },
              child: Text(
                'Camera',
                style: TextStyle(
                  color: Colors.black87,
                ),
              ),
            ),
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
                selectImage(ImageSource.gallery);
              },
              child: Text(
                'Gallery',
                style: TextStyle(
                  color: Colors.black87,
                ),
              ),
            ),
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  imageFile = null;
                });
              },
              child: Text(
                'Remove Photo',
                style: TextStyle(
                  color: Colors.black87,
                ),
              ),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Colors.black87,
              ),
            ),
          ),
        );
      },
    );
  }

  void checkValues() {
    String fullName = fullNameController.text.trim();

    if (fullName.isEmpty || imageFile == null) {
      print("Please fill all the fields");
    } else {
      // log("All fields are filled");
      print("All fields are filled");
      uploadData();
    }
  }

  void uploadData() async {
    setState(() {
      isloading = true;
    });
    UploadTask uploadTask = FirebaseStorage.instance
        .ref("profilepictures")
        .child(widget.userModel.uid.toString())
        .putFile(imageFile!);

    TaskSnapshot snapshot = await uploadTask;
    String imageUrl = await snapshot.ref.getDownloadURL();
    String fullname = fullNameController.text.trim();

    widget.userModel.fullName = fullname;
    widget.userModel.profilepic = imageUrl;

    await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.userModel.uid)
        .set(widget.userModel.toMap())
        .then((value) {
      // log("User data uploaded successfully");
      print("User data uploaded successfully");
      setState(() {
        isloading = false;
      });
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SideDrawer(
            userModel: widget.userModel,
            firebaseUser: widget.firebaseUser,
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100.0,
        automaticallyImplyLeading: false,
        // decorating the app bar
        backgroundColor: Colors.purple[200],
        centerTitle: true,
        title: Text('Complete Profile'),
      ),
      body: SafeArea(
        child: isloading == true
            ? Lottie.asset(
                "assets/animation3.json",
              )
            : Container(
                child: ListView(
                  children: [
                    SizedBox(
                      height: 40,
                    ),
                    CupertinoButton(
                      onPressed: () {
                        showPhotoOptions();
                      },
                      child: Center(
                        child: CircleAvatar(
                          // backgroundImage:
                          //     (imageFile != null) ? FileImage(imageFile!) : null,
                          backgroundImage: (imageFile != null)
                              ? FileImage(imageFile!, scale: 1.0)
                              : null,
                          radius: 70,
                          child: (imageFile == null)
                              ? Image.asset(
                                  'assets/profileavatar.png',
                                  height: 110,
                                )
                              : null,
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 70, left: 20, right: 20),
                      child: TextField(
                        controller: fullNameController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          hintText: "Name",
                          prefixIcon: Icon(Icons.person_2),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      padding: EdgeInsets.all(20),
                      child: CupertinoButton(
                        onPressed: () {
                          checkValues();
                        },
                        padding: EdgeInsets.all(20),
                        color: Theme.of(context).colorScheme.primary,
                        child: Text("Save"),
                      ),
                    )
                  ],
                ),
              ),
      ),
    );
  }
}
