import '../Entities/Feeder.dart';
import '../Entities/User.dart';
import '../Entities/UserLogin.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const String url = 'http://localhost:5000';

class HttpClientFeed {
  static Future<List<UserLogin>> getUserLogin() async {
    /*http.get(url).then((response) {
      var data = json.decode(response.body);
      var rest = data["users"] as List;
      _body =
          rest.map<UserLogin>((json) => UserLogin.fromJson(json)).toList();
      print(_body);
    });*/
    final response = await http.get(url);
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      var rest = data["users"] as List;
      return rest.map<UserLogin>((json) => UserLogin.fromJson(json)).toList();
    } else {
      return null;
    }
  }
}
