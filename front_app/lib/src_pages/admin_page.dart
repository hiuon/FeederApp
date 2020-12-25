import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:front_app/Entities/Logs.dart';
import 'package:http/http.dart' as http;
import '../Entities/User.dart';
import '../Entities/Feeder.dart';
import '../Service/http_service.dart';

class AdminPage extends StatefulWidget {
  Widget build(BuildContext context) {
    return AdminPage();
  }

  State<StatefulWidget> createState() {
    return _AdminPageState();
  }
}

class _AdminPageState extends State<AdminPage> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        automaticallyImplyLeading: false,
        title: new Text("Admin Control Panel"),
      ),
      body: Container(
        margin: EdgeInsets.symmetric(vertical: 20.0),
        height: 800.0,
        child: AdminListView(),
      ),
    );
  }
}

class AdminListView extends StatefulWidget {
  @override
  _AdminListViewState createState() => _AdminListViewState();
}

class _AdminListViewState extends State<AdminListView> {
  //default parametres
  List<User> users;
  Timer timer;

  void initState() {
    super.initState();
    timer = Timer.periodic(
        Duration(seconds: 5),
        (Timer t) => HttpClientFeed.getUsers()
            .then((value) => users = value)
            .whenComplete(() => refresh()));
  }

  void refresh() {
    setState(() {});
  }

  _AdminListViewState() {
    http.get("http://localhost:5000/users").then((response) {
      var data = json.decode(response.body);
      var rest = data["users"] as List;
      users = new List<User>();
      print(data);
      users = rest.map<User>((json) => User.fromJson(json)).toList();
      setState(() {});
    });
  }

