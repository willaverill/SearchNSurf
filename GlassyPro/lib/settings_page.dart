import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';

import 'authentication.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsAppState createState() => _SettingsAppState();
}

class _SettingsAppState extends State<SettingsPage> {

  @override
  void setState(fn) {
    if(mounted){
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Global.shared.set().then((DocumentSnapshot ds) {
      setState(() {
        Global.shared.waveHeight = ds.data['wave_height'];
        Global.shared.windSpeed = ds.data['wind_speed'];
        Global.shared.temperature = ds.data['temperature'];
        if (Global.shared.waveHeight) {
          Global.shared.waveHeightUnits = "Feet";
        } else {
          Global.shared.waveHeightUnits = "Meters";
        }
        if (Global.shared.windSpeed) {
          Global.shared.windSpeedUnits = "Miles Per Hour";
        } else {
          Global.shared.windSpeedUnits = "Meters Per Second";
        }
        if (Global.shared.temperature) {
          Global.shared.temperatureUnits = "Degrees Fahrenheit";
        } else {
          Global.shared.temperatureUnits = "Degrees Celsius";
        }
      });
    });
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        backgroundColor: Colors.cyan,
      ),
      body: SettingsList(
        sections: [
          SettingsSection(
            title: 'Units',
            tiles: [
              SettingsTile.switchTile(
                title: 'Wave Height',
                subtitle: Global.shared.waveHeightUnits,
                leading: Text("🌊"),
                switchValue: Global.shared.waveHeight,
                onToggle: (bool value) {
                  setState(() {
                    Global.shared.waveHeight = value;
                    if (Global.shared.waveHeight) {
                      Global.shared.waveHeightUnits = "Feet";
                    } else {
                      Global.shared.waveHeightUnits = "Meters";
                    }
                    if (Global.shared.windSpeed) {
                      Global.shared.windSpeedUnits = "Miles Per Hour";
                    } else {
                      Global.shared.windSpeedUnits = "Kilometers Per Hour";
                    }
                    if (Global.shared.temperature) {
                      Global.shared.temperatureUnits = "Degrees Fahrenheit";
                    } else {
                      Global.shared.temperatureUnits = "Degrees Celsius";
                    }
                    Auth().getCurrentUser().then((FirebaseUser user) {
                      Firestore.instance.collection('settings').document(user.uid)
                          .setData({ 'wave_height': value, 'wind_speed': Global.shared.windSpeed, 'temperature': Global.shared.temperature});
                    });
                  });
                },
              ),
              SettingsTile.switchTile(
                title: 'Wind Speed',
                subtitle: Global.shared.windSpeedUnits,
                leading: Text("💨"),
                switchValue: Global.shared.windSpeed,
                onToggle: (bool value) {
                  setState(() {
                    Global.shared.windSpeed = value;
                    if (Global.shared.waveHeight) {
                      Global.shared.waveHeightUnits = "Feet";
                    } else {
                      Global.shared.waveHeightUnits = "Meters";
                    }
                    if (Global.shared.windSpeed) {
                      Global.shared.windSpeedUnits = "Miles Per Hour";
                    } else {
                      Global.shared.windSpeedUnits = "Kilometers Per Hour";
                    }
                    if (Global.shared.temperature) {
                      Global.shared.temperatureUnits = "Degrees Fahrenheit";
                    } else {
                      Global.shared.temperatureUnits = "Degrees Celsius";
                    }
                    Auth().getCurrentUser().then((FirebaseUser user) {
                      Firestore.instance.collection('settings').document(user.uid)
                          .setData({'wave_height': Global.shared.waveHeight, 'wind_speed': value, 'temperature': Global.shared.temperature });
                    });
                  });
                },
              ),
              SettingsTile.switchTile(
                title: 'Temperature',
                subtitle: Global.shared.temperatureUnits,
                leading: Text("🌡"),
                switchValue: Global.shared.temperature,
                onToggle: (bool value) {
                  setState(() {
                    Global.shared.temperature = value;
                    if (Global.shared.waveHeight) {
                      Global.shared.waveHeightUnits = "Feet";
                    } else {
                      Global.shared.waveHeightUnits = "Meters";
                    }
                    if (Global.shared.windSpeed) {
                      Global.shared.windSpeedUnits = "Miles Per Hour";
                    } else {
                      Global.shared.windSpeedUnits = "Kilometers Per Hour";
                    }
                    if (Global.shared.temperature) {
                      Global.shared.temperatureUnits = "Degrees Fahrenheit";
                    } else {
                      Global.shared.temperatureUnits = "Degrees Celsius";
                    }
                    Auth().getCurrentUser().then((FirebaseUser user) {
                      Firestore.instance.collection('settings').document(user.uid)
                          .setData({'wave_height': Global.shared.waveHeight, 'wind_speed': Global.shared.windSpeed, 'temperature': value});
                    });
                  });
                },
              ),
            ],
          ),
          SettingsSection(
            title: 'Account',
            tiles: [
              SettingsTile(
                title: 'Sign Out',
                leading: Icon(Icons.exit_to_app),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class Global {
  static final shared = Global();
  var waveHeight = true;
  var windSpeed = true;
  var temperature = true;
  var waveHeightUnits;
  var windSpeedUnits;
  var temperatureUnits;
  Future<DocumentSnapshot> set() async {
    FirebaseUser user = await Auth().getCurrentUser();
    DocumentSnapshot ds = await Firestore.instance
        .collection('settings')
        .document(user.uid)
        .get();
    return ds;
  }
}