import 'package:flutter/material.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire/src/point.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rxdart/rxdart.dart';
import 'package:location/location.dart';
import 'dart:async';
import 'package:flutter/services.dart';

import 'package:flutter_feedly/screens/home.dart';

import 'package:flutter_feedly/streambuilder_test.dart';

///----------------------------------------
// Documentation on geo markers query from firestore
// https://libraries.io/pub/geoflutterfire
///----------------------------------------
///
class FireMap extends StatefulWidget {
  static const String routeName = "/fireMap";

  @override
  FireMapState createState() => FireMapState();
}

final clients = [];
final Set<Marker> markers = {};

class FireMapState extends State<FireMap> {
  GoogleMapController _mapController;
  TextEditingController _latitudeController, _longitudeController;

  // firestore init
  Firestore _firestore = Firestore.instance;
  Geoflutterfire geo;
  Stream<List<DocumentSnapshot>> stream;
  var radius = BehaviorSubject.seeded(1.0);
  var zoom = 1;
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

  Location location =  Location();
  LocationData currentLocation;
  LocationData _startLocation;
  LocationData _currentLocation;
  Completer _controller = Completer();

  Location _locationService  = new Location();
  bool _permission = false;
  String error;
  StreamSubscription<LocationData> _locationSubscription;
  CameraPosition _currentCameraPosition;

  GoogleMap googleMap;


// Platform messages are asynchronous, so we initialize in an async method.
  initPlatformState() async {
    await _locationService.changeSettings(accuracy: LocationAccuracy.HIGH, interval: 1000);

    LocationData location;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      bool serviceStatus = await _locationService.serviceEnabled();
      print("Service status: $serviceStatus");
      if (serviceStatus) {
        _permission = await _locationService.requestPermission();
        print("Permission: $_permission");
        if (_permission) {
          location = await _locationService.getLocation();

          _locationSubscription = _locationService.onLocationChanged().listen((LocationData result) async {
            _currentCameraPosition = CameraPosition(
                target: LatLng(result.latitude, result.longitude),
                zoom: 16
            );

            final GoogleMapController controller = await _controller.future;
            controller.animateCamera(CameraUpdate.newCameraPosition(_currentCameraPosition));

            if(mounted){
              setState(() {
                _currentLocation = result;
              });
            }
          });
        }
      } else {
        bool serviceStatusResult = await _locationService.requestService();
        print("Service status activated after request: $serviceStatusResult");
        if(serviceStatusResult){
          initPlatformState();
        }
      }
    } on PlatformException catch (e) {
      print(e);
      if (e.code == 'PERMISSION_DENIED') {
        error = e.message;
      } else if (e.code == 'SERVICE_STATUS_ERROR') {
        error = e.message;
      }
      location = null;
    }

    setState(() {
      _startLocation = location;
    });

  }

  @override
  void initState() {
    super.initState();
    _latitudeController = TextEditingController();
    _longitudeController = TextEditingController();

    geo = Geoflutterfire();

    initPlatformState();




//TODO: on start grab current location and query based off that here:

    GeoFirePoint center = geo.point(latitude: 12.960632, longitude: 77.641603);


    stream = radius.switchMap((rad) {
      var collectionReference = _firestore.collection('locations');
//          .where('name', isEqualTo: 'darshan');
      return geo.collection(collectionRef: collectionReference).within(
          center: center, radius: rad, field: 'position', strictMode: false);

      /*
      ****Example to specify nested object****
      var collectionReference = _firestore.collection('nestedLocations');
//          .where('name', isEqualTo: 'darshan');
      return geo.collection(collectionRef: collectionReference).within(
          center: center, radius: rad, field: 'address.location.position');
      */
    });
  }



  @override
  void dispose() {
    super.dispose();
    radius.close();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed:() => Navigator.pop(context, false),
          ),
          title: Text('Your Map view'),

          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.filter_center_focus),
              onPressed:() {
                _showHome();
              },
            )
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return StreamTestWidget();
            }));
          },
          child: Icon(Icons.navigate_next),
        ),
        body: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Center(
                child: Card(
                  elevation: 4,
                  margin: EdgeInsets.symmetric(vertical: 8),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width - 30,
                    height: MediaQuery.of(context).size.height * (3 / 5),
                    child: GoogleMap(
                      onMapCreated: _onMapCreated,
                      initialCameraPosition: const CameraPosition(
                        target: LatLng(12.960632, 77.641603),
                        zoom: 1.0,
                      ),
                      markers: Set<Marker>.of(markers.values),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Slider(
                  min: 1,
                  max: 1000,
                  divisions: 20,
                  value: _value,
                  label: _label,
                  activeColor: Colors.blue,
                  inactiveColor: Colors.blue.withOpacity(0.2),
                  onChanged: (double value) => changed(value),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Container(
                    width: 100,
                    child: TextField(
                      controller: _latitudeController,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                          labelText: 'lat',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          )),
                    ),
                  ),
                  Container(
                    width: 100,
                    child: TextField(
                      controller: _longitudeController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                          labelText: 'lng',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          )),
                    ),
                  ),
                  MaterialButton(
                    color: Colors.blue,
                    onPressed: () {
                      double lat = double.parse(_latitudeController.text);
                      double lng = double.parse(_longitudeController.text);
                      _addPoint(lat, lng);
                    },
                    child: Text(
                      'ADD',
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                ],
              ),
