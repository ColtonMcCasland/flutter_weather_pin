import 'package:flutter/material.dart';
import 'package:f_nav/pages/feed.dart';
import 'package:f_nav/screens/account.dart';
import 'package:f_nav/screens/settings.dart';
//import 'package:firebase_auth/firebase_auth.dart';

import 'package:f_nav/pages/map.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'dart:async';


class HomeScreen extends StatefulWidget {
  HomeScreen({Key key}) : super(key: key);

  @override
  HomeScreenState createState() => HomeScreenState();
}






class HomeScreenState extends State<HomeScreen> {


  @override
  void initState() {
    super.initState();
  }



  Completer _controller = Completer();

//  Location currentLocation = new Location();
//  currentLocation;

  Drawer getNavDrawer(BuildContext context) {
    var headerChild = DrawerHeader(child: Text("Header"));
    var aboutChild = AboutListTile(
        child: Text("About"),
        applicationName: "Weather Pin",
        applicationVersion: "v1.0.0",
        applicationIcon: Icon(Icons.adb),
        icon: Icon(Icons.info));

    ListTile getNavItem(var icon, String s, String routeName) {
      return ListTile(
        leading: Icon(icon),
        title: Text(s),
        onTap: () {
          setState(() {
            // pop closes the drawer
            Navigator.of(context).pop();
            // navigate to the route
            Navigator.of(context).pushNamed(routeName);
          });
        },
      );
    }

    var myNavChildren = [
      headerChild,
      getNavItem(Icons.settings, "Settings", SettingsScreen.routeName),
      getNavItem(Icons.home, "Home", "/"),
      getNavItem(Icons.account_box, "Account", AccountScreen.routeName),
      getNavItem(Icons.new_releases, "News Feed", FeedPage.routeName),
      getNavItem(Icons.map, "Map", FireMap.routeName),


      aboutChild
    ];

    ListView listView = ListView(children: myNavChildren);

    return Drawer(
      child: listView,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey,
      appBar: AppBar(
        elevation: 0.0,

        title: Text("Map Page"),
      ),
      body: ClipRRect(
          borderRadius: new BorderRadius.only(
              topLeft: const Radius.circular(40.0),
              topRight: const Radius.circular(40.0)),
          child: Center(
            child: Text("This page is WIP,"
                " \nNot sure what functionality to make the first page. "
                " \nNavigation bar widget shows other pages available."),


          )),
//      floatingActionButton: Column(
//        mainAxisSize: MainAxisSize.min,
//        children: <Widget>[
//          FloatingActionButton(
//            heroTag: null,
//            onPressed: () {
////              updateGoogleMapCameraView();
//            },
//            materialTapTargetSize: MaterialTapTargetSize.padded,
//            backgroundColor: Colors.green,
//            child: const Icon(Icons.center_focus_weak, size: 36.0),
//          ),
//          SizedBox(
//            height: 16.0,
//          ),
//          FloatingActionButton(
//            heroTag: null,
//            onPressed: () {},
//            materialTapTargetSize: MaterialTapTargetSize.padded,
//            backgroundColor: Colors.green,
//            child: const Icon(Icons.add_location, size: 36.0),
//          ),
//        ],
//      ),
      // Set the nav drawer
      drawer: getNavDrawer(context),
    );
  }









}


