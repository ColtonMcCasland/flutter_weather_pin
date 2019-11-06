import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';


///----------------------------------------
// Documentation on geo markers query from firestore
// https://libraries.io/pub/geoflutterfire
///----------------------------------------


class FireMap extends StatefulWidget {
  static const String routeName = "/fireMap";

  @override
  FireMapState createState() => FireMapState();
}


class FireMapState extends State<FireMap> {
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

  GoogleMapController _controller;
  bool dialVisible = true;

  Position position;
  Widget _map;
  Widget _list;





  @override
  void initState() {
    _map=SpinKitCubeGrid(color: Colors.white, size: 50.0, );
    getCurrentLocation();
    populateClients();
    super.initState();

  }

  void setDialVisible(bool value) {
    setState(() {
      dialVisible = value;
    });
  }

  SpeedDial buildSpeedDial() {
    return SpeedDial(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      animatedIcon: AnimatedIcons.menu_close,
      animatedIconTheme: IconThemeData(size: 22.0),
      // child: Icon(Icons.add),
      onOpen: () => print('OPENING DIAL'),
      onClose: () => print('DIAL CLOSED'),
      visible: dialVisible,
      curve: Curves.bounceIn,
      children: [
        SpeedDialChild(
          child: Icon(Icons.center_focus_weak, color: Colors.white),
          backgroundColor: Colors.pink,
          onTap: ()
          {

          },
          label: 'Button 1',
          labelStyle: TextStyle(fontWeight: FontWeight.w500),
          labelBackgroundColor: Colors.pink,
        ),
        SpeedDialChild(
          child: Icon(Icons.zoom_out, color: Colors.white),
          backgroundColor: Colors.blue,
          onTap: ()
          {

          },
          label: 'Button 2',
          labelStyle: TextStyle(fontWeight: FontWeight.w500),
          labelBackgroundColor: Colors.blue,
        ),
        SpeedDialChild(
          child: Icon(Icons.zoom_in, color: Colors.white),
          backgroundColor: Colors.green,
          onTap: ()
          {

          },
          label: 'Button 3',
          labelStyle: TextStyle(fontWeight: FontWeight.w500),
          labelBackgroundColor: Colors.green,
        ),

      ],
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



  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
//    show both lists

    return Scaffold(
      backgroundColor: Colors.amber,
      appBar: AppBar(
        elevation: 0.0,
        title: Text("Posts page"),),
      body: ClipRRect(
        borderRadius: new BorderRadius.only(
          topLeft: const Radius.circular(40.0),
          topRight: const Radius.circular(40.0),

        ),

        child:
        Column( // parent ListView
          children: <Widget>[

            Container(
              height: 500, // give it a fixed height constraint
              color: Colors.white,
              // child ListView

              child: _map,
            ),

            Container(
//              list info
              child: Text("Current coordinates: " + _lat.toString() + " & "+ _lng.toString(),  ),
            ),
            Container(
//              empty space. perhaps list markers.
            ),



          ],
        ),
      ),
      floatingActionButton: buildSpeedDial(),
    );
  }

  Widget mapWidget(){
return GoogleMap(
    mapType: MapType.normal,
    markers:
    Set<Marker>.of(markers.values),
    initialCameraPosition: CameraPosition(
    target: LatLng(position.latitude, position.longitude),
    zoom: 10.0,
    ),
    onMapCreated: (GoogleMapController controller) {
    _controller = controller;

      },

//    onTap: ,



    );
  }

  Widget markerListWidget(){
    return ListView(
      children: <Widget>[
        ListTile(
          leading: Icon(Icons.map),
          title: Text('Map'),
        ),
        ListTile(
          leading: Icon(Icons.photo_album),
          title: Text('Album'),
        ),
        ListTile(
          leading: Icon(Icons.phone),
          title: Text('Phone'),
        ),
      ],
    );
  }





  List<Placemark> placemark;
  String _address;
  void getAddress(double latitude, double longitude) async {
    placemark = await Geolocator().placemarkFromCoordinates(latitude, longitude);
    _address = placemark[0].name.toString() + "," + placemark[0].locality.toString() + ", Postal Code:" + placemark[0].postalCode.toString();
    setState(() {

      _map = mapWidget();

    });
  }

  Set<Marker> _createMarker( ) {
    return <Marker>[
      Marker(
        markerId: MarkerId("home"),
        position: LatLng(position.latitude,position.longitude),
        icon: BitmapDescriptor.defaultMarker,
        infoWindow: InfoWindow(title:"Home", snippet: position.latitude.toString() + ' ' + position.longitude.toString()),
      ),
    ].toSet();
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
      markers[markerId] = marker;
      print(markerId);
    });
  }

  populateClients() {
    print('poplulating...');

    Firestore.instance.collection('test').getDocuments().then((docs) {
      if ( docs.documents.isNotEmpty) {
        for(int i = 0; i < docs.documents.length; i++){
          print('created marker');
          initMarker(docs.documents[i].data, docs.documents[i].documentID);
        }
      }
    });
  }



}
