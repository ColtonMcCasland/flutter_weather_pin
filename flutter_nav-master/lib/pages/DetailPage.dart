import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:f_nav/weather_request.dart';
import 'package:weather_icons/weather_icons.dart';


class SecondPage extends StatefulWidget
{

  final title;
  final lat,long;

  SecondPage({@required this.title, this.lat, this.long});

  @override
  SecondPageState createState() => SecondPageState(title: title, lat: lat, long: long);

}



class SecondPageState extends State<SecondPage> {


  SecondPageState(
      {@required this.title, this.lat, this.long}
      );

  Widget _body;
  var cardIcon;

  final title;
  final lat,long;

  var condition;
  final apiKey = 'c287f389370cfc2c227abf41d002858d';


  @override
  void initState()
  {
    _body = CupertinoActivityIndicator();

    condition = "";
    super.initState();
  }



@override
  Widget build(BuildContext context) {

  var cardIcon;
  // init card color
  var cardColor;

  _body = BodyWidget();

  //  Conditions for card icons and color from OpenWeatherMap
  if (condition.isNotEmpty && condition.length != 0) {

//                    SKY
    if (condition == "clear sky") {
      cardIcon = Icon(
        WeatherIcons.day_sunny_overcast, color: Colors.black,);
      cardColor = Colors.yellow;
    }

//                    CLOUDS
    else if (condition == "scattered clouds") {
      cardIcon = Icon(
        WeatherIcons.day_cloudy_high, color: Colors.black,);
      cardColor = Colors.grey;
    }
    else if (condition == "few clouds") {
      cardIcon =
          Icon(WeatherIcons.day_cloudy, color: Colors.black,);
      cardColor = Colors.blueGrey;
    }
    else if (condition == "scattered clouds") {
      cardIcon =
          Icon(WeatherIcons.day_cloudy, color: Colors.black,);
      cardColor = Colors.blueGrey;
    }
    else if (condition == "broken clouds") {
      cardIcon =
          Icon(WeatherIcons.day_cloudy, color: Colors.black,);
      cardColor = Colors.blueGrey;
    }
    else if (condition == "overcast clouds") {
      cardIcon = Icon(
        WeatherIcons.day_cloudy_gusts, color: Colors.black,);
      cardColor = Colors.grey;
    }

//                    THUNDERSTORM
    else if (condition == "thunderstorm with light rain") {
      cardIcon = Icon(WeatherIcons.day_thunderstorm, color: Colors
          .black,);
      cardColor = Colors.blueAccent;
    }
    else if (condition == "thunderstorm with rain") {
      cardIcon = Icon(WeatherIcons.day_thunderstorm, color: Colors
          .black,);
      cardColor = Colors.blueAccent;
    }
    else if (condition == "thunderstorm with heavy rain") {
      cardIcon = Icon(WeatherIcons.day_thunderstorm, color: Colors
          .black,);
      cardColor = Colors.blueAccent;
    }
    else if (condition == "light thunderstorm") {
      cardIcon = Icon(WeatherIcons.day_thunderstorm, color: Colors
          .black,);
      cardColor = Colors.blueAccent;
    }
    else if (condition == "thunderstorm") {
      cardIcon = Icon(WeatherIcons.day_thunderstorm, color: Colors
          .black,);
      cardColor = Colors.blueAccent;
    }
    else if (condition == "heavy thunderstorm") {
      cardIcon = Icon(WeatherIcons.day_thunderstorm, color: Colors
          .black,);
      cardColor = Colors.blueAccent;
    }
    else if (condition == "ragged thunderstorm") {
      cardIcon = Icon(WeatherIcons.day_thunderstorm, color: Colors
          .black,);
      cardColor = Colors.blueAccent;
    }
    else if (condition == "thunderstorm with light drizzle") {
      cardIcon = Icon(WeatherIcons.day_thunderstorm, color: Colors
          .black,);
      cardColor = Colors.blueAccent;
    }
    else if (condition == "thunderstorm with drizzle") {
      cardIcon = Icon(WeatherIcons.day_thunderstorm, color: Colors
          .black,);
      cardColor = Colors.blueAccent;
    }
    else if (condition == "thunderstorm with heavy drizzle") {
      cardIcon = Icon(WeatherIcons.day_thunderstorm, color: Colors
          .black,);
      cardColor = Colors.blueAccent;
    }





//                    DRIZZLE
    else if (condition == "light intensity drizzle") {
      cardIcon = Icon(WeatherIcons.day_rain, color: Colors
          .black,);
      cardColor = Colors.blueAccent;
    }
    else if (condition == "drizzle") {
      cardIcon = Icon(WeatherIcons.day_rain, color: Colors
          .black,);
      cardColor = Colors.blueAccent;
    }
    else if (condition == "heavy intensity drizzle") {
      cardIcon = Icon(WeatherIcons.day_rain, color: Colors
          .black,);
      cardColor = Colors.blueAccent;
    }
    else if (condition == "light intensity drizzle rain") {
      cardIcon = Icon(WeatherIcons.day_rain, color: Colors
          .black,);
      cardColor = Colors.blueAccent;
    }
    else if (condition == "drizzle rain") {
      cardIcon = Icon(WeatherIcons.day_rain, color: Colors
          .black,);
      cardColor = Colors.blueAccent;
    }
    else if (condition == "heavy intensity drizzle rain") {
      cardIcon = Icon(WeatherIcons.day_rain, color: Colors
          .black,);
      cardColor = Colors.blueAccent;
    }
    else if (condition == "shower rain and drizzle") {
      cardIcon = Icon(WeatherIcons.day_rain, color: Colors
          .black,);
      cardColor = Colors.blueAccent;
    }
    else if (condition == "heavy shower rain and drizzle") {
      cardIcon = Icon(WeatherIcons.day_rain, color: Colors
          .black,);
      cardColor = Colors.blueAccent;
    }
    else if (condition == "shower drizzle") {
      cardIcon = Icon(WeatherIcons.day_rain, color: Colors
          .black,);
      cardColor = Colors.blueAccent;
    }



//                    RAIN
    else if (condition == "rain") {
      cardIcon = Icon(WeatherIcons.day_rain, color: Colors
          .black,);
      cardColor = Colors.blueAccent;
    }
    else if (condition == "light rain") {
      cardIcon = Icon(WeatherIcons.day_rain, color: Colors
          .black,);
      cardColor = Colors.blue;
    }
    else if (condition == "moderate rain") {
      cardIcon = Icon(WeatherIcons.day_rain, color: Colors
          .black,);
      cardColor = Colors.blue;
    }
    else if (condition == "heavy intensity rain") {
      cardIcon = Icon(WeatherIcons.day_rain, color: Colors
          .black,);
      cardColor = Colors.blue;
    }
    else if (condition == "very heavy rain") {
      cardIcon = Icon(WeatherIcons.day_rain, color: Colors
          .black,);
      cardColor = Colors.blue;
    }
    else if (condition == "extreme rain") {
      cardIcon = Icon(WeatherIcons.day_rain, color: Colors
          .black,);
      cardColor = Colors.blue;
    }

    else if (condition == "light intensity shower rain") {
      cardIcon = Icon(WeatherIcons.day_rain, color: Colors
          .black,);
      cardColor = Colors.blue;
    }

    else if (condition == " shower rain") {
      cardIcon = Icon(WeatherIcons.day_rain, color: Colors
          .black,);
      cardColor = Colors.blue;
    }
    else if (condition == "heavy intensity shower rain") {
      cardIcon = Icon(WeatherIcons.day_rain, color: Colors
          .black,);
      cardColor = Colors.blue;
    }
    else if (condition == "ragged shower rain") {
      cardIcon = Icon(WeatherIcons.day_rain, color: Colors
          .black,);
      cardColor = Colors.blue;
    }

    else if (condition == "freezing rain") {
      cardIcon = Icon(WeatherIcons.day_rain, color: Colors
          .black,);
      cardColor = Colors.lightBlueAccent;
    }


    else if (condition == "thunderstorm") {
      cardIcon = Icon(WeatherIcons.day_thunderstorm,
        color: Colors.black,);
      cardColor = Colors.lightBlueAccent;
    }

    else if (condition == "snow") {
      cardIcon = Icon(
        WeatherIcons.day_snow, color: Colors.black,);
      cardColor = Colors.lime;
    }
    else if (condition == "light snow") {
      cardIcon = Icon(
        WeatherIcons.day_snow, color: Colors.black,);
      cardColor = Colors.white30;
    }

    else if (condition == "mist") {
      cardIcon =
          Icon(WeatherIcons.day_fog, color: Colors.black,);
      cardColor = Colors.teal;
    }

    else {
      cardIcon = Icon(Icons.error, color: Colors.red,);
    }
  }



    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text("Detail page"),
        ),
      backgroundColor: cardColor,

        child: Center(
          child: Column(


              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,

              children: <Widget>[
                Material(
                  child: SizedBox(
                    child: Text(title, style: TextStyle(color: Colors.black, fontSize:  40, ),),

                  ),

                ),
                _body,
                SizedBox(
                  width: 100,
                  height: 100,
                  child: cardIcon,
                )


              ]),
        ));
  }

  Widget BodyWidget()
  {


      getDataWeather(lat, long);

      return Material(
        child: Text(condition ?? "", style: TextStyle(color: CupertinoColors.black),),
      );

  }


  double latitude;
  double longitude;


  getDataWeather(latitude,longitude) async {

    WeatherRequest weatherRequest = WeatherRequest(
        'https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&units=metric&appid=$apiKey');
    var weatherdata = await weatherRequest.getData();


    var whole = weatherdata["weather"][0]['description'];


    setState(() {

      condition = whole.toString();
      return condition;
    });

    return whole.toString();

  }



}