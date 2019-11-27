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
            icon: Icon(CupertinoIcons.home),
            title: Text('Home'),
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.bluetooth),
            title: Text('???'),
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
  WeatherStation weatherStation = new WeatherStation(
      "34cd503973bce95c2e833573eb0d9561");

  //  title controller
  final _titleController = TextEditingController();
//  description controller
  final _descriptionController = TextEditingController();
//  due date controller

// vars to check for empty fields.
  bool _validate1 = false;
  bool _validate2 = false;

  var condition;

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

    getCurrentLocation();
    populateMap_w_Markers();
    super.initState();

    //    Connect Task text controllers to fields.
    _titleController.text = inputaddr;
    _descriptionController.text = inputaddr;

    re_InitilizeMap();
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

  Future<String> getData(double latitude, double longitude) async {
    String api = 'http://api.openweathermap.org/data/2.5/forecast';
    String appId = '34cd503973bce95c2e833573eb0d9561';

    String url = '$api?lat=$latitude&lon=$longitude&APPID=$appId';

    http.Response response = await http.get(url);

    Map parsed = json.decode(response.body);

    return parsed['list'][0]['weather'][0]['description'];
  }


  void re_InitilizeMap() {
     markers.clear();
     conditionsMap.clear();
    getCurrentLocation();
    populateMap_w_Markers();
    super.initState();
     iconCounter=0;

  }

  @override
  void dispose() {
    markers.clear();
    conditionsMap.clear();
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
          title: 'Test title', snippet: 'Message: ' + request['address']),
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
    });
  }

  void getCamera_on_Marker(location)  async {
    final GoogleMapController controller = await _controller.future;

    controller.animateCamera(
      CameraUpdate.newCameraPosition(CameraPosition(target: LatLng(location.latitude, location.longitude), zoom: 8.0,)
      ),
    );
  }

  void populateMap_w_Markers() {
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
      },
    );
  }

  Widget _buildList(BuildContext context, DocumentSnapshot document) {
    return ListTile(
      title: Text("ex"),
      subtitle: Text("test"),
    );
  }


  Widget listWidget(){
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('test').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError)
          return new Text('Error: ${snapshot.error}');
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return new CupertinoActivityIndicator();
          default:


            // card ListView
             return new ListView(



              scrollDirection: Axis.horizontal,
              children: snapshot.data.documents.map((DocumentSnapshot document) {


                var latitude = document['location'].latitude;
                var longitude = document['location'].longitude;
//                print("condition: " + condition.toString());

                var temp = condition.toString();
//                print(temp);

                // init card icon
                var cardIcon;
                // init card color
                var cardColor;

                //  Conditions for card icons and color from OpenWeatherMap
                if(conditionsMap[iconCounter].isNotEmpty && conditionsMap[iconCounter].length != 0 ) {
                  if (conditionsMap[iconCounter] == "clear sky") {
                    cardIcon = Icon(
                      WeatherIcons.day_sunny_overcast, color: Colors.black,);
                    cardColor = Colors.yellow;
                  }

                  else if (conditionsMap[iconCounter] == "scattered clouds") {
                    cardIcon = Icon(
                      WeatherIcons.day_cloudy_high, color: Colors.black,);
                    cardColor = Colors.grey;
                  }
                  else if (conditionsMap[iconCounter] == "few clouds") {
                    cardIcon =
                        Icon(WeatherIcons.day_cloudy, color: Colors.black,);
                    cardColor = Colors.lightBlueAccent;
                  }
                  else if (conditionsMap[iconCounter ] == "scattered clouds") {
                    cardIcon =
                        Icon(WeatherIcons.day_cloudy, color: Colors.black,);
                    cardColor = Colors.green;
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
                  else if (conditionsMap[iconCounter ] == "mist") {
                    cardIcon = Icon(WeatherIcons.day_fog, color: Colors.black,);
                    cardColor = Colors.teal;
                  }

                  else {
                    cardIcon = Icon(Icons.error, color: Colors.black,);
                  }
                }

                iconCounter++; // we increment int here when we build a card


                return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),

//                        color: Colors.blueGrey,
                    color: cardColor ?? Colors.blueGrey,

                    child: Container(
                        padding: const EdgeInsets.only(top: 1.0),
                        child: Column(
                          children: <Widget>[
                            Text("Marker: " + document['address'] ?? "", style: TextStyle(color: Colors.black),),
                            cardIcon ?? Icons.pin_drop,
                            SizedBox(height: 3), //separator and spa
                            Text("conditions: \n" + conditionsMap[iconCounter - 1] ?? "null", style: TextStyle(color: Colors.black, fontSize: 12, ), ), //set array to offload saved conditions from weather query and offset by 1 on account of incrementation before.

                            SizedBox(height: 5), //separator and spacer
                            SizedBox(
                              height: 30,
                              child: CupertinoButton(
                                color: Colors.white,
                                onPressed: () {
                                  Toast.show("Address: " + document['address'] ?? "" + "\nLat: " + latitude.toString() + "\nLong: " + longitude.toString() , context, duration: Toast.LENGTH_LONG, gravity:  Toast.TOP);

                                  getCamera_on_Marker(document['location']);
                                },
                                padding: EdgeInsets.all(0), // make the padding 0 so the child wont be dragged right by the default padding
                                child: Container(
                                  child: Text("Address: " + document['address'] ?? "",style: TextStyle(color: Colors.black),),
                                ),
                              ),
                            ),

                            SizedBox(height: 5,), //separator and spacer
                            SizedBox(
                              height: 20,
                              child: RaisedButton(
                                color: cardColor,
                                elevation: 12,
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => SecondPage(
                                              title: document['address'], description: document['address'])));

                                },
                                padding: EdgeInsets.all(0), // make the padding 0 so the child wont be dragged right by the default padding
                                child: Container(
                                  child: Text("More info",style: TextStyle(color: Colors.black),),
                                ),
                              ),
                            ),

                            SizedBox(height: 5,), //separator and spacer
                            SizedBox(
                              height: 20,
                              child: RaisedButton(
                                color: cardColor,
                                elevation: 12,
                                onPressed: () {
                                  deleteMarker(document.documentID);
                                  re_InitilizeMap();
                                },
                                padding: EdgeInsets.all(0), // make the padding 0 so the child wont be dragged right by the default padding
                                child: Container(
                                  child: Text("Delete",style: TextStyle(color: Colors.black),),
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
      },
    );
  }





  @override
  Widget build(BuildContext context) {
     iconCounter = 0;
    return  CupertinoPageScaffold(
      backgroundColor: Colors.white,
      child:
      Column(children: <Widget>[
        SizedBox(height: 20),
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
            dividedBy: 2.5),
        child: _map,
        ),),
        Row(
            children: <Widget>[
              Expanded(
                  child:
                  CupertinoButton(
                    color: Colors.grey,
                    disabledColor: Colors.black,
                    pressedOpacity: .5,

                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                    child: const Icon(Icons.my_location),
                    onPressed: () {

                      _goToUser();

                      setState(() {


                      });
                    },
                  ),
              ),
              Expanded(
                child:
                CupertinoButton(
                  color: Colors.grey,
                  disabledColor: Colors.black,
                  pressedOpacity: .5,

                  borderRadius: BorderRadius.all(Radius.circular(50.0)),
                  child: const Icon(Icons.refresh),
                  onPressed: () {

                    re_InitilizeMap();


                    setState(() {



                    });
                  },
                ),
              ),
              Expanded(
                child:
                CupertinoButton(
                  color: Colors.grey,
                  disabledColor: Colors.black,
                  pressedOpacity: .5,

                  borderRadius: BorderRadius.all(Radius.circular(20.0)),
                  child:  Icon(Icons.pin_drop),
                  onPressed: () {

                    if(_lastMapPosition.latitude == null){
                      print("Error: tap performed on pin_drop while latitude what null!");
                    }
                    else
                      addMarker(_lastMapPosition.latitude,_lastMapPosition.longitude);
                    _titleController.clear();
                    _descriptionController.clear();




                    setState(() {



                    });
                  },
                ),
              ),
                  ]
        ),
      ]
      ), //map
//      floatingActionButton: _getMapButtons(), //buttons
    );
  }



  /// Post to Firebase DB
  addToList(lat, long) async {
    if(lat == null || long == null ){
      print("ERROR: lat and long are NULL!");
    }
    else {
      Firestore.instance.collection('test').add({
        'location': new GeoPoint(lat, long),
        'address': inputaddr,
      });
    }
  }

  Future<void> _goToUser() async {

    final GoogleMapController controller = await _controller.future;

    controller.animateCamera(
        CameraUpdate.newCameraPosition(CameraPosition(target: LatLng(position.latitude, position.longitude), zoom: 15.0,)
        )
    );
  }


