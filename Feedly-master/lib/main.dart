import 'package:flutter/material.dart';
import 'package:flutter_feedly/pages/login.dart';
import 'package:flutter_feedly/pages/login.dart';
import 'package:flutter_feedly/pages/map.dart';
import 'package:flutter_feedly/pages/feed.dart';

import 'package:flutter_feedly/screens/account.dart';
import 'package:flutter_feedly/screens/settings.dart';




void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(

          primarySwatch: Colors.blueGrey,
          backgroundColor: Colors.white
      ),
      home: LoginPage(),
      routes: <String, WidgetBuilder>{

        // define the routes
        SettingsScreen.routeName: (BuildContext context) => SettingsScreen(),

        AccountScreen.routeName: (BuildContext context) => AccountScreen(),

        FeedPage.routeName: (BuildContext context) => FeedPage(),

//        FireMap.routeName:(BuildContext context) => FireMap(),

      },
    );
  }
}