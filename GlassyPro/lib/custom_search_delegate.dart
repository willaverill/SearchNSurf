import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomSearchDelegate extends SearchDelegate<String> {
  var spots = <String, String>{};

  @override
  ThemeData appBarTheme(BuildContext context) {
    assert(context != null);
    final ThemeData theme = Theme.of(context);
    assert(theme != null);
    return theme;
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (spots.length == 0) {
      return Center(
        child: Text(
          '"$query" was not found in our database.',
          textAlign: TextAlign.center,
        ),
      );
    }
    return ListView.builder(
        itemCount: spots.length,
        itemBuilder: (BuildContext context, int index) {
          String key = spots.keys.elementAt(index);
          return ListTile(
            title: Text("$key"),
            subtitle: Text("Tap to view on map!"),
            leading: Icon(Icons.place),
            trailing: Icon(Icons.search),
            onTap: () {
              close(context, spots[query]);
            },
          );
        }
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query != "") {
      Firestore.instance.collection('surf_spots')
          .where("spot_two_name", isEqualTo: query)
          .snapshots()
          .listen((data) =>
          data.documents.forEach((doc) =>
          spots[doc["spot_two_name"]] = doc["spot_two_lat_lng"]));
    }
    return Column();
  }
}