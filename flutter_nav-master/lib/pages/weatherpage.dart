
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:weather/weather.dart';
import '../widgets/drawer.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

//SOURCES:
// OPENWEATHER API: https://openweathermap.org/forecast5
//Example for openWeathermap flutter application:  https://medium.com/@timbergus/lets-create-the-simplest-weather-app-with-flutter-eb4bc3da20c9


//TODO: have API call info via Latitude and Longitude coords.
//TODO: have each marker lat and long passed to the openweather query and create tiles for a list view of all the marker locations current weather.
//api key: 34cd503973bce95c2e833573eb0d9561

class weatherPage extends StatelessWidget {
  static const String routeName = '/weather';


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(
        title: Text("Map"),
      ),
      body: new weatherNews(),
    );
  }

  @override
  _weatherNewsPageState createState() => _weatherNewsPageState();
}

class weatherNewsPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(
        title: Text("Map"),
      ),
      body: new weatherNews(),
    );
  }

}

class weatherNews extends StatefulWidget {
  @override
  State<weatherNews> createState() => _weatherNewsPageState();
}

class _weatherNewsPageState extends State<weatherNews> {
 String _locality = '';
  String _weather = '';

  Future<Position> getPosition() async {
    Position position = await Geolocator()
      .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    return position;
  }

  Future<Placemark> getPlacemark(double latitude, double longitude) async {
    List<Placemark> placemark = await Geolocator()
      .placemarkFromCoordinates(latitude, longitude);
    return placemark[0];
  }

  Future<String> getData(double latitude, double longitude) async {
    String api = 'http://api.openweathermap.org/data/2.5/forecast';
    String appId = '34cd503973bce95c2e833573eb0d9561';

    String url = '$api?lat=$latitude&lon=$longitude&APPID=$appId';

    http.Response response = await http.get(url);

    Map parsed = json.decode(response.body);

    return parsed['list'][0]['weather'][0]['description'];
  }

  @override
  void initState() {
    super.initState();
    getPosition().then((position) {
      getPlacemark(position.latitude, position.longitude).then((data) {
        getData(position.latitude, position.longitude).then((weather) {
          setState(() {
            _locality = data.locality;
            _weather = weather;
          });
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Weather App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              '$_locality',
              style: Theme.of(context).textTheme.display1,
            ),
            Text(
              '$_weather',
              style: Theme.of(context).textTheme.display1,
            ),
          ],
        ),
      ),
    );
  }
}