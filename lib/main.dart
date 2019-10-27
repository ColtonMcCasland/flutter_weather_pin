//import 'package:flutter/material.dart';
//
//import 'grid_list.dart';
//import 'horizontal.dart';
//import 'multi_item_list.dart';
//
//void main() => runApp(new MaterialApp(home: MyApp()));
//
//class MyApp extends StatelessWidget {
//  @override
//  Widget build(BuildContext context) {
//    final title = 'Lists';
//
//    return  new Scaffold(
//        appBar: new AppBar(
//          title: new Text(title),
//        ),
//        body: new Container(
//          margin: new EdgeInsets.symmetric(vertical: 20.0),
//          height: 200.0,
//          child: new Column(
//
////            children: <Widget>[
////              new OutlineButton(
////                child: const Text('Horizontal List'),
////                onPressed: ()=>Navigator.push(context, new MaterialPageRoute(builder: (context)=>new HorizontalApp())),
////              ),
////              new OutlineButton(
////                child: const Text('Grid List'),
////                onPressed: ()=>Navigator.push(context, new MaterialPageRoute(builder: (context)=>new GridList())),
////              ),
////              new OutlineButton(
////                child: const Text('Multi Item List'),
////                onPressed: ()=>Navigator.push(context,
////                new MaterialPageRoute(builder: (context)=>new MultiItemList())),
////              )
////            ],
//
//
//
//          ),
//        ),
//    );
//  }
//}

import 'dart:async';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';

void main() => runApp(MyApp());

bool hideRecents = false;

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text("open Weather Pin app")),
        body: markerListWidget(),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            // Add your onPressed code here!
          },
          label: Text('Open Map'),
          icon: Icon(Icons.map),
          backgroundColor: Colors.pink,
        ),
      ),
    );
  }
}

class UrlObject {
  final String url;

  UrlObject(this.url);
}

Stream<UrlObject> generate(int num, Duration timeout) async* {
  int seed = Random().nextInt(200);
  for (int i = 0; i < num; ++i) {
    await Future.delayed(timeout);
    yield UrlObject("https://loremflickr.com/640/480/flower?random=$i$seed");
  }
}

class markerListWidget extends StatefulWidget {
  @override
  _markerListWidgetState createState() => _markerListWidgetState();
}

class _markerListWidgetState extends State<markerListWidget> {
  Stream<UrlObject> recentMarkerStream;
  Stream<UrlObject> markerStream;

  final auth = FirebaseAuth.instance;
//  final db = DatabaseService(); //database file

//  Stream<UrlObject> stream3;

  @override
  void initState() {
    recentMarkerStream = generate(10, Duration(seconds: 1, milliseconds: 500));
    markerStream = generate(20, Duration(seconds: 1));
//    stream3 = generate(30, Duration(seconds: 2));
  }

  @override
  Widget build(BuildContext context) {

    if(hideRecents == false)
    {
      return ListView(
        scrollDirection: Axis.vertical,
        children: [
          StreamedItemHolder(stream: recentMarkerStream, builder: (context, list) => MarkerList(objects: list)),
          StreamedItemHolder(stream: markerStream, builder: (context, list) => MarkerList(objects: list)),
//          StreamedItemHolder(stream: stream3, builder: (context, list) => MarkerList(objects: list)),
        ],
      );
    }
    else
      {
        StreamedItemHolder(stream: recentMarkerStream, builder: (context, list) => MarkerList(objects: list));
      }
  }
}

typedef Widget UrlObjectListBuilder(BuildContext context, List<UrlObject> objects);

class StreamedItemHolder extends StatefulWidget {
  final UrlObjectListBuilder builder;
  final Stream<UrlObject> stream;

  const StreamedItemHolder({Key key, @required this.builder, @required this.stream}) : super(key: key);

  @override
  StreamedItemHolderState createState() => new StreamedItemHolderState();
}

class StreamedItemHolderState extends State<StreamedItemHolder> {
  List<UrlObject> items = [];

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      builder: (context, snapshot) {
        if (snapshot.hasData) items.add(snapshot.data);
        return widget.builder(context, items);
      },
      stream: widget.stream,
    );

  }
}

class MarkerList extends StatelessWidget {
  final List<UrlObject> objects;

  const MarkerList({Key key, this.objects}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20.0),
      height: 250.0,

      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: objects.length,
        itemBuilder: (context, index) {
          return new GestureDetector(
            onTap: null,
            child: Image.network(
              objects[index].url,
              fit: BoxFit.cover,

            ),
          );
        },
      ),
    );
  }
}