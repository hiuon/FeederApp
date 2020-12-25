import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:front_app/Entities/Logs.dart';
import 'package:front_app/Service/http_service.dart';
import 'package:http/http.dart' as http;
import '../Entities/Feeder.dart';

class UserPage extends StatelessWidget {
  final int userId;
  final String name;

  UserPage({Key key, @required this.userId, @required this.name})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        automaticallyImplyLeading: false,
        title: new Text(name + "'s feeders" + " (" + userId.toString() + ")"),
      ),
      body: Container(
        margin: EdgeInsets.symmetric(vertical: 20.0),
        height: 500.0,
        child: FeederListView(userId),
      ),
    );
  }
}

class FeederListView extends StatefulWidget {
  final int userId;
  FeederListView(this.userId);
  @override
  _FeederListViewState createState() => _FeederListViewState(userId);
}

class _FeederListViewState extends State<FeederListView> {
  //default parametres
  Timer timer;
  List<Feeder> feeders;
  int userId;
  String url = "localhost:5000";

  _FeederListViewState(int userId) {
    this.userId = userId;
    HttpClientFeed.getFeeders(userId)
        .then((value) => feeders = value)
        .whenComplete(() => refresh());
  }

  void refresh() {
    setState(() {});
  }

  void initState() {
    super.initState();
    timer = Timer.periodic(
        Duration(seconds: 5),
        (Timer t) => HttpClientFeed.getFeeders(userId)
            .then((value) => feeders = value)
            .whenComplete(() => refresh()));
  }

