import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:musicPlayer/components/customCard.dart';
import 'package:path_provider/path_provider.dart';

class PlayListDB extends ChangeNotifier{
  List<Widget> playList = [
    Padding(
      padding: const EdgeInsets.only(
        right: 20.0,
        bottom: 20.0,
      ),
      child: CustomCard(
        height: 240,
        width: 240,
        label: 'Favourites',
        numOfSongs: 0,
        child: Icon(Icons.favorite_border),
      ),
    ),
    Padding(
      padding: const EdgeInsets.only(
        right: 20.0,
        bottom: 20.0,
      ),
      child: CustomCard(
        height: 240,
        width: 240,
        label: 'Create playlist',
        numOfSongs: 0,
        child: Icon(Icons.add),
      ),
    ),
  ];

  List<Widget> recent = [
    Padding(
      padding: const EdgeInsets.only(
        right: 20.0,
        bottom: 20.0,
      ),
      child: CustomCard(
        height: 240,
        width: 240,
        label: 'Recently added',
        numOfSongs: 0,
        child: Icon(Icons.playlist_add),
      ),
    ),
    Padding(
      padding: const EdgeInsets.only(
        right: 20.0,
        bottom: 20.0,
      ),
      child: CustomCard(
        height: 240,
        width: 240,
        label: 'Recently played',
        numOfSongs: 0,
        child: Icon(Icons.playlist_play),
      ),
    ),
  ];
  
  getPath() async {
    Directory documentDirectory = await getApplicationDocumentsDirectory();
    final path = documentDirectory.path + '/downloads.db';
    return path;
  }

  createPlayList() {
    // final db = Hive.openBox('favourites', path: getPath());
  }
}