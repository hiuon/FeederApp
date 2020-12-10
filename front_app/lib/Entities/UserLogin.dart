class UserLogin {
  int id;
  String name;

  UserLogin({this.id, this.name});

  factory UserLogin.fromJson(Map<String, dynamic> json) {
    return UserLogin(
      id: json["id"] as int,
      name: json["name"] as String,
    );
  }
}
