import 'dart:async';
import 'package:flutter/material.dart';
import '../widgets/drawer.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:location/location.dart';
import 'package:weather/weather.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'package:simple_moment/simple_moment.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:f_nav/pages/secondPage.dart';

class MapsPage extends StatelessWidget {
  static const String routeName = '/map';

  final title = "test";
  final description = " test";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(
        title: Text("Homepage"),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.notification_important), onPressed: ()
          {
            print("change list shown in view");
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => SecondPage(
                        title: title, description: description)));
          }
          ),
        ],
      ),
      body: new MapSample(),
    );
  }

}

class MapSample extends StatefulWidget {
  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  WeatherStation weatherStation = new WeatherStation(
      "34cd503973bce95c2e833573eb0d9561");


  static const LatLng _center = const LatLng(45.521563, -122.677433);
  LatLng _lastMapPosition = _center;
  MapType _currentMapType = MapType.normal;
  Set<Marker> markers = Set();
  Position position;
  Firestore _firestore = Firestore.instance;
  Location location = Location();
  Map<String, double> currentLocation;
  Completer<GoogleMapController> _controller = Completer();
  Widget _map;

  List<Placemark> placemark;
  String _address;
  String inputaddr = '';

//   run function on loop

//  gets current location of camera
  void _onCameraMove(CameraPosition position) {
    _lastMapPosition = position.target;
  }

  Size screenSize(BuildContext context) {
    return MediaQuery.of(context).size;
  }
  double screenHeight(BuildContext context, {double dividedBy = 1}) {
    return screenSize(context).height / dividedBy;
  }
  double screenWidth(BuildContext context, {double dividedBy = 1}) {
    return screenSize(context).width / dividedBy;
  }

  @override
  void initState() {
    _map = SpinKitPouringHourglass(
      color: Colors.yellow, size: 250, duration: new Duration(seconds: 1),);

    getCurrentLocation();
    populateMap_w_Markers();
    super.initState();
  }

  void re_InitilizeMap() {
    getCurrentLocation();
    populateMap_w_Markers();
    super.initState();
  }

  @override
  void dispose() {
    markers.clear();
    super.dispose();
  }

  _onMapTypeButtonPressed() {
    setState(() {
      _currentMapType = _currentMapType == MapType.normal
          ? MapType.satellite
          : MapType.normal;
    });
  }


  Widget mapWidget() {
    return GoogleMap(


      myLocationButtonEnabled: false,
      onCameraMove: _onCameraMove,

      myLocationEnabled: true,

      compassEnabled: true,
      mapToolbarEnabled: false,

      rotateGesturesEnabled: false,
      markers: markers,
      mapType: _currentMapType,
      initialCameraPosition: CameraPosition(
          target: LatLng(_lat, _lng), zoom: 10),
      onMapCreated:
          (GoogleMapController controller) {
        _controller.complete(controller);
        re_InitilizeMap();
      },
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
    await getAddress(_lat, _lng);
  }

  void getCamera_on_Location() async {
    Position res = await Geolocator().getCurrentPosition();
    setState(() {
      position = res;
      CameraPosition(target: LatLng(position.latitude, position.longitude));
    });
  }

  void getCamera_on_Marker(location)  async {
    final GoogleMapController controller = await _controller.future;

    controller.animateCamera(
        CameraUpdate.newCameraPosition(CameraPosition(target: LatLng(location.latitude, location.longitude), zoom: 8.0,)
        ),


    );
  }

  populateMap_w_Markers() {
    print("loading markers...");

    Firestore.instance.collection('test').getDocuments().then((docs) {
      if (docs.documents.isNotEmpty) {
        for (int i = 0; i < docs.documents.length; i++) {
          print('created a marker');
          initMarker(docs.documents[i].data, docs.documents[i].documentID);
        }
      }
    });
  }

  void getAddress(double latitude, double longitude) async {
    placemark =
    await Geolocator().placemarkFromCoordinates(latitude, longitude);
    _address =
        placemark[0].name.toString() + "," + placemark[0].locality.toString() +
            ", Postal Code:" + placemark[0].postalCode.toString();
    setState(() {
      _map = mapWidget();
    });
  }

  void initMarker(request, requestId) async {
    var markerIdVal = requestId;
    final MarkerId markerId = MarkerId(markerIdVal);

    final Marker marker = Marker(
      markerId: markerId,
      position: LatLng(
          request['location'].latitude, request['location'].longitude),
      icon: BitmapDescriptor.defaultMarker,
      infoWindow: InfoWindow(
          title: 'Test title', snippet: 'Message: ' + request['address']),
    );

    await setState(() {
      markers.add(marker);
    });
  }




  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: Column(children: <Widget>[
        Text("Marker list: "),
        Container(
          child: SizedBox(
            height: screenHeight(context, dividedBy: 4),
            width: screenWidth(context, dividedBy: 1.1),
            child:
            StreamBuilder<QuerySnapshot>(
              stream: Firestore.instance.collection('test')
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError)
                  return new Text('Error: ${snapshot.error}');
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return new Text('Loading...');
                  default:
                    return new ListView(
                      scrollDirection: Axis.horizontal,
                      children: snapshot.data.documents
                          .map((DocumentSnapshot document) {
//                        return new CustomCard(
//                          title: document['address'],
//                          description: document['address'],
//                          location: document['location'],
//
//                        );
                      return Card(
                          child: Container(
                              padding: const EdgeInsets.only(top: 1.0),
                              child: Column(
                                children: <Widget>[
                                  Text(document['address']),
                                  Text(document['address']),
                                  Icon(Icons.pin_drop),
                                  FlatButton(
                                      child: Text(document['address']),

                                      onPressed: ()
                                      {
                                    getCamera_on_Marker(document['location']);

//                                        Navigator.push(
//                                            context,
//                                            MaterialPageRoute(
//                                                builder: (context) => SecondPage(
//                                                    title: document['address'], description: document['address'])));
                                      }
                                  ),
                                ],
                              )));
                      }).toList(),
                    );
                }
              },
            ),
          ),
        ),
        Container(
          child: SizedBox(
        height: screenHeight(context,
            dividedBy: 2),
        child:_map,
        ),),

//        Expanded(
//
//          child: ListView(
//            children:_buildContainer(),
//          ),
//        )

      ]
      ), //map
      floatingActionButton: _getMapButtons(), //buttons
    );
  }


  String user_uid, user_display_name;

  /// Post to Firebase DB
  addToList(lat, long) async {
    if(lat == null || long == null ){
      print("what!?");
    }
    else {
      Firestore.instance.collection('test').add({
        'location': new GeoPoint(lat, long),
        'address': inputaddr,
      });
    }
  }


