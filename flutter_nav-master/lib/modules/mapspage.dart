import 'dart:async';
import 'package:flutter/material.dart';
import '../widget/drawer.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:simple_moment/simple_moment.dart';
import 'package:transparent_image/transparent_image.dart';
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


  Completer<GoogleMapController> _controller = Completer();

  @override
  void initState() {
    _map=SpinKitCubeGrid(color: Colors.white, size: 50.0, );

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
    markers: Set<Marker>.of(markerList.values),
  mapType: MapType.hybrid,
  initialCameraPosition: _kGooglePlex,
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

  Widget _map;

  List<Placemark> placemark;
  String _address;
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

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  static final CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(37.43296265331129, -122.08832357078792),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: mapWidget(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _goToTheLake,
        label: Text('To the lake!'),
        icon: Icon(Icons.directions_boat),
      ),
    );
  }

  Future<void> _goToTheLake() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
  }
}