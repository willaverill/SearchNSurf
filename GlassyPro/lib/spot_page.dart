import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'authentication.dart';

class SpotPage extends StatefulWidget {
  final String spotLatLng;
  SpotPage ({ Key key, this.spotLatLng }): super(key: key);

  @override
  _SpotAppState createState() => _SpotAppState(spotLatLng: spotLatLng);
}

Future<Response>getHttpWeather(double lat, double lng) async {
  Response response;
  try {
    response = await Dio().get("https://api.stormglass.io/v2/weather/point?key=d364e3a0-bb0f-11ea-9409-0242ac130002-d364e44a-bb0f-11ea-9409-0242ac130002&lat="+lat.toString()+"&lng="+lng.toString()+"&params=waveHeight,waveDirection,waterTemperature,windSpeed,windDirection,airTemperature");
    print(response);
  } catch (e) {
    print(e);
  }
  return response;
}

Future<Response>getHttpTide(double lat, double lng) async {
  Response response;
  try {
    response = await Dio().get("https://api.stormglass.io/v2/tide/extremes/point?key=d364e3a0-bb0f-11ea-9409-0242ac130002-d364e44a-bb0f-11ea-9409-0242ac130002&lat="+lat.toString()+"&lng="+lng.toString());
    print(response);
  } catch (e) {
    print(e);
  }
  return response;
}

Future<DocumentSnapshot> set() async {
  FirebaseUser user = await Auth().getCurrentUser();
  DocumentSnapshot ds = await Firestore.instance
      .collection('settings')
      .document(user.uid)
      .get();
  return ds;
}

class _SpotAppState extends State<SpotPage> {
  String spotLatLng;
  _SpotAppState({this.spotLatLng});
  Map<String, String> spots = new Map();
  String spotName = "";
  var favoritedSpotCoordinates = '';
  var favorited = false;
  var latitude = 0.0;
  var longitude = 0.0;
  var waveHeight = 0.0;
  var waveDirection = 0.0;
  var waterTemperature = 0.0;
  var windSpeed = 0.0;
  var windDirection = 0.0;
  var airTemperature = 0.0;
  var waveHeightUI = "";
  var waveDirectionUI = "";
  var waterTemperatureUI = "";
  var windSpeedUI = "";
  var windDirectionUI = "";
  var airTemperatureUI = "";
  var tideOne = 0.0;
  var tideOneTime = '';
  var tideTwo = 0.0;
  var tideTwoTime = '';
  var tideThree = 0.0;
  var tideThreeTime = '';
  var tideFour = 0.0;
  var tideFourTime = '';
  var dates = new List(6);
  var waveDirections =  new List(6);
  var waveCharts =  new List(6);
  var windDirections =  new List(6);
  var windCharts =  new List(6);