  Widget build(BuildContext context) {
    if (feeders == null) {
      return Container();
    }
    return ListView.builder(
        scrollDirection: Axis.vertical,
        itemCount: feeders.length,
        itemBuilder: (context, index) {
          return Container(
            margin: EdgeInsets.only(bottom: 20, right: 20, left: 20, top: 20),
            height: 130.0,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                border: Border.all(width: 1, color: Colors.blueGrey)),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(width: 1, color: Colors.black12)),
                  child: Image.asset(
                    'images/' + feeders[index].feederType + '.png',
                    height: 20,
                    scale: 2,
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 20),
                  alignment: Alignment.center,
                  child: Text("Id: " + feeders[index].feederId.toString()),
                ),
                Container(
                    margin: EdgeInsets.only(left: 80, top: 30, bottom: 30),
                    alignment: Alignment.center,
                    child: Row(
                      children: [
                        ToggleButtons(
                          isSelected: feeders[index].labelsState,
                          onPressed: (int _index) {
                            setState(() {
                              feeders[index].labelsState[_index] =
                                  !feeders[index].labelsState[_index];
                            });
                            HttpClientFeed.changeFeeder(
                                    Feeder.changeLabel(feeders[index]), userId)
                                .then((value) => feeders = value);
                          },
                          children: showToggle(feeders[index].labels),
                        )
                      ],
                    )),
                Container(
                    margin: EdgeInsets.only(left: 10, top: 30, bottom: 30),
                    alignment: Alignment.center,
                    child: FlatButton(
                      child: Text("+"),
                      color: Colors.blue,
                      onLongPress: () {
                        HttpClientFeed.changeFeeder(
                                Feeder.removeLabel(feeders[index]), userId)
                            .then((value) => feeders = value)
                            .whenComplete(() => refresh());
                      },
                      onPressed: () {
                        TextEditingController _c = new TextEditingController();
                        String label;
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text("Добавить метку"),
                                content: TextField(
                                  controller: _c,
                                  textInputAction: TextInputAction.go,
                                  decoration: InputDecoration(
                                      hintText: "Введите название метки"),
                                ),
                                actions: [
                                  new FlatButton(
                                    child: Text("Добавить"),
                                    onPressed: () {
                                      label = _c.text;

                                      HttpClientFeed.changeFeeder(
                                              Feeder.addLabel(
                                                  feeders[index], label),
                                              userId)
                                          .then((value) => feeders = value)
                                          .whenComplete(() => refresh());
                                      Navigator.of(context).pop();
                                    },
                                  )
                                ],
                              );
                            });
                      },
                    )),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      margin: EdgeInsets.only(left: 80, top: 5, bottom: 5),
                      alignment: Alignment.center,
                      child: Text("Наполненность кормушки: " +
                          feeders[index].filledInernally.toString() +
                          "%"),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 80, top: 5, bottom: 5),
                      alignment: Alignment.center,
                      child: Text("Наполненность миски: " +
                          feeders[index].filledExternally.toString() +
                          "%"),
                    ),
                  ],
                ),
                Container(
                  margin: EdgeInsets.only(left: 80, top: 20, bottom: 10),
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      FlatButton(
                        child: Text("Изменить расписание"),
                        color: Colors.blue,
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                List<bool> timeTableBool = new List<bool>();
                                for (int i = 0;
                                    i < feeders[index].timeTable.length;
                                    i++) {
                                  if (feeders[index].timeTable[i] == "1") {
                                    timeTableBool.add(true);
                                  } else {
                                    timeTableBool.add(false);
                                  }
                                }
                                return AlertDialog(
                                  title: Text("Изменить расписание"),
                                  content: StatefulBuilder(
                                    builder: (BuildContext context,
                                        StateSetter setState) {
                                      return ToggleButtons(
                                        isSelected: timeTableBool,
                                        onPressed: (int _index) {
                                          setState(() {
                                            timeTableBool[_index] =
                                                !timeTableBool[_index];
                                            if (feeders[index]
                                                    .timeTable[_index] ==
                                                "1") {
                                              feeders[index].timeTable[_index] =
                                                  "0";
                                            } else {
                                              feeders[index].timeTable[_index] =
                                                  "1";
                                            }
                                          });
                                        },
                                        children: [
                                          Text("00:00"),
                                          Text("03:00"),
                                          Text("06:00"),
                                          Text("09:00"),
                                          Text("12:00"),
                                          Text("15:00"),
                                          Text("18:00"),
                                          Text("21:00"),
                                        ],
                                      );
                                    },
                                  ),
                                  actions: [
                                    new FlatButton(
                                      child: Text("Изменить"),
                                      onPressed: () {
                                        print(timeTableBool);
                                        HttpClientFeed.changeFeeder(
                                            Feeder.timeTableChange(
                                                feeders[index], timeTableBool),
                                            userId);
                                      },
                                    )
                                  ],
                                );
                              });
                        },
                      )
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 80, top: 15, bottom: 30),
                  alignment: Alignment.center,
                  child: FlatButton(
                    child: Text("Просмотреть лог"),
                    color: Colors.blue,
                    onPressed: () {
                      List<Log> logs;
                      HttpClientFeed.getFeederLog(
                              userId, feeders[index].feederId)
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          child: FlatButton(
                                            child: Text("Export"),
                                            color: Colors.blue,
                                            textColor: Colors.white,
                                            onPressed: () {
                                              HttpClientFeed.downloadLogs(
                                                  userId,
                                                  feeders[index].feederId);
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                        ),
                                        Container(
                                          margin: EdgeInsets.only(
                                              right: 20, left: 20),
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
                  margin:
                      EdgeInsets.only(left: 80, top: 20, bottom: 10, right: 30),
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      Text("Добавить корм"),
                      FlatButton(
                        child: Text("+"),
                        color: Colors.blue,
                        onPressed: () {
                          String time;
                          if (feeders[index].feederType == "normal") {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text("Добавить корм?"),
                                    actions: [
                                      new FlatButton(
                                        child: Text("Добавить"),
                                        onPressed: () {
                                          print(time);
                                          //add food
                                          HttpClientFeed.addFood(
                                                  feeders[index].feederId,
                                                  feeders[index].userId,
                                                  "5")
                                              .then((value) => feeders = value)
                                              .whenComplete(() => refresh());
                                          Navigator.of(context).pop();
                                        },
                                      )
                                    ],
                                  );
                                });
                          } else {
                            TextEditingController _c =
                                new TextEditingController();
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text("Добавить корм"),
                                    content: TextField(
                                      controller: _c,
                                      textInputAction: TextInputAction.go,
                                      decoration: InputDecoration(
                                          hintText: "Введите число секунд"),
                                    ),
                                    actions: [
                                      new FlatButton(
                                          child: Text("Добавить"),
                                          onPressed: () {
                                            time = _c.text;
                                            HttpClientFeed.addFood(
                                                    feeders[index].feederId,
                                                    feeders[index].userId,
                                                    time)
                                                .then(
                                                    (value) => feeders = value)
                                                .whenComplete(() => refresh());
                                            Navigator.of(context).pop();
                                          })
                                    ],
                                  );
                                });
                          }
                        },
                      )
                    ],
                  ),
                ),
              ],
            ),
          );
        });
  }
}

List<Widget> showToggle(List<String> labels) {
  List<Widget> showLabels = new List<Widget>();
  for (int i = 0; i < labels.length; i++) {
    showLabels.add(Text(labels[i]));
  }
  return showLabels;
}
