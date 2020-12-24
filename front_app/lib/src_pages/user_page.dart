import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
  List<Feeder> feeders;
  int userId;
  String url = "localhost:5000";

  _FeederListViewState(int userId) {
    //show feeders
    http.get("http://localhost:5000/users/?userId=$userId").then((response) {
      var data = json.decode(response.body);
      print(response.body);
      var rest = data["feeders"] as List;
      feeders = new List<Feeder>();
      feeders = rest.map<Feeder>((json) => Feeder.fromJson(json)).toList();
      this.userId = userId;
      print(feeders);

      for (int i = 0; i < feeders.length; i++) {
        feeders[i].userId = userId;
        print(feeders[i].labels);
        if (feeders[i].labels[0] != '') {
          feeders[i].stateLabels = new List<bool>(feeders[i].labels.length);
          print(feeders[i].labels.length);
          for (int j = 0; j < feeders[i].labels.length; j++) {
            /*if (feeders[i].stateLabels_[j] == "false") {
              feeders[i].stateLabels.add(false);
            } else {
              feeders[i].stateLabels.add(true);
            }*/
            feeders[i].stateLabels[j] = false;
          }
          print("state" + feeders[i].stateLabels.toString());
        } else {
          feeders[i].stateLabels = new List<bool>();
          //feeders[i].stateLabels_ = new List<String>();
          feeders[i].labels = new List<String>();
        }
        /*for (int j = 0; j < feeders[i].stateLabels_.length; j++) {
          if (feeders[i].stateLabels_[j] == "false") {
            feeders[i].stateLabels.add(false);
          } else {
            feeders[i].stateLabels.add(true);
          }
        }
        for (int j = 0; j < feeders[j].labels.length; i++) {
          feeders[i].stateLabels.add(false);
        }
        print(feeders[i].stateLabels);
      }*/
        print(feeders[i].stateLabels.length);
        print(feeders[i].labels.length);
      }

      setState(() {});
    });
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
                          isSelected: feeders[index].stateLabels,
                          onPressed: (int _index) {
                            setState(() {
                              feeders[index].stateLabels[_index] =
                                  !feeders[index].stateLabels[_index];
                            });
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
                        StringBuffer newLabels = new StringBuffer();
                        //StringBuffer newLabelsState = new StringBuffer();
                        //newLabels.writeAll(feeders[index].labels, "; ");
                        if (feeders[index].labels.isEmpty != true) {
                          for (int i = 0;
                              i < feeders[index].labels.length - 1;
                              i++) {
                            if (i == feeders[index].labels.length - 2) {
                              newLabels.write(feeders[index].labels[i]);
                              //newLabelsState
                              //.write(feeders[index].stateLabels_[i]);
                            } else {
                              newLabels.write(feeders[index].labels[i] + "__");
                              //newLabelsState
                              // .write(feeders[index].stateLabels_[i] + "__");
                            }
                          }
                        }
                        if (newLabels.toString() == "__") {
                          newLabels = new StringBuffer();
                          //newLabelsState = new StringBuffer();
                        }
                        String post_data = "feederId=" +
                            feeders[index].feederId.toString() +
                            "&userId=" +
                            userId.toString() +
                            "&labels=" +
                            newLabels.toString() +
                            //"&labelsState=" +
                            //newLabelsState.toString() +
                            "&feederType=" +
                            feeders[index].feederType +
                            "&timeTable=" +
                            "no" +
                            "&capacity=100" +
                            "&filledInternally=" +
                            feeders[index].filledInernally.toString() +
                            "&filledExternally=" +
                            feeders[index].filledExternally.toString();
                        http
                            .post("http://localhost:5000/feeders/?$post_data")
                            .then((response) {});

                        http
                            .get("http://localhost:5000/users/?userId=$userId")
                            .then((response) {
                          var data = json.decode(response.body);
                          print(response.body);
                          var rest = data["feeders"] as List;
                          feeders = new List<Feeder>();
                          feeders = rest
                              .map<Feeder>((json) => Feeder.fromJson(json))
                              .toList();
                          print(feeders[0].stateLabels);
                          for (int i = 0; i < feeders.length; i++) {
                            feeders[i].userId = userId;
                            print(feeders[i].labels);
                            if (feeders[i].labels[0] != '') {
                              feeders[i].stateLabels =
                                  new List<bool>(feeders[i].labels.length);
                              print(feeders[i].labels.length);
                              for (int j = 0;
                                  j < feeders[i].labels.length;
                                  j++) {
                                feeders[i].stateLabels[j] = false;
                                /*if (feeders[i].stateLabels_[j] == "false") {
                                  feeders[i].stateLabels.add(false);
                                } else {
                                  feeders[i].stateLabels.add(true);
                                }*/

                              }
                              print(
                                  "state" + feeders[i].stateLabels.toString());
                            } else {
                              feeders[i].stateLabels = new List<bool>();
                              feeders[i].labels = new List<String>();
                              //feeders[i].stateLabels_ = new List<String>();
                            }
                            /*for (int j = 0; j < feeders[i].stateLabels_.length; j++) {
          if (feeders[i].stateLabels_[j] == "false") {
            feeders[i].stateLabels.add(false);
          } else {
            feeders[i].stateLabels.add(true);
          }
        }
        for (int j = 0; j < feeders[j].labels.length; i++) {
          feeders[i].stateLabels.add(false);
        }
        print(feeders[i].stateLabels);
      }*/
                          }
                          setState(() {});
                        });
                      },
                      onPressed: () {
                        TextEditingController _c = new TextEditingController();
                        String label;
                        //if (feeders[index].labels[0] == '') {
                        //  feeders[index].labels = new List<String>();
                        //}
                        StringBuffer newLabels = new StringBuffer();
                        //newLabels.writeAll(feeders[index].labels, "; ");
                        if (feeders[index].labels.isEmpty != true) {
                          for (int i = 0;
                              i < feeders[index].labels.length;
                              i++) {
                            newLabels.write(feeders[index].labels[i] + "__");
                          }
                        }
                        print(newLabels);
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
                                      print(label);
                                      print(index);
                                      print("/" +
                                          feeders[index].feederType +
                                          "/");
                                      //add label

                                      newLabels.write(label);
                                      String post_data = "feederId=" +
                                          feeders[index].feederId.toString() +
                                          "&userId=" +
                                          userId.toString() +
                                          "&labels=" +
                                          newLabels.toString() +
                                          "&feederType=" +
                                          feeders[index].feederType +
                                          "&timeTable=" +
                                          "no" +
                                          "&capacity=100" +
                                          "&filledInternally=" +
                                          feeders[index]
                                              .filledInernally
                                              .toString() +
                                          "&filledExternally=" +
                                          feeders[index]
                                              .filledExternally
                                              .toString();
                                      print(post_data);
                                      http
                                          .post(
                                              "http://localhost:5000/feeders/?$post_data")
                                          .then((response) {});
                                      Navigator.of(context).pop();
                                      http
                                          .get(
                                              "http://localhost:5000/users/?userId=$userId")
                                          .then((response) {
                                        var data = json.decode(response.body);
                                        print(response.body);
                                        var rest = data["feeders"] as List;
                                        feeders = new List<Feeder>();
                                        feeders = rest
                                            .map<Feeder>(
                                                (json) => Feeder.fromJson(json))
                                            .toList();
                                        print(feeders[0].stateLabels);
                                        for (int i = 0;
                                            i < feeders.length;
                                            i++) {
                                          feeders[i].userId = userId;
                                          print(feeders[i].labels);
                                          if (feeders[i].labels[0] != '') {
                                            feeders[i].stateLabels =
                                                new List<bool>(
                                                    feeders[i].labels.length);
                                            print(feeders[i].labels.length);
                                            for (int j = 0;
                                                j < feeders[i].labels.length;
                                                j++) {
                                              feeders[i].stateLabels[j] = false;
                                            }
                                            print("state" +
                                                feeders[i]
                                                    .stateLabels
                                                    .toString());
                                          } else {
                                            feeders[i].stateLabels =
                                                new List<bool>();
                                            //feeders[i].stateLabels_ = new List<String>();
                                            feeders[i].labels =
                                                new List<String>();
                                          }
                                          /*for (int j = 0; j < feeders[i].stateLabels_.length; j++) {
          if (feeders[i].stateLabels_[j] == "false") {
            feeders[i].stateLabels.add(false);
          } else {
            feeders[i].stateLabels.add(true);
          }
        }
        for (int j = 0; j < feeders[j].labels.length; i++) {
          feeders[i].stateLabels.add(false);
        }
        print(feeders[i].stateLabels);
      }*/
                                        }
                                        setState(() {});
                                      });
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
                      Text(feeders[index].timeTable),
                      FlatButton(
                        child: Text("Изменить расписание"),
                        color: Colors.blue,
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                List<String> timeTable = [
                                  "0",
                                  "0",
                                  "1",
                                  "1",
                                  "0",
                                  "0",
                                  "1",
                                  "1"
                                ];
                                List<bool> timeTableBool = new List<bool>();
                                for (int i = 0; i < timeTable.length; i++) {
                                  if (timeTable[i] == "1") {
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
                                        timeTable = timeTableBool.toString()
                                            as List<String>;
                                        print(timeTable);
                                        http.post(
                                            "http://localhost:5000/users/?id=" +
                                                feeders[index]
                                                    .userId
                                                    .toString(),
                                            body: {
                                              'timeTable': timeTable
                                            }).then((response) {
                                          var data = json.decode(response.body);
                                          var rest = data["feeders"] as List;
                                          feeders = new List<Feeder>();
                                          feeders = rest
                                              .map<Feeder>((json) =>
                                                  Feeder.fromJson(json))
                                              .toList();
                                        });
                                        Navigator.of(context).pop();
                                        setState(() {});
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
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text("ЛОГ"),
                              content: Text(feeders[index].logs),
                            );
                          });
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

                                          http
                                              .post(
                                                  "http://localhost:5000/feeders/?feedingAmount=5&feederId=${feeders[index].feederId}&userId=$userId")
                                              .then((response) {});
                                          print("check id");
                                          print(userId);
                                          http
                                              .get(
                                                  "http://localhost:5000/users/?userId=$userId")
                                              .then(
                                            (response) {
                                              var data =
                                                  json.decode(response.body);
                                              print(response.body);
                                              var rest =
                                                  data["feeders"] as List;
                                              feeders = new List<Feeder>();
                                              feeders = rest
                                                  .map<Feeder>((json) =>
                                                      Feeder.fromJson(json))
                                                  .toList();
                                              print(feeders);
                                              print("labels :");
                                              print(feeders[0].labels);
                                              print(feeders[0].stateLabels);
                                              for (int i = 0;
                                                  i < feeders.length;
                                                  i++) {
                                                feeders[i].userId = userId;
                                                print(feeders[i].labels);
                                                if (feeders[i].labels[0] !=
                                                    '') {
                                                  feeders[i].stateLabels =
                                                      new List<bool>(feeders[i]
                                                          .labels
                                                          .length);
                                                  print(
                                                      feeders[i].labels.length);
                                                  for (int j = 0;
                                                      j <
                                                          feeders[i]
                                                              .labels
                                                              .length;
                                                      j++) {
                                                    feeders[i].stateLabels[j] =
                                                        false;
                                                  }
                                                  print("state" +
                                                      feeders[i]
                                                          .stateLabels
                                                          .toString());
                                                } else {
                                                  feeders[i].stateLabels =
                                                      new List<bool>();
                                                  //feeders[i].stateLabels_ = new List<String>();
                                                  feeders[i].labels =
                                                      new List<String>();
                                                }
                                                /*for (int j = 0; j < feeders[i].stateLabels_.length; j++) {
          if (feeders[i].stateLabels_[j] == "false") {
            feeders[i].stateLabels.add(false);
          } else {
            feeders[i].stateLabels.add(true);
          }
        }
        for (int j = 0; j < feeders[j].labels.length; i++) {
          feeders[i].stateLabels.add(false);
        }
        print(feeders[i].stateLabels);
      }*/
                                              }
                                              setState(() {});
                                              Navigator.of(context).pop();
                                            },
                                          );
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
                                            print(userId);
                                            print(time);
                                            http
                                                .post(
                                                    "http://localhost:5000/feeders/?feedingAmount=$time&feederId=${feeders[index].feederId}&userId=$userId")
                                                .then((response) {});
                                            print("check id");
                                            print(userId);
                                            http
                                                .get(
                                                    "http://localhost:5000/users/?userId=$userId")
                                                .then(
                                              (response) {
                                                var data =
                                                    json.decode(response.body);
                                                print(response.body);
                                                var rest =
                                                    data["feeders"] as List;
                                                feeders = new List<Feeder>();
                                                feeders = rest
                                                    .map<Feeder>((json) =>
                                                        Feeder.fromJson(json))
                                                    .toList();
                                                print(feeders);
                                                print("labels :");
                                                print(feeders[0].labels);
                                                print(feeders[0].stateLabels);
                                                for (int i = 0;
                                                    i < feeders.length;
                                                    i++) {
                                                  feeders[i].userId = userId;
                                                  print(feeders[i].labels);
                                                  if (feeders[i].labels[0] !=
                                                      '') {
                                                    feeders[i].stateLabels =
                                                        new List<bool>(
                                                            feeders[i]
                                                                .labels
                                                                .length);
                                                    print(feeders[i]
                                                        .labels
                                                        .length);
                                                    for (int j = 0;
                                                        j <
                                                            feeders[i]
                                                                .labels
                                                                .length;
                                                        j++) {
                                                      feeders[i]
                                                              .stateLabels[j] =
                                                          false;
                                                    }
                                                    print("state" +
                                                        feeders[i]
                                                            .stateLabels
                                                            .toString());
                                                  } else {
                                                    feeders[i].stateLabels =
                                                        new List<bool>();
                                                    //feeders[i].stateLabels_ = new List<String>();
                                                    feeders[i].labels =
                                                        new List<String>();
                                                  }
                                                  /*for (int j = 0; j < feeders[i].stateLabels_.length; j++) {
          if (feeders[i].stateLabels_[j] == "false") {
            feeders[i].stateLabels.add(false);
          } else {
            feeders[i].stateLabels.add(true);
          }
        }
        for (int j = 0; j < feeders[j].labels.length; i++) {
          feeders[i].stateLabels.add(false);
        }
        print(feeders[i].stateLabels);
      }*/
                                                }
                                                setState(() {});
                                                Navigator.of(context).pop();
                                              },
                                            );
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
