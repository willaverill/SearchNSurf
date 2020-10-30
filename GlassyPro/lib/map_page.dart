import 'dart:developer';
import 'package:GlassyPro/spot_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

import 'authentication.dart';
import 'custom_search_delegate.dart';

class MapPage extends StatefulWidget {
  @override
  _MapAppState createState() => _MapAppState();
}

class _MapAppState extends State<MapPage> {
  LatLng _currentPosition;
  BitmapDescriptor mapIcon;
  List<Marker> spots = [];
  var latitude = 0.0;
  var longitude = 0.0;
  var firestoreInstance = Firestore.instance;
  var searchBar;
  var searchResult = "";
  var _mapController;

  Future<void> _onMapCreated(GoogleMapController controller) async {
    setState(() {
      _mapController = controller;
    });
  }

  _searchForSpot(BuildContext context) async {
    searchResult = await showSearch(
      context: context,
      delegate: CustomSearchDelegate(),
    );
    setState(() {
      _getCurrentLocation();
    });
  }

  @override
  void initState() {
    setState(() {
      _getCurrentLocation();
      BitmapDescriptor.fromAssetImage(
          ImageConfiguration(size: Size(12, 12)), 'assets/images/marker.png')
          .then((onValue) {
        mapIcon = onValue;
      });
      spots.clear();
      firestoreInstance.collection("surf_spots").getDocuments().then((querySnapshot) {
        querySnapshot.documents.forEach((document) {
          if (document.data["spot_two_name"] != "" && document.data["spot_two_name"] != null  && document.data["spot_two_lat_lng"] != "" && document.data["spot_two_lat_lng"] != null) {
            var latLng = document.data["spot_two_lat_lng"].split("\n");
            if (latLng.length == 3) {
              var tempLat = latLng[0].replaceAll("Latitude: ", "");
              var tempLng = latLng[2].replaceAll("Longitude: ", "");
              if (tempLat.contains("N")) {
                tempLat = tempLat.replaceAll("N", "");
                var lat = tempLat.split(" ");
                lat[0] = lat[0].replaceAll("°", "");
                lat[1] = lat[1].replaceAll("'", "");
                latitude = double.parse(lat[0]) + (double.parse(lat[1]) / 60.0);
              } else if (tempLat.contains("S")) {
                tempLat = tempLat.replaceAll("S", "");
                var lat = tempLat.split(" ");
                lat[0] = lat[0].replaceAll("°", "");
                lat[1] = lat[1].replaceAll("'", "");
                latitude = 0.0 -
                    (double.parse(lat[0]) + (double.parse(lat[1]) / 60.0));
              }
              if (tempLng.contains("E")) {
                tempLng = tempLng.replaceAll("E", "");
                var lng = tempLng.split(" ");
                lng[4] = lng[4].replaceAll("°", "");
                lng[5] = lng[5].replaceAll("'", "");
                longitude =
                    double.parse(lng[4]) + (double.parse(lng[5]) / 60.0);
              } else if (tempLng.contains("W")) {
                tempLng = tempLng.replaceAll("W", "");
                var lng = tempLng.split(" ");
                lng[4] = lng[4].replaceAll("°", "");
                lng[5] = lng[5].replaceAll("'", "");
                longitude = 0.0 -
                    (double.parse(lng[4]) + (double.parse(lng[5]) / 60.0));
              }
              //log(document.data["spot_two_name"]);
              //log("$latitude");
              //log("$longitude");
              final marker = Marker(
                markerId: MarkerId(document.data["spot_two_name"]),
                position: LatLng(latitude, longitude),
                icon: mapIcon,
                infoWindow: InfoWindow(
                  title: document.data["spot_two_name"],
                  snippet: "Tap to view forecast!",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SpotPage(spotLatLng: document.data["spot_two_lat_lng"])),
                    );
                  },
                ),
              );
              spots.add(marker);
            }
          }
        });
      });
    });
    searchBar = AppBar(
      title: Text("Map"),
      backgroundColor: Colors.cyan,
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.search),
          onPressed: () {
            _searchForSpot(context);
          },
        ),
      ],
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: searchBar,
      body: Column(
        children: <Widget>[
          Expanded(
            child: GoogleMap(
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _currentPosition,
                zoom: 11.0,
              ),
              markers: Set.from(spots),
            ),
          ),
        ],
      ) ,
    );
  }
  _getCurrentLocation() {
    final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
    geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
      setState(() {
        if (searchResult == "") {
          Auth().getCurrentUser().then((FirebaseUser user) {
            _currentPosition = LatLng(position.latitude, position.longitude);
            Firestore.instance.
            collection('current_location').
            document(user.uid).
            setData({'uid': user.uid, 'latitude': _currentPosition.latitude, 'longitude': _currentPosition.longitude}, merge: true);
          });
        } else {
          log(searchResult);
          var latLng = searchResult.split("\n");
          if (latLng.length == 3) {
            var tempLat = latLng[0].replaceAll("Latitude: ", "");
            var tempLng = latLng[2].replaceAll("Longitude: ", "");
            if (tempLat.contains("N")) {
              tempLat = tempLat.replaceAll("N", "");
              var lat = tempLat.split(" ");
              lat[0] = lat[0].replaceAll("°", "");
              lat[1] = lat[1].replaceAll("'", "");
              latitude = double.parse(lat[0]) + (double.parse(lat[1]) / 60.0);
            } else if (tempLat.contains("S")) {
              tempLat = tempLat.replaceAll("S", "");
              var lat = tempLat.split(" ");
              lat[0] = lat[0].replaceAll("°", "");
              lat[1] = lat[1].replaceAll("'", "");
              latitude = 0.0 -
                  (double.parse(lat[0]) + (double.parse(lat[1]) / 60.0));
            }
            if (tempLng.contains("E")) {
              tempLng = tempLng.replaceAll("E", "");
              var lng = tempLng.split(" ");
              lng[4] = lng[4].replaceAll("°", "");
              lng[5] = lng[5].replaceAll("'", "");
              longitude =
                  double.parse(lng[4]) + (double.parse(lng[5]) / 60.0);
            } else if (tempLng.contains("W")) {
              tempLng = tempLng.replaceAll("W", "");
              var lng = tempLng.split(" ");
              lng[4] = lng[4].replaceAll("°", "");
              lng[5] = lng[5].replaceAll("'", "");
              longitude = 0.0 -
                  (double.parse(lng[4]) + (double.parse(lng[5]) / 60.0));
            }
            _currentPosition = LatLng(latitude, longitude);
            log("$_currentPosition");
            _mapController.moveCamera(CameraUpdate.newLatLng(_currentPosition));
          }
        }
      });
    }).catchError((e) {
      print(e);
    });
  }
}