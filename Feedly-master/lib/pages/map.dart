//import 'package:flutter/material.dart';
//import 'package:google_maps_flutter/google_maps_flutter.dart';
//
//import 'package:location/location.dart';
//
//import 'package:geoflutterfire/geoflutterfire.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:rxdart/rxdart.dart';
//import 'dart:async';
//
/////----------------------------------------
//class FireMap extends StatefulWidget {
//  static const String routeName = "/fireMap";
//
//  State createState() => FireMapState();
//}
//
//final clients = [];
//final Set<Marker> markers = {};
//
//class FireMapState extends State<FireMap> {
//  _SimpleLiveMapPageState() {
//    mapController = MapController();
//    liveMapController = LiveMapController(mapController: mapController);
//  }
//
//  MapController mapController;
//  LiveMapController liveMapController;
//
//  @override
//  void dispose() {
//    liveMapController.dispose();
//    super.dispose();
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    return Scaffold(
//      body: LiveMap(
//        mapController: mapController,
//        liveMapController: liveMapController,
//        mapOptions: MapOptions(
//          center: LatLng(51.0, 0.0),
//          zoom: 17.0,
//        ),
//        titleLayer: TileLayerOptions(
//            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
//            subdomains: ['a', 'b', 'c']),
//      ),
//    );
//  }
//
//}