  @override
  void initState() {
    Auth().getCurrentUser().then((FirebaseUser user) {
      setState(() {
        print("Spot Page Reached...");
        print(this.spotLatLng);
        Firestore.instance
            .collection('surf_spots')
            .where("spot_two_lat_lng", isEqualTo: this.spotLatLng)
            .snapshots()
            .listen((data) =>
            data.documents.forEach((doc) => this.setState(() {
              this.spotName = (doc["spot_two_name"]);})));
        Firestore.instance
            .collection('favorite_spots')
            .where('uid', isEqualTo: user.uid)
            .snapshots()
            .listen((data) =>
            data.documents.forEach((doc) => setState(() {
              favoritedSpotCoordinates = doc['favorited_spot_coordinates'];
              if (favoritedSpotCoordinates.contains(spotLatLng)) {
                favorited = true;
                print(favorited);
              }
            })));
      });
      setState(() {
        var latLng = this.spotLatLng.split("\n");
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
        }
      });
      set().then((DocumentSnapshot ds) {
        getHttpWeather(latitude, longitude).then((Response response) {
          setState(() {
            var initialDateUTC = response.data['hours'][0]['time'];
            var count = 0;
            for (int i = 0; i < response.data['hours'].length; i++) {
              if (response.data['hours'][i]['time'].toString().contains(
                  initialDateUTC)) {
                waveHeight += response.data['hours'][i]['waveHeight']['noaa'];
                waterTemperature +=
                response.data['hours'][i]['waterTemperature']['noaa'];
                windSpeed += response.data['hours'][i]['windSpeed']['noaa'];
                airTemperature +=
                response.data['hours'][i]['airTemperature']['noaa'];
                count++;
              } else {
                break;
              }
              if (ds['wave_height']) {
                waveHeightUI = (waveHeight / count * 3.28084).toStringAsFixed(2) + ' ft';
              } else {
                waveHeightUI = (waveHeight / count).toString() + ' m';
              }
              waveDirectionUI = response.data['hours'][0]['waveDirection']['noaa'].toString() + '°';
              if (ds['temperature']) {
                waterTemperatureUI = ((waterTemperature / count) * (9.0 / 5.0) + 32.0).toStringAsFixed(2) + '°F';
              } else {
                waterTemperatureUI = (waterTemperature / count).toString() + '°C';
              }
              if (ds['wind_speed']) {
                windSpeedUI = ((windSpeed / count) * 2.23694).toStringAsFixed(2) + ' mph';
              } else {
                windSpeedUI = (windSpeed / count).toString() + ' m/s';
              }
              windDirectionUI = response.data['hours'][0]['windDirection']['noaa'].toString() + '°';
              if (ds['temperature']) {
                airTemperatureUI = ((airTemperature / count) * (9.0 / 5.0) + 32.0).toStringAsFixed(2) + '°F';
              } else {
                airTemperatureUI = (airTemperature / count).toString() + '°C';
              }
            }
            for (int i = 0; i < 6; i++) {
              dates[i] = response.data['hours'][i*24]['time'].toString().split("T")[0];
              waveDirections[i] = response.data['hours'][i*24]['waveDirection']['noaa'];
              if (ds['wave_height']) {
                waveCharts[i] = ColumnSeries<SurfData, String>(
                  color: Colors.cyan,
                  // Bind data source
                  dataSource: <SurfData>[
                    SurfData('0', response.data['hours'][i*24]['waveHeight']['noaa']*3.28084),
                    SurfData('1', response.data['hours'][i*24+1]['waveHeight']['noaa']*3.28084),
                    SurfData('2', response.data['hours'][i*24+2]['waveHeight']['noaa']*3.28084),
                    SurfData('3', response.data['hours'][i*24+3]['waveHeight']['noaa']*3.28084),
                    SurfData('4', response.data['hours'][i*24+4]['waveHeight']['noaa']*3.28084),
                    SurfData('5', response.data['hours'][i*24+5]['waveHeight']['noaa']*3.28084),
                    SurfData('6', response.data['hours'][i*24+6]['waveHeight']['noaa']*3.28084),
                    SurfData('7', response.data['hours'][i*24+7]['waveHeight']['noaa']*3.28084),
                    SurfData('8', response.data['hours'][i*24+8]['waveHeight']['noaa']*3.28084),
                    SurfData('9', response.data['hours'][i*24+9]['waveHeight']['noaa']*3.28084),
                    SurfData('10', response.data['hours'][i*24+10]['waveHeight']['noaa']*3.28084),
                    SurfData('11', response.data['hours'][i*24+11]['waveHeight']['noaa']*3.28084),
                    SurfData('12', response.data['hours'][i*24+12]['waveHeight']['noaa']*3.28084),
                    SurfData('13', response.data['hours'][i*24+13]['waveHeight']['noaa']*3.28084),
                    SurfData('14', response.data['hours'][i*24+14]['waveHeight']['noaa']*3.28084),
                    SurfData('15', response.data['hours'][i*24+15]['waveHeight']['noaa']*3.28084),
                    SurfData('16', response.data['hours'][i*24+16]['waveHeight']['noaa']*3.28084),
                    SurfData('17', response.data['hours'][i*24+17]['waveHeight']['noaa']*3.28084),
                    SurfData('18', response.data['hours'][i*24+18]['waveHeight']['noaa']*3.28084),
                    SurfData('19', response.data['hours'][i*24+19]['waveHeight']['noaa']*3.28084),
                    SurfData('20', response.data['hours'][i*24+20]['waveHeight']['noaa']*3.28084),
                    SurfData('21', response.data['hours'][i*24+21]['waveHeight']['noaa']*3.28084),
                    SurfData('22', response.data['hours'][i*24+22]['waveHeight']['noaa']*3.28084),
                    SurfData('23', response.data['hours'][i*24+23]['waveHeight']['noaa']*3.28084),
                  ],
                  xValueMapper: (SurfData surf, _) => surf.time,
                  yValueMapper: (SurfData surf, _) => surf.magnitude,
                );
              } else {
                waveCharts[i] = ColumnSeries<SurfData, String>(
                  color: Colors.cyan,
                  // Bind data source
                  dataSource: <SurfData>[
                    SurfData('0', response.data['hours'][i*24]['waveHeight']['noaa']),
                    SurfData('1', response.data['hours'][i*24+1]['waveHeight']['noaa']),
                    SurfData('2', response.data['hours'][i*24+2]['waveHeight']['noaa']),
                    SurfData('3', response.data['hours'][i*24+3]['waveHeight']['noaa']),
                    SurfData('4', response.data['hours'][i*24+4]['waveHeight']['noaa']),
                    SurfData('5', response.data['hours'][i*24+5]['waveHeight']['noaa']),
                    SurfData('6', response.data['hours'][i*24+6]['waveHeight']['noaa']),
                    SurfData('7', response.data['hours'][i*24+7]['waveHeight']['noaa']),
                    SurfData('8', response.data['hours'][i*24+8]['waveHeight']['noaa']),
                    SurfData('9', response.data['hours'][i*24+9]['waveHeight']['noaa']),
                    SurfData('10', response.data['hours'][i*24+10]['waveHeight']['noaa']),
                    SurfData('11', response.data['hours'][i*24+11]['waveHeight']['noaa']),
                    SurfData('12', response.data['hours'][i*24+12]['waveHeight']['noaa']),
                    SurfData('13', response.data['hours'][i*24+13]['waveHeight']['noaa']),
                    SurfData('14', response.data['hours'][i*24+14]['waveHeight']['noaa']),
                    SurfData('15', response.data['hours'][i*24+15]['waveHeight']['noaa']),
                    SurfData('16', response.data['hours'][i*24+16]['waveHeight']['noaa']),
                    SurfData('17', response.data['hours'][i*24+17]['waveHeight']['noaa']),
                    SurfData('18', response.data['hours'][i*24+18]['waveHeight']['noaa']),
                    SurfData('19', response.data['hours'][i*24+19]['waveHeight']['noaa']),
                    SurfData('20', response.data['hours'][i*24+20]['waveHeight']['noaa']),
                    SurfData('21', response.data['hours'][i*24+21]['waveHeight']['noaa']),
                    SurfData('22', response.data['hours'][i*24+22]['waveHeight']['noaa']),
                    SurfData('23', response.data['hours'][i*24+23]['waveHeight']['noaa']),
                  ],
                  xValueMapper: (SurfData surf, _) => surf.time,
                  yValueMapper: (SurfData surf, _) => surf.magnitude,
                );
              }
              windDirections[i] = response.data['hours'][i*24]['windDirection']['noaa'];
              if (ds['wind_speed']) {
                windCharts[i] = ColumnSeries<SurfData, String>(
                  color: Colors.cyan,
                  // Bind data source
                  dataSource: <SurfData>[
                    SurfData('0', response.data['hours'][i*24]['windSpeed']['noaa']*2.23694),
                    SurfData('1', response.data['hours'][i*24+1]['windSpeed']['noaa']*2.23694),
                    SurfData('2', response.data['hours'][i*24+2]['windSpeed']['noaa']*2.23694),
                    SurfData('3', response.data['hours'][i*24+3]['windSpeed']['noaa']*2.23694),
                    SurfData('4', response.data['hours'][i*24+4]['windSpeed']['noaa']*2.23694),
                    SurfData('5', response.data['hours'][i*24+5]['windSpeed']['noaa']*2.23694),
                    SurfData('6', response.data['hours'][i*24+6]['windSpeed']['noaa']*2.23694),
                    SurfData('7', response.data['hours'][i*24+7]['windSpeed']['noaa']*2.23694),
                    SurfData('8', response.data['hours'][i*24+8]['windSpeed']['noaa']*2.23694),
                    SurfData('9', response.data['hours'][i*24+9]['windSpeed']['noaa']*2.23694),
                    SurfData('10', response.data['hours'][i*24+10]['windSpeed']['noaa']*2.23694),
                    SurfData('11', response.data['hours'][i*24+11]['windSpeed']['noaa']*2.23694),
                    SurfData('12', response.data['hours'][i*24+12]['windSpeed']['noaa']*2.23694),
                    SurfData('13', response.data['hours'][i*24+13]['windSpeed']['noaa']*2.23694),
                    SurfData('14', response.data['hours'][i*24+14]['windSpeed']['noaa']*2.23694),
                    SurfData('15', response.data['hours'][i*24+15]['windSpeed']['noaa']*2.23694),
                    SurfData('16', response.data['hours'][i*24+16]['windSpeed']['noaa']*2.23694),
                    SurfData('17', response.data['hours'][i*24+17]['windSpeed']['noaa']*2.23694),
                    SurfData('18', response.data['hours'][i*24+18]['windSpeed']['noaa']*2.23694),
                    SurfData('19', response.data['hours'][i*24+19]['windSpeed']['noaa']*2.23694),
                    SurfData('20', response.data['hours'][i*24+20]['windSpeed']['noaa']*2.23694),
                    SurfData('21', response.data['hours'][i*24+21]['windSpeed']['noaa']*2.23694),
                    SurfData('22', response.data['hours'][i*24+22]['windSpeed']['noaa']*2.23694),
                    SurfData('23', response.data['hours'][i*24+23]['windSpeed']['noaa']*2.23694),
                  ],
                  xValueMapper: (SurfData surf, _) => surf.time,
                  yValueMapper: (SurfData surf, _) => surf.magnitude,
                );
              } else {
                windCharts[i] = ColumnSeries<SurfData, String>(
                  color: Colors.cyan,
                  // Bind data source
                  dataSource: <SurfData>[
                    SurfData('0', response.data['hours'][i*24]['windSpeed']['noaa']),
                    SurfData('1', response.data['hours'][i*24+1]['windSpeed']['noaa']),
                    SurfData('2', response.data['hours'][i*24+2]['windSpeed']['noaa']),
                    SurfData('3', response.data['hours'][i*24+3]['windSpeed']['noaa']),
                    SurfData('4', response.data['hours'][i*24+4]['windSpeed']['noaa']),
                    SurfData('5', response.data['hours'][i*24+5]['windSpeed']['noaa']),
                    SurfData('6', response.data['hours'][i*24+6]['windSpeed']['noaa']),
                    SurfData('7', response.data['hours'][i*24+7]['windSpeed']['noaa']),
                    SurfData('8', response.data['hours'][i*24+8]['windSpeed']['noaa']),
                    SurfData('9', response.data['hours'][i*24+9]['windSpeed']['noaa']),
                    SurfData('10', response.data['hours'][i*24+10]['windSpeed']['noaa']),
                    SurfData('11', response.data['hours'][i*24+11]['windSpeed']['noaa']),
                    SurfData('12', response.data['hours'][i*24+12]['windSpeed']['noaa']),
                    SurfData('13', response.data['hours'][i*24+13]['windSpeed']['noaa']),
                    SurfData('14', response.data['hours'][i*24+14]['windSpeed']['noaa']),
                    SurfData('15', response.data['hours'][i*24+15]['windSpeed']['noaa']),
                    SurfData('16', response.data['hours'][i*24+16]['windSpeed']['noaa']),
                    SurfData('17', response.data['hours'][i*24+17]['windSpeed']['noaa']),
                    SurfData('18', response.data['hours'][i*24+18]['windSpeed']['noaa']),
                    SurfData('19', response.data['hours'][i*24+19]['windSpeed']['noaa']),
                    SurfData('20', response.data['hours'][i*24+20]['windSpeed']['noaa']),
                    SurfData('21', response.data['hours'][i*24+21]['windSpeed']['noaa']),
                    SurfData('22', response.data['hours'][i*24+22]['windSpeed']['noaa']),
                    SurfData('23', response.data['hours'][i*24+23]['windSpeed']['noaa']),
                  ],
                  xValueMapper: (SurfData surf, _) => surf.time,
                  yValueMapper: (SurfData surf, _) => surf.magnitude,
                );
              }
            }
            print(dates);
          });
        });
        getHttpTide(latitude, longitude).then((Response response) {
          setState(() {
            if (ds['wave_height']) {
              tideOne = response.data['data'][0]['height']*3.28084;
              tideOneTime = response.data['data'][0]['time'].toString().split('T')[1];
              tideTwo = response.data['data'][1]['height']*3.28084;
              tideTwoTime = response.data['data'][1]['time'].toString().split('T')[1];
              tideThree = response.data['data'][2]['height']*3.28084;
              tideThreeTime = response.data['data'][2]['time'].toString().split('T')[1];
              tideFour = response.data['data'][3]['height']*3.28084;
              tideFourTime = response.data['data'][3]['time'].toString().split('T')[1];
            } else {
              tideOne = response.data['data'][0]['height'];
              tideOneTime =
              response.data['data'][0]['time'].toString().split('T')[1];
              tideTwo = response.data['data'][1]['height'];
              tideTwoTime =
              response.data['data'][1]['time'].toString().split('T')[1];
              tideThree = response.data['data'][2]['height'];
              tideThreeTime =
              response.data['data'][2]['time'].toString().split('T')[1];
              tideFour = response.data['data'][3]['height'];
              tideFourTime =
              response.data['data'][3]['time'].toString().split('T')[1];
            }
          });
        });
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(title: Text(spotName),
          actions: [
            if (!favorited)
              IconButton(icon: Icon(Icons.favorite_border),
                  onPressed: () {
                    setState(() {
                      Auth().getCurrentUser().then((FirebaseUser user) {
                        Firestore.instance.collection('favorite_spots').document(user.uid)
                            .setData({ 'favorited_spot_coordinates': favoritedSpotCoordinates + spotLatLng + '/', 'uid': user.uid});
                        favorited = true;
                      });
                    });
                  }
              ),
            if (favorited)
              IconButton(icon: Icon(Icons.favorite),
                  onPressed: () {
                    setState(() {
                      Auth().getCurrentUser().then((FirebaseUser user) {
                        Firestore.instance.collection('favorite_spots').document(user.uid)
                            .setData({ 'favorited_spot_coordinates': favoritedSpotCoordinates.replaceAll(spotLatLng + '/', ''), 'uid': user.uid});
                        favorited = false;
                      });
                    });
                  }
              ),
          ],
          leading: new IconButton(
            icon: new Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          bottom: TabBar(
            tabs: [
              Tab(text: "Overview"),
              Tab(text: "Forecast"),
            ],
            indicatorColor: Colors.black,
            indicatorWeight: 7.0,
          ),
          backgroundColor: Colors.cyan,),
        body: TabBarView(
          children: [
            Container(
              color: Colors.black,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text("Wave", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 36),),
                            Text("🌊", style: TextStyle(fontSize: 36),),
                            Text(waveHeightUI, style: TextStyle(color: Colors.white, fontSize: 12),),
                            Text(waveDirectionUI, style: TextStyle(color: Colors.white, fontSize: 12),),
                            Text(waterTemperatureUI, style: TextStyle(color: Colors.white, fontSize: 12),),
                          ],
                        ),
                      ),
                      Expanded(
                          child: Image.asset('assets/images/compass.png')
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text("Wind", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 36),),
                            Text("💨", style: TextStyle(color: Colors.white, fontSize: 36),),
                            Text(windSpeedUI, style: TextStyle(color: Colors.white, fontSize: 12),),
                            Text(windDirectionUI, style: TextStyle(color: Colors.white, fontSize: 12),),
                            Text(airTemperatureUI, style: TextStyle(color: Colors.white, fontSize: 12),),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text("Tide", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 36),),
                          Text("🌑", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 36),),
                          SfCartesianChart(
                              primaryXAxis: CategoryAxis(),
                              primaryYAxis: NumericAxis(),
                              series: <ChartSeries>[
                                ColumnSeries<SurfData, String>(
                                  color: Colors.cyan,
                                  // Bind data source
                                  dataSource:  <SurfData>[
                                    SurfData(tideOneTime, tideOne),
                                    SurfData(tideTwoTime, tideTwo),
                                    SurfData(tideThreeTime, tideThree),
                                    SurfData(tideFourTime, tideFour),
                                  ],
                                  xValueMapper: (SurfData surf, _) => surf.time,
                                  yValueMapper: (SurfData surf, _) => surf.magnitude,
                                )
                              ]
                          ),
                          Text("All times are in UTC.", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),),
                        ],
                      )
                  ),
                ],
              ),
            ),
            ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: dates.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 1.0),
                  color: Colors.black,
                  child: SingleChildScrollView(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(dates[index], style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),),
                          Text("Wave", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 36),),
                          Text(waveDirections[index].toString() + "°", style: TextStyle(color: Colors.white, fontWeight: FontWeight.normal, fontSize: 12),),
                          SfCartesianChart(
                              primaryXAxis: CategoryAxis(),
                              primaryYAxis: NumericAxis(),
                              series: <ChartSeries>[
                                waveCharts[index]
                              ]
                          ), Text("Wind", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 36),),
                          Text(windDirections[index].toString() + "°", style: TextStyle(color: Colors.white, fontWeight: FontWeight.normal, fontSize: 12),),
                          SfCartesianChart(
                              primaryXAxis: CategoryAxis(),
                              primaryYAxis: NumericAxis(),
                              series: <ChartSeries>[
                                windCharts[index]
                              ]
                          ),
                          Text("All times are in UTC.", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),),
                        ]
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class SurfData {
  SurfData(this.time, this.magnitude);
  final String time;
  final double magnitude;
}