import 'package:flutter/material.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire/src/point.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rxdart/rxdart.dart';
import 'package:location/location.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import 'package:flutter_feedly/screens/home.dart';

import 'package:flutter_feedly/streambuilder_test.dart';

///----------------------------------------
// Documentation on geo markers query from firestore
// https://libraries.io/pub/geoflutterfire
///----------------------------------------


class FireMap extends StatefulWidget {
  static const String routeName = "/fireMap";

  @override
  FireMapState createState() => FireMapState();
}


class FireMapState extends State<FireMap> {
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

  GoogleMapController _controller;
  bool dialVisible = true;

  Position position;
  Widget _child;




  @override
  void initState() {
    _child=SpinKitRotatingCircle(color: Colors.white, size: 50.0, );
    getCurrentLocation();
    populateClients();
    super.initState();

  }

  void setDialVisible(bool value) {
    setState(() {
      dialVisible = value;
    });
  }

  SpeedDial buildSpeedDial() {
    return SpeedDial(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      animatedIcon: AnimatedIcons.menu_close,
      animatedIconTheme: IconThemeData(size: 22.0),
      // child: Icon(Icons.add),
      onOpen: () => print('OPENING DIAL'),
      onClose: () => print('DIAL CLOSED'),
      visible: dialVisible,
      curve: Curves.bounceIn,
      children: [
        SpeedDialChild(
          child: Icon(Icons.accessibility, color: Colors.white),
          backgroundColor: Colors.deepOrange,
          onTap: () => print('FIRST CHILD'),
          label: 'First Child',
          labelStyle: TextStyle(fontWeight: FontWeight.w500),
          labelBackgroundColor: Colors.deepOrangeAccent,
        ),
        SpeedDialChild(
          child: Icon(Icons.brush, color: Colors.white),
          backgroundColor: Colors.green,
          onTap: () => print('SECOND CHILD'),
          label: 'Second Child',
          labelStyle: TextStyle(fontWeight: FontWeight.w500),
          labelBackgroundColor: Colors.green,
        ),
        SpeedDialChild(
          child: Icon(Icons.keyboard_voice, color: Colors.white),
          backgroundColor: Colors.blue,
          onTap: () => print('THIRD CHILD'),
          labelWidget: Container(
            color: Colors.blue,
            margin: EdgeInsets.only(right: 10),
            padding: EdgeInsets.all(6),
            child: Text('Custom Label Widget'),
          ),
        ),
      ],
    );
  }

  double _lat, _lng;
  void getCurrentLocation() async {
    Position res = await Geolocator().getCurrentPosition();
    setState(() {
      position = res;
      _lat = position.latitude;
      _lng = position.longitude;
    });
    await getAddress(_lat,_lng);
  }



  @override
  void dispose() {
    super.dispose();
  }

//  @override
//  Widget build(BuildContext context) {
//    return Scaffold(
//      appBar: AppBar(title: Text('test'),),
//      body: Container(
//          child: Column(
//              crossAxisAlignment: CrossAxisAlignment.center,
//              children: <Widget>[
//                Center(
//                  child: Card(
//
//                    elevation: 4,
//                    margin: EdgeInsets.symmetric(vertical: 8),
//                    child: SizedBox(
//                      width: MediaQuery.of(context).size.width - 30,
//                      height: MediaQuery.of(context).size.height * (3 / 5),
//                      child: _child,
//                    ),
//                    ),
//                  ),
//
//              ]),
//
//      ),
//
//    );
//  }

  @override
  Widget build(BuildContext context) {
//    show both lists

    return Scaffold(
      backgroundColor: Colors.blueGrey,
      appBar: AppBar(
        elevation: 0.0,
        title: Text("Posts page"),),
      body: ClipRRect(
        borderRadius: new BorderRadius.only(
          topLeft: const Radius.circular(40.0),
          topRight: const Radius.circular(40.0),



        ),

        child:
        Column( // parent ListView
          children: <Widget>[

            Container(
              height: 500, // give it a fixed height constraint
              color: Colors.white,
              // child ListView

              child: _child,
            ),



          ],

        ),

      ),
      floatingActionButton: buildSpeedDial(),

    );
  }

  Widget mapWidget(){
return GoogleMap(
    mapType: MapType.normal,
    markers:
    Set<Marker>.of(markers.values),
    initialCameraPosition: CameraPosition(
    target: LatLng(position.latitude, position.longitude),
    zoom: 16.0,
    ),
    onMapCreated: (GoogleMapController controller) {
    _controller = controller;

      },

//    onTap: ,



    );
  }



  List<Placemark> placemark;
  String _address;
  void getAddress(double latitude, double longitude) async {
    placemark = await Geolocator().placemarkFromCoordinates(latitude, longitude);
    _address = placemark[0].name.toString() + "," + placemark[0].locality.toString() + ", Postal Code:" + placemark[0].postalCode.toString();
    setState(() {

      _child = mapWidget();

    });
  }

  Set<Marker> _createMarker( ) {
    return <Marker>[
      Marker(
        markerId: MarkerId("home"),
        position: LatLng(position.latitude,position.longitude),
        icon: BitmapDescriptor.defaultMarker,
        infoWindow: InfoWindow(title:"Home", snippet: position.latitude.toString() + ' ' + position.longitude.toString()),
      ),
    ].toSet();
  }

  void initMarker(request, requestId) {
    print('test print: ');

    print(request['location'].latitude);
    print(request['location'].longitude);

    var markerIdVal = requestId;
    final MarkerId markerId = MarkerId(markerIdVal);

    final Marker marker = Marker(
      markerId: markerId,
      position:
            LatLng(request['location'].latitude,request['location'].longitude),
      icon:
            BitmapDescriptor.defaultMarker,
      infoWindow:
            InfoWindow(title: "Fetched Markers", snippet: request['address']),
    );

    setState(() {
      markers[markerId] = marker;
      print(markerId);
    });
  }

  populateClients() {
    print('poplulating...');
    Firestore.instance.collection('test').getDocuments().then((docs) {
      if ( docs.documents.isNotEmpty) {
        for(int i = 0; i < docs.documents.length; i++){
          print('created marker');
          initMarker(docs.documents[i].data, docs.documents[i].documentID);
        }
      }
    });
  }



}