  Widget build(BuildContext context) {
    if (users == null) {
      return Container(
        margin: EdgeInsets.only(left: 10),
        alignment: Alignment.center,
        child: FlatButton(
          child: Icon(
            Icons.add_box_outlined,
            color: Colors.white,
          ),
          textColor: Colors.white,
          color: Colors.blue,
          shape: new RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(30.0)),
          onPressed: () {
            String name;
            TextEditingController _c = new TextEditingController();
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  print(name);
                  return AlertDialog(
                    title: Text("Добавить пользователя"),
                    content: TextField(
                      controller: _c,
                      textInputAction: TextInputAction.go,
                      decoration:
                          InputDecoration(hintText: "Введите имя пользователя"),
                    ),
                    actions: [
                      new FlatButton(
                        child: Text("Добавить"),
                        onPressed: () {
                          name = _c.text;
                          HttpClientFeed.addUser(name)
                              .then((value) => users = value)
                              .whenComplete(() => refresh());
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                        },
                      )
                    ],
                  );
                });
          },
        ),
      );
    }
    return ListView.builder(
        scrollDirection: Axis.vertical,
        itemCount: users.length + 1,
        itemBuilder: (context, index) {
          if (index == users.length) {
            return Container(
              margin: EdgeInsets.only(left: 10),
              alignment: Alignment.center,
              child: FlatButton(
                child: Icon(
                  Icons.add_box_outlined,
                  color: Colors.white,
                ),
                textColor: Colors.white,
                color: Colors.blue,
                shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(30.0)),
                onPressed: () {
                  String name;
                  TextEditingController _c = new TextEditingController();
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        print(name);
                        return AlertDialog(
                          title: Text("Добавить пользователя"),
                          content: TextField(
                            controller: _c,
                            textInputAction: TextInputAction.go,
                            decoration: InputDecoration(
                                hintText: "Введите имя пользователя"),
                          ),
                          actions: [
                            new FlatButton(
                              child: Text("Добавить"),
                              onPressed: () {
                                name = _c.text;
                                HttpClientFeed.addUser(name)
                                    .then((value) => users = value)
                                    .whenComplete(() => refresh());
                                Navigator.of(context).pop();
                              },
                            )
                          ],
                        );
                      });
                },
              ),
            );
          }
          return Container(
            margin: EdgeInsets.only(bottom: 20, right: 20, left: 20, top: 20),
            height: 150.0,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                border: Border.all(width: 1, color: Colors.blueGrey)),
            child: ListView(scrollDirection: Axis.horizontal, children: [
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(width: 1, color: Colors.black12)),
                child: Image.asset(
                  'images/user.png',
                  height: 20,
                  scale: 2,
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 20),
                alignment: Alignment.center,
                child: Text("Имя: " + users[index].name),
              ),
              Container(
                margin: EdgeInsets.only(left: 20),
                alignment: Alignment.center,
                child: FlatButton(
                  child: Text("     Удалить\nПользователя"),
                  textColor: Colors.white,
                  color: Colors.blue,
                  shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(30.0)),
                  onPressed: () {
                    HttpClientFeed.deleteUser(users[index].userId)
                        .whenComplete(() {
                      setState(() {});
                    }).then((value) => users = value);
                    //HttpClientFeed.getUsers().then((value) => users = value);
                  },
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 20),
                alignment: Alignment.center,
                child: FlatButton(
                  child: Text("Эксортировать лог\n   Пользователя"),
                  textColor: Colors.white,
                  shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(30.0)),
                  color: Colors.blue,
                  onPressed: () {
                    HttpClientFeed.downloadLogs(users[index].userId, -1);
                  },
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 40),
                alignment: Alignment.center,
                child: FlatButton(
                  child: Text("+"),
                  textColor: Colors.white,
                  color: Colors.blue,
                  shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(30.0)),
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          List<bool> feed = [true, false];
                          return AlertDialog(
                            title: Text("Добавить кормушку"),
                            content: StatefulBuilder(
                              builder:
                                  (BuildContext context, StateSetter setState) {
                                return ToggleButtons(
                                  isSelected: feed,
                                  onPressed: (int _index) {
                                    setState(() {
                                      for (int buttonIndex = 0;
                                          buttonIndex < feed.length;
                                          buttonIndex++) {
                                        if (buttonIndex == _index) {
                                          feed[buttonIndex] = true;
                                        } else {
                                          feed[buttonIndex] = false;
                                        }
                                      }
                                    });
                                  },
                                  children: [
                                    Text("Классическая"),
                                    Text("Спиральная")
                                  ],
                                );
                              },
                            ),
                            actions: [
                              new FlatButton(
                                child: Text("Добавить"),
                                onPressed: () {
                                  String name;
                                  if (feed[0] == true) {
                                    name = "normal";
                                  } else {
                                    name = "spiral";
                                  }
                                  HttpClientFeed.addFeeder(
                                          users[index].userId, name)
                                      .then((value) => users = value)
                                      .whenComplete(() => refresh());
                                  Navigator.of(context).pop();
                                },
                              )
                            ],
                          );
                        });
                  },
                ),
              ),
              Container(
                  margin: EdgeInsets.only(left: 20),
                  child: Row(
                      children:
                          buildRow(users[index].feeders, users[index].userId))),
            ]),
          );
        });
  }

  List<Widget> buildRow(List<Feeder> feeders, int userId) {
    List<Widget> rows = new List<Widget>();
    for (int i = 0; i < feeders.length; i++) {
      rows.add(Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.only(left: 40, right: 40),
            child: Text(feeders[i].feederId.toString()),
          ),
          Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                border: Border.all(width: 1, color: Colors.black12)),
            child: Image.asset(
              'images/' + feeders[i].feederType + '.png',
              height: 35,
              scale: 5,
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 40, right: 40),
            child: Text("Наполненность: " +
                feeders[i].filledInernally.toString() +
                "%"),
          ),
          Container(
            child: FlatButton(
              child: Text("Просмотреть лог"),
              textColor: Colors.white,
              color: Colors.blue,
              shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(30.0)),
              onPressed: () {
                List<Log> logs;
                HttpClientFeed.getFeederLog(userId, feeders[i].feederId)
                    .then((value) => logs = value)
                    .whenComplete(() => showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text("ЛОГ"),
                            content: Container(
                                height: 400,
                                width: 800,
                                child: SingleChildScrollView(
                                  child: Text(Log.logToString(logs)),
                                )),
                            actions: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    child: FlatButton(
                                      child: Text("Export"),
                                      color: Colors.blue,
                                      textColor: Colors.white,
                                      onPressed: () {
                                        HttpClientFeed.downloadLogs(
                                            userId, feeders[i].feederId);
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ),
                                  Container(
                                    margin:
                                        EdgeInsets.only(right: 20, left: 20),
                                    child: FlatButton(
                                      child: Text("Close"),
                                      color: Colors.blue,
                                      textColor: Colors.white,
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ),
                                ],
                              )
                            ],
                          );
                        }));
              },
            ),
          ),
          Container(
            child: FlatButton(
              child: Text("Удалить кормушку"),
              textColor: Colors.white,
              color: Colors.blue,
              shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(30.0)),
              onPressed: () {
                HttpClientFeed.deleteFeeder(userId, feeders[i].feederId)
                    .then((value) => users = value)
                    .whenComplete(() => refresh());
              },
            ),
          ),
        ],
      ));
    }
    return rows;
  }
}
