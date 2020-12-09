import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:front_app/src_pages/admin_page.dart';
import 'package:front_app/src_pages/user_page.dart';
import '../Entities/UserLogin.dart';
import 'package:http/http.dart' as http;

class LoginPage extends StatefulWidget {
  Widget build(BuildContext context) {
    return LoginPage();
  }

  @override
  State<StatefulWidget> createState() {
    return _LoginPageState();
  }
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    final title = 'Login Page';
    _UserListViewState();
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Container(
        margin: EdgeInsets.symmetric(vertical: 20.0),
        height: 800.0,
        child: ListView(scrollDirection: Axis.vertical, children: [
          Container(
            width: 100.0,
            height: 200,
            decoration: BoxDecoration(
                border: Border.all(color: Colors.blueGrey),
                color: Colors.white),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  child: Image.asset(
                    'images/admin.png',
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
                FlatButton(
                  child: Text("Admin"),
                  onPressed: () {
                    Navigator.push(
                      context,
                      new MaterialPageRoute(
                          builder: (context) => new AdminPage()),
                    );
                  },
                ),
              ],
            ),
          ),
          Container(
              margin: EdgeInsets.symmetric(vertical: 20.0),
              height: 400.0,
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.blueGrey),
                  color: Colors.white),
              child: UserListView()),
        ]),
      ),
    );
  }
}

class UserListView extends StatefulWidget {
  @override
  _UserListViewState createState() => _UserListViewState();
}

class _UserListViewState extends State<UserListView> {
  List<User> _body;

  _UserListViewState() {
    http.get("http://localhost:5000").then((response) {
      var data = json.decode(response.body);
      var rest = data["users"] as List;
      _body = rest.map<User>((json) => User.fromJson(json)).toList();
      print(this._body);
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_body == null) {
      return Container();
    }
    return ListView.builder(
      scrollDirection: Axis.vertical,
      itemCount: _body.length,
      itemBuilder: (context, index) {
        return Container(
          width: 50.0,
          height: 100,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                child: Image.asset(
                  'images/user.png',
                  height: 50,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                child: Text(_body[index].name), //userName
                onPressed: () {
                  Navigator.push(
                    context,
                    new MaterialPageRoute(
                        builder: (context) => new UserPage(
                              userId: _body[index].id,
                              name: _body[index].name,
                            )),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
