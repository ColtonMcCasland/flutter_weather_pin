
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

class weatherPage extends StatefulWidget {
  static const String routeName = '/weather';




  @override
  weatherNewsPage createState() => weatherNewsPage();
}

class weatherNewsPage extends State<weatherPage> {

  String _res = 'Unknown';
  String key = '12b6e28582eb9298577c734a31ba9f4f';
  WeatherStation ws;

  @override
  void initState() {
    super.initState();
    ws = new WeatherStation(key);
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    queryWeather();
  }

  void queryForecast() async {
    List<Weather> f = await ws.fiveDayForecast();
    setState(() {
      _res = f.toString();
    });
  }

  void queryWeather() async {
    Weather w = await ws.currentWeather();
    setState(() {
      _res = w.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("Weather API Example"),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                _res,
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(onPressed: queryWeather, child: Icon(Icons.cloud_download)),
      ),
    );
  }
}