//  create marker
  Future addMarker(lat, long) async {
      await showDialog(
          context: context,
          barrierDismissible: true,
          builder: (BuildContext context) {
            return new SimpleDialog(
              title: new Text(
                'Add Marker',
                style: new TextStyle(fontSize: 17.0),
              ),
              children: <Widget>[
                new TextField(
                  decoration: InputDecoration(
                    hintText: 'Write marker information',
                    border: InputBorder.none,
                  ),


                  onChanged: (String enteredLoc) {
                    setState(() {
                      inputaddr = enteredLoc;
                    });
                  },
                ),

                new SimpleDialogOption(
                  child: new Text('Add Marker',
                      style: new TextStyle(color: Colors.amberAccent)),
                  onPressed: () {
                    addToList(lat, long);


                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          });
    re_InitilizeMap();

}

  Future<void> _goToUser() async {

    final GoogleMapController controller = await _controller.future;

    controller.animateCamera(
        CameraUpdate.newCameraPosition(CameraPosition(target: LatLng(position.latitude, position.longitude), zoom: 15.0,)
        )
    );
  }

  Widget _getMapButtons() {
    return SpeedDial(
      animatedIcon: AnimatedIcons.menu_close,
      animatedIconTheme: IconThemeData(size: 22),
      backgroundColor: Colors.amberAccent,
      visible: true,
      curve: Curves.bounceIn,
      children:
      [

        SpeedDialChild(
            child: Icon(Icons.my_location),
            backgroundColor: Colors.amberAccent,
            onTap: () { _goToUser(); },
            label: 'Move camera to location',
            labelStyle: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.white,
                fontSize: 16.0),
            labelBackgroundColor: Colors.amberAccent),

        SpeedDialChild(
            child: Icon(Icons.refresh),
            backgroundColor: Colors.amberAccent,
            onTap: () { re_InitilizeMap(); },
            label: 'Refresh Map',
            labelStyle: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.white,
                fontSize: 16.0),
            labelBackgroundColor: Colors.amberAccent),

        SpeedDialChild(


            child: Icon(Icons.pin_drop),
            backgroundColor: Colors.amberAccent,
            onTap: () {
              if(_lastMapPosition.latitude == null){
                print("damn");
              }
              else
              addMarker(_lastMapPosition.latitude,_lastMapPosition.longitude);

              },
            label: 'Drop pin',
            labelStyle: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.white,
                fontSize: 16.0),
            labelBackgroundColor: Colors.amberAccent),
      ],
    );
  }


}
