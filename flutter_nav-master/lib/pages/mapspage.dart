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
import 'package:toast/toast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:f_nav/weather_request.dart';

import 'package:weather_icons/weather_icons.dart';
import 'package:flutter/cupertino.dart';



import 'package:f_nav/pages/secondPage.dart';
const apiKey = 'c287f389370cfc2c227abf41d002858d';


class MapsPage extends StatelessWidget {

  static const String routeName = '/map';

  final title = "Notifications Page";
  final description = "add content....";
  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        backgroundColor: CupertinoColors.lightBackgroundGray,
        items: [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.location_solid),
            title: Text('Marker page', style: TextStyle(fontSize: 15),),
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.profile_circled),
            title: Text('User Page', style: TextStyle(fontSize: 15),),
          ),
        ],
      ),
      tabBuilder: (context, index) {
        return CupertinoTabView(
          builder: (context) {
            switch (index) {
              case 0:
                return MapSample();
            ;
                break;
              case 1:
                return Container();
                break;
              default:
                return Container();
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

  String user_uid, user_display_name;

  double _lat, _lng;




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
    _map = CupertinoActivityIndicator();

    re_InitilizeMap();

    super.initState();

    //    Connect Task text controllers to fields.
    _titleController.text = inputaddr;
    _descriptionController.text = inputaddr;

  }

  double latitude;
  double longitude;


   getDataWeather(latitude,longitude) async {

    WeatherRequest weatherRequest = WeatherRequest(
        'https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&units=metric&appid=$apiKey');
    var weatherdata = await weatherRequest.getData();




//   TODO: parse json here and grab info for card Icons
    var whole = weatherdata["weather"][0]['description'];


     setState(() {

       //     TODO: Save description to array from here
       condition = whole.toString();

       conditionsMap.add(whole.toString());
       print("Array is: " + conditionsMap.toString());
     });

  return whole.toString();

  }


  void re_InitilizeMap() {
     markers.clear();
     conditionsMap.clear();
     iconCounter=0;
    getCurrentLocation();
    populateMap_w_Markers();
     _titleController.clear();
     _descriptionController.clear();
    super.initState();
    
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
      condition = getDataWeather(request['location'].latitude,request['location'].longitude);

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


  Widget listWidget()
  {
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
            if (!snapshot.hasData || snapshot.data.documents.length != conditionsMap.length  ) {
              return CupertinoActivityIndicator();
            }

              else {
              // card ListView
              return new ListView(


                scrollDirection: Axis.horizontal,
                children: snapshot.data.documents.map((
                    DocumentSnapshot document) {
                  var latitude = document['location'].latitude;
                  var longitude = document['location'].longitude;
//                print("condition: " + condition.toString());

                  var temp = condition.toString();

                  // init card icon
                  var cardIcon;
                  // init card color
                  var cardColor;

                  //  Conditions for card icons and color from OpenWeatherMap
                  if (conditionsMap[iconCounter].isNotEmpty &&
                      conditionsMap[iconCounter].length != 0) {

//                    SKY
                    if (conditionsMap[iconCounter] == "clear sky") {
                      cardIcon = Icon(
                        WeatherIcons.day_sunny_overcast, color: Colors.black,);
                      cardColor = Colors.yellow;
                    }

//                    CLOUDS
                    else if (conditionsMap[iconCounter] == "scattered clouds") {
                      cardIcon = Icon(
                        WeatherIcons.day_cloudy_high, color: Colors.black,);
                      cardColor = Colors.grey;
                    }
                    else if (conditionsMap[iconCounter] == "few clouds") {
                      cardIcon =
                          Icon(WeatherIcons.day_cloudy, color: Colors.black,);
                      cardColor = Colors.blueGrey;
                    }
                    else if (conditionsMap[iconCounter ] == "scattered clouds") {
                      cardIcon =
                          Icon(WeatherIcons.day_cloudy, color: Colors.black,);
                      cardColor = Colors.blueGrey;
                    }
                    else if (conditionsMap[iconCounter ] == "broken clouds") {
                      cardIcon =
                          Icon(WeatherIcons.day_cloudy, color: Colors.black,);
                      cardColor = Colors.blueGrey;
                    }
                    else if (conditionsMap[iconCounter ] == "overcast clouds") {
                      cardIcon = Icon(
                        WeatherIcons.day_cloudy_gusts, color: Colors.black,);
                      cardColor = Colors.grey;
                    }

//                    THUNDERSTORM
                    else if (conditionsMap[iconCounter ] == "thunderstorm with light rain") {
                      cardIcon = Icon(WeatherIcons.day_thunderstorm, color: Colors
                          .black,);
                      cardColor = Colors.blueAccent;
                    }
                    else if (conditionsMap[iconCounter ] == "thunderstorm with rain") {
                      cardIcon = Icon(WeatherIcons.day_thunderstorm, color: Colors
                          .black,);
                      cardColor = Colors.blueAccent;
                    }
                    else if (conditionsMap[iconCounter ] == "thunderstorm with heavy rain") {
                      cardIcon = Icon(WeatherIcons.day_thunderstorm, color: Colors
                          .black,);
                      cardColor = Colors.blueAccent;
                    }
                    else if (conditionsMap[iconCounter ] == "light thunderstorm") {
                      cardIcon = Icon(WeatherIcons.day_thunderstorm, color: Colors
                          .black,);
                      cardColor = Colors.blueAccent;
                    }
                    else if (conditionsMap[iconCounter ] == "thunderstorm") {
                      cardIcon = Icon(WeatherIcons.day_thunderstorm, color: Colors
                          .black,);
                      cardColor = Colors.blueAccent;
                    }
                    else if (conditionsMap[iconCounter ] == "heavy thunderstorm") {
                      cardIcon = Icon(WeatherIcons.day_thunderstorm, color: Colors
                          .black,);
                      cardColor = Colors.blueAccent;
                    }
                    else if (conditionsMap[iconCounter ] == "ragged thunderstorm") {
                      cardIcon = Icon(WeatherIcons.day_thunderstorm, color: Colors
                          .black,);
                      cardColor = Colors.blueAccent;
                    }
                    else if (conditionsMap[iconCounter ] == "thunderstorm with light drizzle") {
                      cardIcon = Icon(WeatherIcons.day_thunderstorm, color: Colors
                          .black,);
                      cardColor = Colors.blueAccent;
                    }
                    else if (conditionsMap[iconCounter ] == "thunderstorm with drizzle") {
                      cardIcon = Icon(WeatherIcons.day_thunderstorm, color: Colors
                          .black,);
                      cardColor = Colors.blueAccent;
                    }
                    else if (conditionsMap[iconCounter ] == "thunderstorm with heavy drizzle") {
                      cardIcon = Icon(WeatherIcons.day_thunderstorm, color: Colors
                          .black,);
                      cardColor = Colors.blueAccent;
                    }





//                    DRIZZLE
                    else if (conditionsMap[iconCounter ] == "light intensity drizzle") {
                      cardIcon = Icon(WeatherIcons.day_rain, color: Colors
                          .black,);
                      cardColor = Colors.blueAccent;
                    }
                    else if (conditionsMap[iconCounter ] == "drizzle") {
                      cardIcon = Icon(WeatherIcons.day_rain, color: Colors
                          .black,);
                      cardColor = Colors.blueAccent;
                    }
                    else if (conditionsMap[iconCounter ] == "heavy intensity drizzle") {
                      cardIcon = Icon(WeatherIcons.day_rain, color: Colors
                          .black,);
                      cardColor = Colors.blueAccent;
                    }
                    else if (conditionsMap[iconCounter ] == "light intensity drizzle rain") {
                      cardIcon = Icon(WeatherIcons.day_rain, color: Colors
                          .black,);
                      cardColor = Colors.blueAccent;
                    }
                    else if (conditionsMap[iconCounter ] == "drizzle rain") {
                      cardIcon = Icon(WeatherIcons.day_rain, color: Colors
                          .black,);
                      cardColor = Colors.blueAccent;
                    }
                    else if (conditionsMap[iconCounter ] == "heavy intensity drizzle rain") {
                      cardIcon = Icon(WeatherIcons.day_rain, color: Colors
                          .black,);
                      cardColor = Colors.blueAccent;
                    }
                    else if (conditionsMap[iconCounter ] == "shower rain and drizzle") {
                      cardIcon = Icon(WeatherIcons.day_rain, color: Colors
                          .black,);
                      cardColor = Colors.blueAccent;
                    }
                    else if (conditionsMap[iconCounter ] == "heavy shower rain and drizzle") {
                      cardIcon = Icon(WeatherIcons.day_rain, color: Colors
                          .black,);
                      cardColor = Colors.blueAccent;
                    }
                    else if (conditionsMap[iconCounter ] == "shower drizzle") {
                      cardIcon = Icon(WeatherIcons.day_rain, color: Colors
                          .black,);
                      cardColor = Colors.blueAccent;
                    }



//                    RAIN
                    else if (conditionsMap[iconCounter ] == "rain") {
                      cardIcon = Icon(WeatherIcons.day_rain, color: Colors
                          .black,);
                      cardColor = Colors.blueAccent;
                    }
                    else if (conditionsMap[iconCounter ] == "light rain") {
                      cardIcon = Icon(WeatherIcons.day_rain, color: Colors
                          .black,);
                      cardColor = Colors.blue;
                    }
                    else if (conditionsMap[iconCounter ] == "moderate rain") {
                      cardIcon = Icon(WeatherIcons.day_rain, color: Colors
                          .black,);
                      cardColor = Colors.blue;
                    }
                    else if (conditionsMap[iconCounter ] == "heavy intensity rain") {
                      cardIcon = Icon(WeatherIcons.day_rain, color: Colors
                          .black,);
                      cardColor = Colors.blue;
                    }
                    else if (conditionsMap[iconCounter ] == "very heavy rain") {
                      cardIcon = Icon(WeatherIcons.day_rain, color: Colors
                          .black,);
                      cardColor = Colors.blue;
                    }
                    else if (conditionsMap[iconCounter ] == "extreme rain") {
                      cardIcon = Icon(WeatherIcons.day_rain, color: Colors
                          .black,);
                      cardColor = Colors.blue;
                    }

                    else if (conditionsMap[iconCounter ] == "light intensity shower rain") {
                      cardIcon = Icon(WeatherIcons.day_rain, color: Colors
                          .black,);
                      cardColor = Colors.blue;
                    }

                    else if (conditionsMap[iconCounter ] == " shower rain") {
                      cardIcon = Icon(WeatherIcons.day_rain, color: Colors
                          .black,);
                      cardColor = Colors.blue;
                    }
                    else if (conditionsMap[iconCounter ] == "heavy intensity shower rain") {
                      cardIcon = Icon(WeatherIcons.day_rain, color: Colors
                          .black,);
                      cardColor = Colors.blue;
                    }
                    else if (conditionsMap[iconCounter ] == "ragged shower rain") {
                      cardIcon = Icon(WeatherIcons.day_rain, color: Colors
                          .black,);
                      cardColor = Colors.blue;
                    }

                    else if (conditionsMap[iconCounter ] == "freezing rain") {
                      cardIcon = Icon(WeatherIcons.day_rain, color: Colors
                          .black,);
                      cardColor = Colors.lightBlueAccent;
                    }


                    else if (conditionsMap[iconCounter ] == "thunderstorm") {
                      cardIcon = Icon(WeatherIcons.day_thunderstorm,
                        color: Colors.black,);
                      cardColor = Colors.lightBlueAccent;
                    }

                    else if (conditionsMap[iconCounter ] == "snow") {
                      cardIcon = Icon(
                        WeatherIcons.day_snow, color: Colors.black,);
                      cardColor = Colors.lime;
                    }
                    else if (conditionsMap[iconCounter ] == "light snow") {
                      cardIcon = Icon(
                        WeatherIcons.day_snow, color: Colors.black,);
                      cardColor = Colors.white30;
                    }

                    else if (conditionsMap[iconCounter ] == "mist") {
                      cardIcon =
                          Icon(WeatherIcons.day_fog, color: Colors.black,);
                      cardColor = Colors.teal;
                    }

                    else {
                      cardIcon = Icon(Icons.error, color: Colors.red,);
                    }
                  }

                  iconCounter++; // we increment int here when we build a card

                  return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),

                        color: Colors.white30,
//                      color:  CupertinoColors.lightBackgroundGray,
                      borderOnForeground: true,

                      child: Container(



                          padding: const EdgeInsets.only(top: 1.0),
                          child: Column(
                            children: <Widget>[
                              Text(document['address'],
                                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),

                              SizedBox(height: 0),
                              //separator and spa
                              Text("conditions: \n" +
                                  conditionsMap[iconCounter - 1] ?? "null",
                                style: TextStyle(
                                  color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold),),
                              //set array to offload saved conditions from weather query and offset by 1 on account of incrementation before.

                              SizedBox( width: 150,
                                child: CupertinoButton(
                                  color: Colors.blueGrey,
                                  child: Container(child: cardIcon,  ),),
                              ),
                              //separator and spacer
                              SizedBox(
                                height: 20,
                                child: CupertinoButton(
//                                  color: cardColor,
                                  onPressed: () {
                                    Toast.show(
                                        "Address: " + document['address'] ??
                                            "" + "\nLat: " +
                                                latitude.toString() +
                                                "\nLong: " +
                                                longitude.toString(), context,
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

                              SizedBox(height: 5,),
                              //separator and spacer
                              SizedBox(
                                height: 20,
                                child: CupertinoButton(
                                  color: cardColor,
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                SecondPage(
                                                    title: document['address'],
                                                    description: document['address'])));
                                  },
                                  padding: EdgeInsets.all(0),
                                  // make the padding 0 so the child wont be dragged right by the default padding
                                  child: Container(
                                    child: Text("More info",
                                      style: TextStyle(color: Colors.black),),
                                  ),
                                ),
                              ),

                              SizedBox(height: 2,),
                              //separator and spacer
                              SizedBox(
                                height: 18,
                                width: 70,
                                child: CupertinoButton(
                                  color: Colors.redAccent,
                                  onPressed: () {
                                    confirmDeleteMarker(document.documentID);

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
     iconCounter = 0;
    return  CupertinoPageScaffold(

      backgroundColor: CupertinoColors.white,
      child:
      Column(children: <Widget>[

        SizedBox(height: 70, ),
//        Text("Marker list: ", style: TextStyle(color: Colors.black),),
        Container(
          child: SizedBox(
            height: screenHeight(context, dividedBy: 4),
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
    else {Firestore.instance.collection('test').add({'location': new GeoPoint(lat, long), 'address': inputaddr,});}
  }


  Future confirmDeleteMarker(documentID) async {


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

