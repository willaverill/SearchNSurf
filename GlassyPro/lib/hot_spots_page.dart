import 'package:GlassyPro/spot_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:latlong/latlong.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'authentication.dart';

class HotSpotsPage extends StatefulWidget {
  @override
  _HotSpotsAppState createState() => _HotSpotsAppState();
}

Future<DocumentSnapshot> set() async {
  FirebaseUser user = await Auth().getCurrentUser();
  DocumentSnapshot ds = await Firestore.instance
      .collection('settings')
      .document(user.uid)
      .get();
  return ds;
}

class _HotSpotsAppState extends State<HotSpotsPage> {
  final Distance distance = new Distance();
  var _currentPosition = new LatLng(0.0, 0.0);
  var latitude = 0.0;
  var longitude = 0.0;
  var spotLatLng = "";
  Map<String, Spot> localSpots = new Map();
  Map<String, Spot> localSpotsSorted = new Map();
  var localSpotsList;

  RefreshController _refreshController = RefreshController(initialRefresh: false);

  void _onRefresh() async{
    await Future.delayed(Duration(milliseconds: 1000));
    setState(() {
      Auth().getCurrentUser().then((FirebaseUser user) {
        set().then((DocumentSnapshot ds) {
          Firestore.instance.collection("current_location")
              .getDocuments()
              .then((querySnapshot) {
            querySnapshot.documents.forEach((document) {
              if (document.data["uid"] == user.uid) {
                _currentPosition =
                new LatLng(
                    document.data["latitude"], document.data["longitude"]);
                print("$_currentPosition");
                Firestore.instance.collection("surf_spots")
                    .getDocuments()
                    .then((querySnapshot) {
                  querySnapshot.documents.forEach((document) {
                    if (document.data["spot_two_name"] != "" &&
                        document.data["spot_two_name"] != null &&
                        document.data["spot_two_lat_lng"] != "" &&
                        document.data["spot_two_lat_lng"] != null) {
                      spotLatLng = document.data["spot_two_lat_lng"];
                      var latLng = document.data["spot_two_lat_lng"].split(
                          "\n");
                      if (latLng.length == 3) {
                        var tempLat = latLng[0].replaceAll("Latitude: ", "");
                        var tempLng = latLng[2].replaceAll("Longitude: ", "");
                        if (tempLat.contains("N")) {
                          tempLat = tempLat.replaceAll("N", "");
                          var lat = tempLat.split(" ");
                          lat[0] = lat[0].replaceAll("°", "");
                          lat[1] = lat[1].replaceAll("'", "");
                          latitude =
                              double.parse(lat[0]) + (double.parse(lat[1]) /
                                  60.0);
                        } else if (tempLat.contains("S")) {
                          tempLat = tempLat.replaceAll("S", "");
                          var lat = tempLat.split(" ");
                          lat[0] = lat[0].replaceAll("°", "");
                          lat[1] = lat[1].replaceAll("'", "");
                          latitude = 0.0 -
                              (double.parse(lat[0]) + (double.parse(lat[1]) /
                                  60.0));
                        }
                        if (tempLng.contains("E")) {
                          tempLng = tempLng.replaceAll("E", "");
                          var lng = tempLng.split(" ");
                          lng[4] = lng[4].replaceAll("°", "");
                          lng[5] = lng[5].replaceAll("'", "");
                          longitude =
                              double.parse(lng[4]) +
                                  (double.parse(lng[5]) / 60.0);
                        } else if (tempLng.contains("W")) {
                          tempLng = tempLng.replaceAll("W", "");
                          var lng = tempLng.split(" ");
                          lng[4] = lng[4].replaceAll("°", "");
                          lng[5] = lng[5].replaceAll("'", "");
                          longitude = 0.0 -
                              (double.parse(lng[4]) + (double.parse(lng[5]) /
                                  60.0));
                        }
                        if (ds['wave_height']) {
                          var distanceInMiles = distance.as(
                              LengthUnit.Mile,
                              new LatLng(latitude, longitude),
                              _currentPosition);
                          if (distanceInMiles <= 25.0) {
                            setState(() {
                              print([document.data["spot_two_name"]]);
                              localSpots[document.data["spot_two_name"]] =
                              new Spot(spotLatLng, distanceInMiles);
                              localSpotsSorted = Map.fromEntries(
                                  localSpots.entries.toList()
                                    ..sort((e1, e2) =>
                                        e1.value.getDistance().compareTo(
                                            e2.value.getDistance())));
                              localSpotsList = ListView.builder(
                                  itemCount: localSpotsSorted.length,
                                  itemBuilder: (context, index) {
                                    return ListTile(
                                      title: Text(
                                          localSpotsSorted.keys.elementAt(
                                              index)),
                                      subtitle: Text(
                                          localSpotsSorted.values
                                              .elementAt(index)
                                              .distance
                                              .toString() + " Miles"),
                                      leading: Icon(Icons.place),
                                      trailing: Icon(Icons.arrow_forward_ios),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (
                                              context) =>
                                              SpotPage(
                                                  spotLatLng: localSpotsSorted
                                                      .values.elementAt(index)
                                                      .getLatLng())),
                                        );
                                      },
                                    );
                                  });
                            });
                          }
                        } else {
                          var distanceInKilometers = distance.as(
                              LengthUnit.Kilometer,
                              new LatLng(latitude, longitude),
                              _currentPosition);
                          if (distanceInKilometers <= 25.0) {
                            setState(() {
                              print([document.data["spot_two_name"]]);
                              localSpots[document.data["spot_two_name"]] =
                              new Spot(spotLatLng, distanceInKilometers);
                              localSpotsSorted = Map.fromEntries(
                                  localSpots.entries.toList()
                                    ..sort((e1, e2) =>
                                        e1.value.getDistance().compareTo(
                                            e2.value.getDistance())));
                              localSpotsList = ListView.builder(
                                  itemCount: localSpotsSorted.length,
                                  itemBuilder: (context, index) {
                                    return ListTile(
                                      title: Text(
                                          localSpotsSorted.keys.elementAt(
                                              index)),
                                      subtitle: Text(
                                          localSpotsSorted.values
                                              .elementAt(index)
                                              .distance
                                              .toString() + " Kilometers"),
                                      leading: Icon(Icons.place),
                                      trailing: Icon(Icons.arrow_forward_ios),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (
                                              context) =>
                                              SpotPage(
                                                  spotLatLng: localSpotsSorted
                                                      .values.elementAt(index)
                                                      .getLatLng())),
                                        );
                                      },
                                    );
                                  });
                            });
                          }
                        }
                      }
                    }
                  });
                });
              }
            });
          });
        });
      });
    });
    _refreshController.refreshCompleted();
  }

  void _onLoading() async{
    await Future.delayed(Duration(milliseconds: 1000));
    _refreshController.loadComplete();
  }

  @override
  void initState() {
    setState(() {
      Auth().getCurrentUser().then((FirebaseUser user) {
        set().then((DocumentSnapshot ds) {
          Firestore.instance.collection("current_location")
              .getDocuments()
              .then((querySnapshot) {
            querySnapshot.documents.forEach((document) {
              if (document.data["uid"] == user.uid) {
                _currentPosition =
                new LatLng(
                    document.data["latitude"], document.data["longitude"]);
                print("$_currentPosition");
                Firestore.instance.collection("surf_spots")
                    .getDocuments()
                    .then((querySnapshot) {
                  querySnapshot.documents.forEach((document) {
                    if (document.data["spot_two_name"] != "" &&
                        document.data["spot_two_name"] != null &&
                        document.data["spot_two_lat_lng"] != "" &&
                        document.data["spot_two_lat_lng"] != null) {
                      spotLatLng = document.data["spot_two_lat_lng"];
                      var latLng = document.data["spot_two_lat_lng"].split(
                          "\n");
                      if (latLng.length == 3) {
                        var tempLat = latLng[0].replaceAll("Latitude: ", "");
                        var tempLng = latLng[2].replaceAll("Longitude: ", "");
                        if (tempLat.contains("N")) {
                          tempLat = tempLat.replaceAll("N", "");
                          var lat = tempLat.split(" ");
                          lat[0] = lat[0].replaceAll("°", "");
                          lat[1] = lat[1].replaceAll("'", "");
                          latitude =
                              double.parse(lat[0]) + (double.parse(lat[1]) /
                                  60.0);
                        } else if (tempLat.contains("S")) {
                          tempLat = tempLat.replaceAll("S", "");
                          var lat = tempLat.split(" ");
                          lat[0] = lat[0].replaceAll("°", "");
                          lat[1] = lat[1].replaceAll("'", "");
                          latitude = 0.0 -
                              (double.parse(lat[0]) + (double.parse(lat[1]) /
                                  60.0));
                        }
                        if (tempLng.contains("E")) {
                          tempLng = tempLng.replaceAll("E", "");
                          var lng = tempLng.split(" ");
                          lng[4] = lng[4].replaceAll("°", "");
                          lng[5] = lng[5].replaceAll("'", "");
                          longitude =
                              double.parse(lng[4]) +
                                  (double.parse(lng[5]) / 60.0);
                        } else if (tempLng.contains("W")) {
                          tempLng = tempLng.replaceAll("W", "");
                          var lng = tempLng.split(" ");
                          lng[4] = lng[4].replaceAll("°", "");
                          lng[5] = lng[5].replaceAll("'", "");
                          longitude = 0.0 -
                              (double.parse(lng[4]) + (double.parse(lng[5]) /
                                  60.0));
                        }
                        if (ds['wave_height']) {
                          var distanceInMiles = distance.as(
                              LengthUnit.Mile, new LatLng(latitude, longitude),
                              _currentPosition);
                          if (distanceInMiles <= 25.0) {
                            setState(() {
                              print([document.data["spot_two_name"]]);
                              localSpots[document.data["spot_two_name"]] =
                              new Spot(spotLatLng, distanceInMiles);
                              localSpotsSorted = Map.fromEntries(
                                  localSpots.entries.toList()
                                    ..sort((e1, e2) =>
                                        e1.value.getDistance().compareTo(
                                            e2.value.getDistance())));
                              localSpotsList = ListView.builder(
                                  itemCount: localSpotsSorted.length,
                                  itemBuilder: (context, index) {
                                    return ListTile(
                                      title: Text(
                                          localSpotsSorted.keys.elementAt(
                                              index)),
                                      subtitle: Text(
                                          localSpotsSorted.values
                                              .elementAt(index)
                                              .distance
                                              .toString() + " Miles"),
                                      leading: Icon(Icons.place),
                                      trailing: Icon(Icons.arrow_forward_ios),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (
                                              context) => SpotPage(
                                              spotLatLng: localSpotsSorted
                                                  .values.elementAt(index)
                                                  .getLatLng())),
                                        );
                                      },
                                    );
                                  });
                            });
                          }
                        } else {
                          var distanceInKilometers = distance.as(
                              LengthUnit.Kilometer,
                              new LatLng(latitude, longitude),
                              _currentPosition);
                          if (distanceInKilometers <= 25.0) {
                            setState(() {
                              print([document.data["spot_two_name"]]);
                              localSpots[document.data["spot_two_name"]] =
                              new Spot(spotLatLng, distanceInKilometers);
                              localSpotsSorted = Map.fromEntries(
                                  localSpots.entries.toList()
                                    ..sort((e1, e2) =>
                                        e1.value.getDistance().compareTo(
                                            e2.value.getDistance())));
                              localSpotsList = ListView.builder(
                                  itemCount: localSpotsSorted.length,
                                  itemBuilder: (context, index) {
                                    return ListTile(
                                      title: Text(
                                          localSpotsSorted.keys.elementAt(
                                              index)),
                                      subtitle: Text(
                                          localSpotsSorted.values
                                              .elementAt(index)
                                              .distance
                                              .toString() + " Kilometers"),
                                      leading: Icon(Icons.place),
                                      trailing: Icon(Icons.arrow_forward_ios),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (
                                              context) => SpotPage(
                                              spotLatLng: localSpotsSorted
                                                  .values.elementAt(index)
                                                  .getLatLng())),
                                        );
                                      },
                                    );
                                  });
                            });
                          }
                        }
                      }
                    }
                  });
                });
              }
            });
          });
        });
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Hot Spots'),
        backgroundColor: Colors.cyan,),
      body: SmartRefresher(
        enablePullDown: true,
        enablePullUp: true,
        header: WaterDropHeader(),
        controller: _refreshController,
        onRefresh: _onRefresh,
        onLoading: _onLoading,
        child: localSpotsList,
      ),
    );
  }
}

class Spot {
  final String latLng;
  final double distance;

  Spot(this.latLng, this.distance);

  getLatLng() {
    return this.latLng;
  }

  getDistance() {
    return this.distance;
  }
}