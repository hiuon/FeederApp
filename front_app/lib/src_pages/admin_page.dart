import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../Entities/User.dart';
import '../Entities/Feeder.dart';

class AdminPage extends StatelessWidget {
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
          color: Colors.blue,
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
                          print(name);
                          http
                              .get("http://localhost:5000/users/new?name=$name")
                              .then((response) {});
                          http
                              .get("http://localhost:5000/users")
                              .then((response) {
                            var data = json.decode(response.body);
                            var rest = data["users"] as List;
                            users = new List<User>();
                            users = rest
                                .map<User>((json) => User.fromJson(json))
                                .toList();
                            print(users[0].feeders);
                            setState(() {});
                          });
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
                color: Colors.blue,
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
                                print(name);
                                http
                                    .get(
                                        "http://localhost:5000/users/new?name=$name")
                                    .then((response) {});
                                http
                                    .get("http://localhost:5000/users")
                                    .then((response) {
                                  var data = json.decode(response.body);
                                  var rest = data["users"] as List;
                                  users = new List<User>();
                                  users = rest
                                      .map<User>((json) => User.fromJson(json))
                                      .toList();
                                  print(users[0].feeders);
                                  setState(() {});
                                });
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
                  color: Colors.blue,
                  onPressed: () {
                    http
                        .delete(
                            "http://localhost:5000/users/?userId=${users[index].userId}")
                        .then((response) {});
                    http.get("http://localhost:5000/users").then((response) {
                      var data = json.decode(response.body);
                      var rest = data["users"] as List;
                      print(response.body);
                      users = new List<User>();
                      users = rest
                          .map<User>((json) => User.fromJson(json))
                          .toList();
                      setState(() {});
                    });

                    http.get("http://localhost:5000/users").then((response) {
                      var data = json.decode(response.body);
                      var rest = data["users"] as List;
                      print(response.body);
                      users = new List<User>();
                      users = rest
                          .map<User>((json) => User.fromJson(json))
                          .toList();
                      setState(() {});
                    });
                    setState(() {});
                  },
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 40),
                alignment: Alignment.center,
                child: FlatButton(
                  child: Text("+"),
                  color: Colors.blue,
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
                                  String post_data =
                                      "feederId=-1&userId=${users[index].userId}&labels=&feederType=$name&timeTable=no&capacity=100&filledInternally=100&filledExternally=0";
                                  print(feed);
                                  http
                                      .post(
                                        "http://localhost:5000/feeders/?$post_data",
                                      )
                                      .then((response) {});
                                  http
                                      .get("http://localhost:5000/users")
                                      .then((response) {
                                    var data = json.decode(response.body);
                                    var rest = data["users"] as List;
                                    print(response.body);
                                    users = new List<User>();
                                    users = rest
                                        .map<User>(
                                            (json) => User.fromJson(json))
                                        .toList();
                                    setState(() {});
                                  });

                                  http
                                      .get("http://localhost:5000/users")
                                      .then((response) {
                                    var data = json.decode(response.body);
                                    var rest = data["users"] as List;
                                    print(response.body);
                                    users = new List<User>();
                                    users = rest
                                        .map<User>(
                                            (json) => User.fromJson(json))
                                        .toList();
                                    setState(() {});
                                  });
                                  Navigator.of(context).pop();
                                  setState(() {});
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
              color: Colors.blue,
              onPressed: () {},
            ),
          ),
          Container(
            child: FlatButton(
              child: Text("Удалить кормушку"),
              color: Colors.blue,
              onPressed: () {
                http
                    .delete(
                      "http://localhost:5000/feeders/?userId=$userId&feederId=${feeders[i].feederId}",
                    )
                    .then((response) {});
                http.get("http://localhost:5000/users").then((response) {
                  var data = json.decode(response.body);
                  var rest = data["users"] as List;
                  users = new List<User>();
                  users =
                      rest.map<User>((json) => User.fromJson(json)).toList();
                });
                http.get("http://localhost:5000/users").then((response) {
                  var data = json.decode(response.body);
                  var rest = data["users"] as List;
                  users = new List<User>();
                  users =
                      rest.map<User>((json) => User.fromJson(json)).toList();
                  setState(() {});
                });
                setState(() {});
              },
            ),
          ),
        ],
      ));
    }
    return rows;
  }
}

/*addUser(BuildContext context, String name) {
  TextEditingController _c;
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
            child: SizedBox(
          height: 100,
          width: 100,
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(hintText: "Имя пользователя"),
                controller: _c,
              ),
              FlatButton(
                child: Text("Добавить"),
                color: Colors.blue,
                onPressed: () {
                  name = _c.text;
                  print(name);
                  Navigator.pop(context);
                },
              )
            ],
          ),
        ));
      });
}*/