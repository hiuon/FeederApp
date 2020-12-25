import 'dart:js' as js;

import '../Entities/Feeder.dart';
import '../Entities/Logs.dart';
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
        "/feeders/?feederId=-1&userId=$userId&labels=&labelsState=&feederType=$name&timeTable=0__0__0__0__0__0__0__0&capacity=100&filledInternally=100&filledExternally=0");
    return getUsers();
  }

  static Future<List<User>> addUser(String name) async {
    final response = await http.get(url + "/users/new?name=$name");
    return getUsers();
  }

  static Future<List<Feeder>> getFeeders(int userId) async {
    List<Feeder> feeders;
    final response = await http.get(url + "/users/?userId=$userId");
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      var rest = data["feeders"] as List;
      feeders = new List<Feeder>();
      feeders = rest.map<Feeder>((json) => Feeder.fromJson(json)).toList();
      for (int i = 0; i < feeders.length; i++) {
        feeders[i].userId = userId;
        print(feeders[i].labels);
        if (feeders[i].labels[0] == '') {
          feeders[i].labelsState = new List<bool>();
          feeders[i].labels = new List<String>();
        }
      }
    } else {
      return null;
    }
    return feeders;
  }

  static Future<List<Feeder>> changeFeeder(String data, int userId) async {
    final response = await http.post(url + "/feeders/?$data");
    return getFeeders(userId);
  }

  static Future<List<Feeder>> addFood(
      int feederId, int userId, String amount) async {
    final response = await http.post(url +
        "/feeders/?feedingAmount=$amount&feederId=$feederId&userId=$userId");
    return getFeeders(userId);
  }

  static Future<List<Log>> getFeederLog(int userId, int feederId) async {
    List<Log> logs;
    final response =
        await http.get(url + "/feeders/logs?userId=$userId&feederId=$feederId");
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      var rest = data["logs"] as List;
      logs = new List<Log>();
      logs = rest.map<Log>((json) => Log.fromJson(json)).toList();
    } else {
      return null;
    }
    return logs;
  }

  static void downloadLogs(int userId, int feederId) {
    /*new HttpClient()
        .getUrl(
            Uri.parse(url + "/exportLogs?userId=$userId&feederId=$feederId"))
        .then((HttpClientRequest request) => request.close())
        .then((HttpClientResponse response) =>
            response.pipe(new File('exportLogs.txt').openWrite()))*/

    //http.get(url + "/exportLogs?userId=$userId&feederId=$feederId");
    /*print("file download");
    html.AnchorElement anchorElement = html.AnchorElement(
        href: url + "/exportLogs?userId=$userId&feederId=$feederId");
    anchorElement.download =
        url + "/exportLogs?userId=$userId&feederId=$feederId";
    anchorElement.click();*/
    js.context.callMethod(
        'open', [url + "/exportLogs?userId=$userId&feederId=$feederId"]);
  }
}
