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
        top: 20.0,
      ),
      child: CustomCard(
        height: 30,
        width: 30,
        label: 'Favourites',
        numOfSongs: 0,
        child: Icons.favorite_border,
      ),
    ),
    Padding(
      padding: const EdgeInsets.only(
        right: 20.0,
        bottom: 20.0,
        top: 20.0,
      ),
      child: CustomCard(
        height: 30,
        width: 30,
        label: 'Create playlist',
        numOfSongs: 0,
        child: Icons.add,
      ),
    ),
  ];

  List<Widget> recent = [
    Padding(
      padding: const EdgeInsets.only(
        right: 20.0,
        bottom: 20.0,
        top: 20.0,
      ),
      child: CustomCard(
        height: 30,
        width: 30,
        label: 'Recently added',
        numOfSongs: 0,
        child: Icons.playlist_add,
      ),
    ),
    Padding(
      padding: const EdgeInsets.only(
        right: 20.0,
        bottom: 20.0,
        top: 20.0,
      ),
      child: CustomCard(
        height: 30,
        width: 30,
        label: 'Recently played',
        numOfSongs: 0,
        child: Icons.playlist_play,
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