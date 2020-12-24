import '../Entities/Feeder.dart';
import '../Entities/User.dart';
import '../Entities/UserLogin.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const String url = 'http://localhost:5000';

class HttpClientFeed {
  static Future<List<UserLogin>> getUserLogin() async {
    final response = await http.get(url);
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      var rest = data["users"] as List;
      return rest.map<UserLogin>((json) => UserLogin.fromJson(json)).toList();
    } else {
      return null;
    }
  }

  static Future<List<User>> getUsers() async {
    final response = await http.get(url + "/users");
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      var rest = data["users"] as List;
      return rest.map<User>((json) => User.fromJson(json)).toList();
    } else {
      return null;
    }
  }

  static Future<List<User>> deleteUser(int userId) async {
    final response = await http.delete(url + "/users/?userId=$userId");
    return getUsers();
  }

  static Future<List<User>> deleteFeeder(int userId, int feederId) async {
    final response =
        await http.delete(url + "/feeders/?userId=$userId&feederId=$feederId");
    return getUsers();
  }

  static Future<List<User>> addFeeder(int userId, String name) async {
    final response = await http.post(url +
        "/feeders/?feederId=-1&userId=$userId&labels=&feederType=$name&timeTable=no&capacity=100&filledInternally=100&filledExternally=0");
    return getUsers();
  }

  static Future<List<User>> addUser(String name) async {
    final response = await http.get(url + "/users/new?name=$name");
    return getUsers();
  }
}
