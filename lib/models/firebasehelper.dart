import 'package:chattingapp/models/UserModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Firebasehelper {
  static Future<UserModel?> getUserModelById(String uid) async {
    UserModel? userModel;

    DocumentSnapshot docsnap =
        await FirebaseFirestore.instance.collection("users").doc(uid).get();

    if (docsnap.data() != null) {
      userModel = UserModel.fromMap(docsnap.data() as Map<String, dynamic>);
    }

    return userModel;
  }
}
