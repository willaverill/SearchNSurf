import 'package:GlassyPro/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'favorite_spots_page.dart';
import 'hot_spots_page.dart';
import 'map_page.dart';

class TabNavigationItem {
  final Widget page;
  final Widget title;
  final Icon icon;

  TabNavigationItem({
    @required this.page,
    @required this.title,
    @required this.icon,
  });

  static List<TabNavigationItem> get items => [
    TabNavigationItem(
      page: MapPage(),
      icon: Icon(Icons.map),
      title: Text("Map"),
    ),
    TabNavigationItem(
      page: HotSpotsPage(),
      icon: Icon(Icons.whatshot),
      title: Text("Hot Spots"),
    ),
    TabNavigationItem(
      page: FavoriteSpotsPage(),
      icon: Icon(Icons.favorite),
      title: Text("Favorite Spots"),
    ),
    TabNavigationItem(
      page: SettingsPage(),
      icon: Icon(Icons.settings),
      title: Text("Settings"),
    ),
  ];
}