//              MaterialButton(
//                color: Colors.amber,
//                child: Text(
//                  'Add nested ',
//                  style: TextStyle(color: Colors.white),
//                ),
//                onPressed: () {
//                  double lat = double.parse(_latitudeController.text);
//                  double lng = double.parse(_longitudeController.text);
//                  _addNestedPoint(lat, lng);
//                },
//              )
            ],
          ),
        ),
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      _mapController = controller;
//      _showHome();
      //start listening after map is created
      stream.listen((List<DocumentSnapshot> documentList) {
        _updateMarkers(documentList);
      });

      _mapController.animateCamera(CameraUpdate.newCameraPosition(
        const CameraPosition(
          target: LatLng(36.0822, 94.1719),
          zoom: 5.0,
        ),
      ));


    });
  }



  void _addPoint(double lat, double lng) {
    GeoFirePoint geoFirePoint = geo.point(latitude: lat, longitude: lng);
    _firestore
        .collection('locations')
        .add({'name': 'random name', 'position': geoFirePoint.data}).then((_) {
      print('added ${geoFirePoint.hash} successfully');
    });
  }

  //example to add geoFirePoint inside nested object
  void _addNestedPoint(double lat, double lng) {
    GeoFirePoint geoFirePoint = geo.point(latitude: lat, longitude: lng);
    _firestore.collection('nestedLocations').add({
      'name': 'random name',
      'address': {
        'location': {'position': geoFirePoint.data}
      }
    }).then((_) {
      print('added ${geoFirePoint.hash} successfully');
    });
  }

  void _addMarker(double lat, double lng) {
    MarkerId id = MarkerId(lat.toString() + lng.toString());
    Marker _marker = Marker(
      markerId: id,
      position: LatLng(lat, lng),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
      infoWindow: InfoWindow(title: 'latLng', snippet: '$lat,$lng'),
    );
    setState(() {
      markers[id] = _marker;
    });
  }

  void _updateMarkers(List<DocumentSnapshot> documentList) {
    documentList.forEach((DocumentSnapshot document) {
      GeoPoint point = document.data['position']['geopoint'];
      _addMarker(point.latitude, point.longitude);
    });
  }

  double _value = 150.0;
  String _label = '';

  changed(value) {
    setState(() {
      _value = value;
      _label = '${_value.toInt().toString()} kms';
      markers.clear();
    });
    radius.add(value);
  }

  void updateGoogleMap()
  async{

    try {
      currentLocation = await location.getLocation();

      print("locationLatitude: ${currentLocation.latitude.toString()}");
      print("locationLongitude: ${currentLocation.longitude.toString()}");
      setState(
              () {}); //rebuild the widget after getting the current location of the user
    } on Exception {
      currentLocation = null;
    }

    GoogleMapController cont = await _controller.future;
    setState(() {

      CameraPosition newtPosition = CameraPosition(
        target: LatLng(currentLocation.latitude, currentLocation.longitude), //re-orient to user location on call
        zoom: 10, // controlls zoom factoring when clicked update map

      );

      cont.animateCamera(CameraUpdate.newCameraPosition(newtPosition));

    });
  }

  void _showHome() async{

    try {
      currentLocation = await location.getLocation();

      print("locationLatitude: ${currentLocation.latitude.toString()}");
      print("locationLongitude: ${currentLocation.longitude.toString()}");
      setState(() {
                _mapController.animateCamera(CameraUpdate.newCameraPosition(
                   CameraPosition(
                    target: LatLng(12.960632, 77.641603),
                    zoom: 5.0,
                  ),
                ));

              }); //rebuild the widget after getting the current location of the user
    } on Exception
    {
      currentLocation = null;
    }


  }
}
