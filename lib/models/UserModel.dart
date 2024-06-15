class UserModel {
  String? uid;
  String? fullName;
  String? email;
  String? profilepic;
  late bool is_online;
  String? last_active;

  UserModel(
      {this.uid,
      this.fullName,
      this.email,
      this.profilepic,
      required this.is_online,
      this.last_active});

  UserModel.fromMap(Map<String, dynamic> map) {
    uid = map["uid"];
    fullName = map["fullName"];
    email = map["email"];
    profilepic = map["profilepic"];
    is_online = map["is_online"] ?? false;
    last_active = map["last_active"];
  }

  Map<String, dynamic> toMap() {
    return {
      "uid": uid,
      "fullName": fullName,
      "email": email,
      "profilepic": profilepic,
      "is_online": is_online,
      "last_active": last_active,
    };
  }
}
