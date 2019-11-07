import 'dart:async';
import 'package:flutter/material.dart';
import '../widgets/drawer.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:simple_moment/simple_moment.dart';
import 'package:location/location.dart';
import 'dart:async';



class MapsPage extends StatelessWidget {
  static const String routeName = '/map';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(
        title: Text("Map"),
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
  Map<MarkerId, Marker> markerList = <MarkerId, Marker>{};
  Position position;
  Firestore _firestore = Firestore.instance;

  Location location = Location();

  Map<String, double> currentLocation;


  Completer<GoogleMapController> _controller = Completer();

  Widget _map;

  List<Placemark> placemark;
  String _address;

  @override
  void initState() {

    _map=SpinKitPouringHourglass(color: Colors.white, size: 250, duration: new Duration(seconds: 3),);

    getCurrentLocation();
    populateMap_w_Markers();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }



  Widget mapWidget()
  {
    return GoogleMap(
      myLocationEnabled: true,
      compassEnabled: false,
    myLocationButtonEnabled: false,
    rotateGesturesEnabled: true,
    markers: Set<Marker>.of(markerList.values),
  mapType: MapType.normal,
  initialCameraPosition: CameraPosition(target: LatLng(_lat,_lng),zoom: 10),
  onMapCreated: (GoogleMapController controller) {
  _controller.complete(controller);
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
    await getAddress(_lat,_lng);
  }

  void getCamera_on_Location() async {
    Position res = await Geolocator().getCurrentPosition();
    setState(() {
      position = res;
      print("position: ");
      print(_lat);
      print(_lng);
      CameraPosition(
        target: LatLng(position.latitude, position.longitude),
      );
    });
  }



  populateMap_w_Markers() {
    print("loading markers");

    Firestore.instance.collection('test').getDocuments().then((docs) {
      if ( docs.documents.isNotEmpty) {
        for(int i = 0; i < docs.documents.length; i++){
          print('created marker');
          initMarker(docs.documents[i].data, docs.documents[i].documentID);
        }
      }
    });
  }


  void getAddress(double latitude, double longitude) async {
    placemark = await Geolocator().placemarkFromCoordinates(latitude, longitude);
    _address = placemark[0].name.toString() + "," + placemark[0].locality.toString() + ", Postal Code:" + placemark[0].postalCode.toString();
    setState(() {

      _map = mapWidget();

    });
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
      markerList[markerId] = marker;
      print(markerId);
    });
  }



    CameraPosition _kLake = CameraPosition(
      target: LatLng(37.43296265331129, -122.08832357078792),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: Center(child: _map),
      floatingActionButton: _getMapButtons(),


    );
  }

  Future<void> _goToUser() async {

    final GoogleMapController controller = await _controller.future;


    controller.animateCamera(
        CameraUpdate.newCameraPosition(CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: 15.0,
        )
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
      children: [

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

      ],
    );
  }


}