import 'package:f_nav/pages/feed.dart';
import 'package:f_nav/pages/login.dart';
import 'package:f_nav/pages/weatherpage.dart';
import 'package:flutter/material.dart';
import 'routes/Routes.dart';
import 'pages/chartspage.dart';
import 'pages/homepage.dart';
import 'pages/timelinepage.dart';
import 'pages/mapspage.dart';
import 'pages/calendarpage.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  final appTitle = 'Drawer Demo';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: appTitle,
      theme : ThemeData(
        // Define the default brightness and colors.
        brightness: Brightness.dark,
        primaryColor: Colors.amber,
        accentColor: Colors.amberAccent,

        // Define the default font family.
        fontFamily: 'Montserrat',

        // Define the default TextTheme. Use this to specify the default
        // text styling for headlines, titles, bodies of text, and more.
        textTheme: TextTheme(
          headline: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
          title: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic),
          body1: TextStyle(fontSize: 14.0, fontFamily: 'Hind'),
        ),
      ),
      home: LoginPage(),
      routes: {
        Routes.home: (context) => HomePage(),
        Routes.charts: (context) => ChartsPage.withSampleData(),
        Routes.timeline: (context) => TimelinePage(),

        Routes.map: (context) => MapsPage(),
        Routes.weather: (context) => weatherPage(),

        Routes.calendar: (context) => CalendarPage(),
        Routes.logout: (context) => LoginPage(),
        Routes.feed: (context) => FeedPage(),


      },
    );
  }
}
