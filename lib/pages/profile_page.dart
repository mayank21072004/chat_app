import 'dart:io';

import 'package:chattingapp/models/UserModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;
  ProfilePage({super.key, required this.userModel, required this.firebaseUser});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  final TextEditingController phoneController =
      TextEditingController(text: '+92 317 8059528');

  final TextEditingController passwordController =
      TextEditingController(text: '••••••••');

  bool updating = false;
  File? imageFile;

  @override
  void initState() {
    super.initState();
    fullNameController.text = widget.userModel.fullName.toString();
    emailController.text = widget.userModel.email.toString();
  }
  // updating the values of the user to the firebase

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

  void updatevalues() async {
    setState(() {
      updating = true;
    });
    UploadTask uploadTask = FirebaseStorage.instance
        .ref("profilepictures")
        .child(widget.userModel.uid.toString())
        .putFile(imageFile!);
    TaskSnapshot snapshot = await uploadTask;
    String imageUrl = await snapshot.ref.getDownloadURL();
    widget.userModel.profilepic = imageUrl;
    widget.userModel.fullName = fullNameController.text;
    await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.firebaseUser.uid)
        .update(widget.userModel.toMap())
        .then((value) {
      setState(() {
        updating = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.black,
        elevation: 0,
        // leading: IconButton(
        //   icon: Icon(Icons.arrow_back, color: Colors.white),
        //   onPressed: () {},
        // ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            children: [
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      // setting user image as background image
                      backgroundImage: (widget.userModel.profilepic == null)
                          ? AssetImage("assets/profileavatar.png")
                          : NetworkImage(
                              widget.userModel.profilepic.toString()),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: InkWell(
                        onTap: () {
                          // Handle image picker action here
                          print('Change profile picture');
                          showModalBottomSheet(
                            context: context,
                            builder: (context) {
                              return Container(
                                height: 150,
                                padding: EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Choose Profile Picture',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 20),
                                    Row(
                                      children: [
                                        ElevatedButton.icon(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            selectImage(ImageSource.camera);
                                          },
                                          icon: Icon(Icons.camera),
                                          label: Text('Camera'),
                                        ),
                                        SizedBox(width: 20),
                                        ElevatedButton.icon(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            selectImage(ImageSource.gallery);
                                          },
                                          icon: Icon(Icons.image),
                                          label: Text('Gallery'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                        child: CircleAvatar(
                          backgroundColor: Colors.yellow,
                          radius: 15,
                          child: Icon(Icons.camera_alt,
                              size: 20, color: Colors.black),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(height: 30),
              TextField(
                // readOnly: true,
                controller: fullNameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  labelStyle: TextStyle(color: Colors.white),
                  hintText: 'Coding with T',
                  hintStyle: TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: Colors.black,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.yellow),
                  ),
                ),
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 20),
              TextField(
                readOnly: true,
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'E-Mail',
                  labelStyle: TextStyle(color: Colors.white),
                  hintText: 'support@codingwitht.com',
                  hintStyle: TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: Colors.black,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.yellow),
                  ),
                ),
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 20),
              TextField(
                readOnly: true,
                controller: phoneController,
                decoration: InputDecoration(
                  labelText: 'Phone No',
                  labelStyle: TextStyle(color: Colors.white),
                  hintText: '+92 317 8059528',
                  hintStyle: TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: Colors.black,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.yellow),
                  ),
                ),
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 20),
              TextField(
                readOnly: true,
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(color: Colors.white),
                  hintText: '••••••••',
                  hintStyle: TextStyle(color: Colors.white),
                  suffixIcon: Icon(Icons.visibility_off, color: Colors.white),
                  filled: true,
                  fillColor: Colors.black,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.yellow),
                  ),
                ),
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  // Handle edit profile action here
                  print('Full Name: ${fullNameController.text}');
                  print('Email: ${emailController.text}');
                  print('Phone: ${phoneController.text}');
                  print('Password: ${passwordController.text}');
                  // if updating is true then return circular progress indicator
                  updatevalues();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  minimumSize: Size(double.infinity, 50),
                ),
                child: (updating)
                    ? CircularProgressIndicator()
                    : Text('Edit Profile'),
              ),
              SizedBox(height: 20),
              Text(
                'Joined 31 October 2022',
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  // Handle delete action here
                  print('Delete account');
                },
                style: TextButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: Text('Delete'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
