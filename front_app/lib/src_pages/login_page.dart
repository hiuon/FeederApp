import 'package:flutter/material.dart';
import 'package:front_app/src_pages/admin_page.dart';
import 'package:front_app/src_pages/user_page.dart';
import '../Entities/UserLogin.dart';
import '../Service/http_service.dart';

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
    //_UserListViewState();
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
  Future<List<UserLogin>> _body;

  @override
  void initState() {
    super.initState();
    _body = HttpClientFeed.getUserLogin();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _body,
        builder: (context, snapshot) {
          if (snapshot.hasData == null) {
            return Container();
          }
          return ListView.builder(
            scrollDirection: Axis.vertical,
            itemCount: snapshot.data.length,
            itemBuilder: (context, index) {
              if (snapshot.data.length == null) {
                return Container();
              } else
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
                        child: Text(snapshot.data[index].name), //userName
                        onPressed: () {
                          Navigator.push(
                            context,
                            new MaterialPageRoute(
                                builder: (context) => new UserPage(
                                      userId: snapshot.data[index].id,
                                      name: snapshot.data[index].name,
                                    )),
                          );
                        },
                      ),
                    ],
                  ),
                );
            },
          );
        });
  }
}
