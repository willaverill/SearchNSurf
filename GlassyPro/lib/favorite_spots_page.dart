import 'package:GlassyPro/spot_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'authentication.dart';

class FavoriteSpotsPage extends StatefulWidget {
  @override
  _FavoriteSpotsAppState createState() => _FavoriteSpotsAppState();
}

class _FavoriteSpotsAppState extends State<FavoriteSpotsPage> {
  var favoriteSpotsList;
  var temp = '';
  var favoritedSpotCoordinates = [];
  var favoritedSpotNames = [];

  @override
  void initState() {
    Auth().getCurrentUser().then((FirebaseUser user) {
      Firestore.instance
          .collection('favorite_spots')
          .where('uid', isEqualTo: user.uid)
          .snapshots()
          .listen((data) => data.documents.forEach((doc) => setState(() {
        var temp = '';
        favoritedSpotCoordinates.clear();
        favoritedSpotNames.clear();
        temp =
        doc['favorited_spot_coordinates'];
        favoritedSpotCoordinates = temp.split('/');
        print("favorited spot coordinates = " + favoritedSpotCoordinates.length.toString());
        for (int i = 0; i < favoritedSpotCoordinates.length; i++) {
          if (favoritedSpotCoordinates[i] != "") {
            Firestore.instance
                .collection('surf_spots')
                .where('spot_two_lat_lng',
                isEqualTo: favoritedSpotCoordinates[i])
                .snapshots()
                .listen(
                    (data) => data.documents.forEach((doc) => setState(() {
                  print("favorite spot = " + doc['spot_two_name']);
                  favoritedSpotNames.add(doc['spot_two_name']);
                  favoriteSpotsList = ListView.builder(
                      itemCount: favoritedSpotNames.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(favoritedSpotNames[index]),
                          leading: Icon(Icons.place),
                          trailing: Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => SpotPage(spotLatLng: favoritedSpotCoordinates[index])),
                            );
                          },
                        );
                      });
                })));
          }
        }
      })));
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorite Spots'),
        backgroundColor: Colors.cyan,
      ),
      body: favoriteSpotsList,
    );
  }
}
