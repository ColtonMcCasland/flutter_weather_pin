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
      mapType: MapType.normal,
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
      body: Stack(children: <Widget>[ _map]), //map
      floatingActionButton: _getMapButtons(), //buttons
    );
  }


  String user_uid, user_display_name;

  /// Post to Firebase DB
  addToList(lat, long) async {
    if(lat == null || long == null ){
      print("what!");
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
                    hintText: 'Write your message here ...',
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