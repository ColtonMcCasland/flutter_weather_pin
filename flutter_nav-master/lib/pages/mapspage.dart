import 'dart:async';
import 'package:f_nav/pages/settings.dart';
import 'package:flutter/material.dart';
import '../widgets/drawer.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:location/location.dart';
import 'package:weather/weather.dart';
import 'package:toast/toast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:f_nav/weather_request.dart';

import 'package:weather_icons/weather_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:f_nav/pages/account.dart';
import 'package:firebase_auth/firebase_auth.dart';



import 'package:f_nav/pages/DetailPage.dart';
const apiKey = 'c287f389370cfc2c227abf41d002858d';


//TODO: Work on getting weather function to load markers syncronously with condition order.

class MapsPage extends StatelessWidget {

  static const String routeName = '/map';

  final title = "Notifications Page";
  final description = "add content....";
  @override
  Widget build(BuildContext context)
  {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        backgroundColor: CupertinoColors.lightBackgroundGray,
        items: [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.location_solid),
            title: Text('Markers page', style: TextStyle(fontSize: 15),),
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.profile_circled),
            title: Text('Profile Page', style: TextStyle(fontSize: 15),),
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.settings),
            title: Text('Settings Page', style: TextStyle(fontSize: 15),),
          ),
        ],
      ),
      tabBuilder: (context, index) {
        return CupertinoTabView(
          builder: (context) {
            switch (index) {
              case 0:
                return MapSample();
                break;
              case 1:
                return AccountScreen();
                break;
              default:
                return SettingsScreen();
            }
          },
        );
      },

//      body:
//      new MapSample(),
    );
  }

}

class MapSample extends StatefulWidget {
  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {

  WeatherStation weatherStation = new WeatherStation("34cd503973bce95c2e833573eb0d9561");



  //  title controller
  final _titleController = TextEditingController();
//  description controller
  final _descriptionController = TextEditingController();
//  due date controller

// vars to check for empty fields.
  bool _validate1 = false;
  bool _validate2 = false;

  var condition;
  var tempCondition;

  int iconCounter =0;

  List<String> conditionsMap = [];




  static const LatLng _center = const LatLng(45.521563, -122.677433);
  LatLng _lastMapPosition = _center;
  MapType _currentMapType = MapType.normal;
  Set<Marker> markers = Set();
  Set<Icon> icons = Set();

  Position position;
  Location location = Location();
  Map<String, double> currentLocation;
  Completer<GoogleMapController> _controller = Completer();
  Widget _map;

  List<Placemark> placemark;
  String _address;
  String inputaddr = '';
  Colors inputcolor;


  double _lat, _lng;

  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  String user_uid, user_display_name;





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


  void onStart(){
    _firebaseAuth.currentUser().then((FirebaseUser user) {
      user_uid = user.uid;
      user_display_name = user.displayName;
      print(user_display_name);

    });
  }

  @override
  void initState() {





    _map = CupertinoActivityIndicator();


    super.initState();

    onStart();


    //    Connect Task text controllers to fields.
    _titleController.text = inputaddr;
    _descriptionController.text = inputaddr;
    re_InitilizeMap();


  }

  double latitude;
  double longitude;




  void re_InitilizeMap() {
     markers.clear();
     conditionsMap.clear();
     iconCounter=0;
    getCurrentLocation();
    populateMap_w_Markers();
     _titleController.clear();
     _descriptionController.clear();



    
  }

  @override
  void dispose() {
    conditionsMap.clear();
    markers.clear();

    icons.clear();
    super.dispose();
    _titleController.clear();
    _descriptionController.clear();
    iconCounter=0;
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
          title: request['address']  , snippet: null),
    );