//  create marker
  Future addMarker(lat, long) async {
      await showDialog(
          context: context,
          barrierDismissible: true,
          builder: (BuildContext context) {
            return new SimpleDialog(
              backgroundColor: Colors.white,
              title: new Text(
                'Compose Marker info',
                style: new TextStyle(fontSize: 17.0,color: Colors.black),
              ),
              children: <Widget>[
                new CupertinoTextField(
                  controller: _titleController,

//                  decoration: InputDecoration(
//            hintText: 'Marker title',
//              errorText: _validate1 ? 'Value Can\'t Be Empty' : null,
//            border: InputBorder.none,
//            ),
                placeholder: 'Marker title',



                  onChanged: (String enteredLoc) {
                    setState(() {
                      inputaddr = enteredLoc;
                    });
                  },
                ),

            new CupertinoTextField(
              controller: _descriptionController,

//              decoration: InputDecoration(
//            hintText: 'Marker message', errorText: _validate2 ? 'Value Can\'t Be Empty' : null,
//            border: InputBorder.none,
//            ),
            placeholder: 'Marker message',

            ),


                new SimpleDialogOption(
                  child: new Text('Add Marker',
                      style: new TextStyle(color: Colors.black)),
                  onPressed: () {
                    if(_titleController != null|| _descriptionController != null){

                    setState(() {
                      _titleController.text.isEmpty ? _validate1 = true : _validate1 = false;
                      _descriptionController.text.isEmpty ? _validate2 = true : _validate2 = false;
                    });

            if (_titleController.text.isEmpty == false && _descriptionController.text.isEmpty == false  ) {
              addToList(lat, long);


              Navigator.of(context).pop();

            }
                    }
                    else
                      {
                        Toast.show("Fill in all entry fields.", context, duration: Toast.LENGTH_SHORT, gravity:  Toast.TOP);

                        print("empty fields");
                      }
                  },
                )
              ],
            );
          });
    re_InitilizeMap();

}

}

