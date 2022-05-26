class UserModel {
  final String uid;
  final String displayName;
  final String photoURL;
  final String email;

  UserModel({
    required this.uid,
    required this.displayName,
    required this.photoURL,
    required this.email,
  });

  factory UserModel.fromMap(Map map) {
    return UserModel(
      uid: map["uid"],
      displayName: map["displayName"]??" ",
      photoURL: map["photoURL"]?? "https://eitrawmaterials.eu/wp-content/uploads/2016/09/person-icon.png",
      email: map["email"],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "uid": uid,
      "displayName": displayName,
      "photoURL": photoURL,
      "email": email,
    };
  }
}