    await setState(() {

      markers.add(marker);

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
      re_InitilizeMap();

    });
  }

  void getCamera_on_Marker(location)  async
  {
    final GoogleMapController controller = await _controller.future;

    controller.animateCamera(
      CameraUpdate.newCameraPosition(CameraPosition(target: LatLng(location.latitude, location.longitude), zoom: 8.0,)
      ),
    );
  }

  void populateMap_w_Markers()
  {
    print("loading markers...");

    Firestore.instance.collection('test').getDocuments().then((docs) {
      if (docs.documents.isNotEmpty) {
        for (int i = 0; i < docs.documents.length; i++) {
          initMarker(docs.documents[i].data, docs.documents[i].documentID);

        }
      }
    });
  }

    Future<void> deleteMarker(String documentId){
      return  Firestore.instance.collection('test').document(documentId).delete();
    }


  Widget mapWidget() {
    return GoogleMap(

      myLocationButtonEnabled: true,
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

      },

    );
  }

  getDataWeather(latitude,longitude) async {

    WeatherRequest weatherRequest = WeatherRequest(
        'https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&units=metric&appid=$apiKey');
    var weatherdata = await weatherRequest.getData();


    var whole = weatherdata["weather"][0]['description'];


    setState(() {

      condition = whole.toString();
    });


  }


   listWidget()  {


    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('test').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError)
          return new Text('Error: ${
              snapshot.error
          }');
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return new CupertinoActivityIndicator(animating: true,);
          default:
            if (!snapshot.hasData ) {
              return CupertinoActivityIndicator();
            }

              else {
                print(condition);

              // card ListView
              return
                ListView(


                scrollDirection: Axis.horizontal,
                children: snapshot.data.documents.map((DocumentSnapshot document)
                {


                  var latitude = document['location'].latitude;
                  var longitude = document['location'].longitude;


                  var temp = condition.toString();




                  return Card(

                      color: Colors.white70,
//                      color:  CupertinoColors.lightBackgroundGray,
                      borderOnForeground: true,

                      child: Container(

                          padding: const EdgeInsets.only(top: 1.0),
                          child: Column(
                            children: <Widget>[
                              Text(document['address'],
                                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 30), ),

                              SizedBox(height: 15, child: Text('by:' + document['owner_name']),),
                              //separator and spa
                              //set array to offload saved conditions from weather query and offset by 1 on account of incrementation before.

                              //separator and spacer
                              SizedBox(
                                child: CupertinoButton(
//                                  color: cardColor,
                                  onPressed: () {
                                    Toast.show("Address: " + document['address'] ?? "" + "\nLat: " + latitude.toString() + "\nLong: " + longitude.toString(),
                                        context,
                                        duration: Toast.LENGTH_LONG,
                                        gravity: Toast.TOP);

                                    getCamera_on_Marker(document['location']);
                                  },
                                  padding: EdgeInsets.all(0),
                                  // make the padding 0 so the child wont be dragged right by the default padding
                                  child: Container(
                                    child: Icon(Icons.location_searching),
                                  ),
                                ),
                              ),

                              //separator and spacer
                              SizedBox(
                                child: CupertinoButton(
                                  color: CupertinoColors.white,
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                SecondPage(
                                                    title: document['address'],
                                                    lat: document['location'].latitude,
                                                    long: document['location'].longitude
                                                )
                                        ));
                                  },
                                  padding: EdgeInsets.all(0),
                                  // make the padding 0 so the child wont be dragged right by the default padding
                                  child: Container(
                                    child: Text("More info",
                                      style: TextStyle(color: Colors.black, ),),
                                  ),
                                ),
                              ),

                              //separator and spacer
                              SizedBox(
                                width: 70,
                                child: CupertinoButton(
                                  color: Colors.redAccent,
                                  onPressed: () {
                                    confirmDeleteMarker(document,document.documentID);

                                  },
                                  padding: EdgeInsets.all(0),
                                  // make the padding 0 so the child wont be dragged right by the default padding
                                  child: Container(

                                    child: Text("Delete",
                                      style: TextStyle(color: Colors.black),),
                                  ),
                                ),
                              ),
                            ],
                          )
                      )
                  );
                }
                ).toList(),
              );
            }
        }
      },
    );
  }





  @override
  Widget build(BuildContext context) {

    return  CupertinoPageScaffold(

      backgroundColor: CupertinoColors.white,
      child:
      Column(children: <Widget>[

        SizedBox(height: 70, ),
//        Text("Marker list: ", style: TextStyle(color: Colors.black),),
        Container(
          child: SizedBox(
            height: screenHeight(context, dividedBy: 3.5),
//            width: screenWidth(context, dividedBy: 1.1),
            child: listWidget(),
          ),
        ),


        Container(
          margin: const EdgeInsets.all(1.0),
          padding: const EdgeInsets.all(1.0),
          decoration: BoxDecoration(
            border: Border.all(
            width: 3.0
            ),
            borderRadius: BorderRadius.all(
            Radius.circular(2.0)
          )),
          child: SizedBox(
        height: screenHeight(context,
            dividedBy: 3),
        child: _map,
          ),
        ),

        Row(
            children: <Widget>[
              CupertinoButton(
                child:
                CupertinoButton(
                  color: Colors.black,
                  disabledColor: Colors.black,
                  pressedOpacity: .5,

                  borderRadius: BorderRadius.all(Radius.elliptical(10.0,10)),
                  child:  Icon(Icons.pin_drop),
                  onPressed: () {

                    if(_lastMapPosition.latitude == null){
                      print("Error: tap performed on pin_drop while latitude what null!");
                    }
                    else
                      ConfirmAddMarker(_lastMapPosition.latitude,_lastMapPosition.longitude);
                    _titleController.clear();
                    _descriptionController.clear();

                    setState(() {});
                  },
                ),
              ),
            ]
        ),
      ],
      ), //map
      navigationBar: CupertinoNavigationBar(
        middle: Text("Main page"),

      ),
    );
  }



  /// Post to Firebase DB
  addToList(lat, long) async {
    if(lat == null || long == null ){print("ERROR: lat and long are NULL!");}
    else {Firestore.instance.collection('test').add({'location': new GeoPoint(lat, long), 'address': inputaddr, 'owner_name': user_display_name});}
  }


  Future confirmDeleteMarker(document,documentID) async {

    if(user_display_name == document['owner_name'])
      {
        await showDialog(
            context: context,
            barrierDismissible: true,
            builder: (BuildContext context) {

              return CupertinoAlertDialog(
                title: new Text('Compose Marker info',
                  style: new TextStyle(fontSize: 17.0,color: Colors.black),
                ),
                content: new Text("Are you sure?"),
                actions: <Widget>[

                  CupertinoDialogAction(
                      child: new CupertinoButton(child: new Text('Cancel',
                          style: new TextStyle(color: Colors.black)), onPressed: () {

                        setState(() {});

                        Navigator.of(context).pop();

                      },
                      )
                  ),


                  CupertinoDialogAction(
                      child: new CupertinoButton(child: new Text('Confirm',
                          style: new TextStyle(color: Colors.black)), onPressed: () {

                        setState(() {
                          deleteMarker(documentID);
                        });

                        Navigator.of(context).pop();
                      },
                      )
                  ),
                ],
              );
            });
        re_InitilizeMap();
      }
    else
      {
        Toast.show("Do not have authority to delete this marker.", context);
      }



  }

  Future ConfirmAddMarker(lat, long) async {

      await showDialog(
          context: context,
          barrierDismissible: true,
          builder: (BuildContext context) {

            return CupertinoAlertDialog(
                title: new Text(
                'Compose Marker info',
                style: new TextStyle(fontSize: 17.0,color: Colors.black),
              ),
              content: new Text(""),
              actions: <Widget>[

              new CupertinoTextField(
                    style: new TextStyle(color: Colors.black),
                  controller: _titleController,

                placeholder: 'Marker title',

                  onChanged: (String enteredLoc) {
                    setState(() {
                      inputaddr = enteredLoc;
                    });
                  },
                ),
                 new CupertinoTextField(
                    style: new TextStyle(color: Colors.black),

                    placeholder: 'Marker message',
                    controller: _descriptionController,

            ),
                CupertinoDialogAction(
                  child: new CupertinoButton(child: new Text('Add Marker',
                      style: new TextStyle(color: Colors.black)), onPressed: () {
                    if(_titleController != null|| _descriptionController != null){

                      setState(()
                      {
                        _titleController.text.isEmpty ? _validate1 = true : _validate1 = false;
                        _descriptionController.text.isEmpty ? _validate2 = true : _validate2 = false;
                      });

                      if (_titleController.text.isEmpty == false && _descriptionController.text.isEmpty == false  )
                      {
                        addToList(lat, long);
                        Navigator.of(context).pop();
                      }

                    }
                    else {
//                      Toast.show("Fill in all entry fields.", context, duration: Toast.LENGTH_LONG, gravity:  Toast.TOP);
                    }
                  },)
                ),
              ],
            );
          });
    re_InitilizeMap();
  }

}

