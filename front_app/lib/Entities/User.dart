import 'Feeder.dart';

class User {
  List<Feeder> feeders;
  int userId;
  String name;
  //List<String> timeTables;

  User({this.feeders, this.userId, this.name});

  factory User.fromJson(Map<String, dynamic> json) {
    var list = json['feeders'] as List;
    return User(
        feeders: list.map((i) => Feeder.fromJson(i)).toList(),
        userId: json["id"] as int,
        //timeTables: json["timeTables"] as List<String>,
        name: (json["name"] as String).toString());
  }
}
