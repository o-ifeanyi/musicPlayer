import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:musicPlayer/models/songController.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

class PlayListDB extends ChangeNotifier {
  PlayListDB() {
    refresh();
  }
  List playList = [
    {
      'name': 'Create playlist',
    },
    {
      'name': 'Favourites',
      'songs': [],
    },
  ];

  List recent = [
    {
      'name': 'Recently added',
      'songs': [],
    },
    {
      'name': 'Recently played',
      'songs': [],
    },
  ];

  static Future<String> getPath() async {
    Directory documentDirectory = await getApplicationDocumentsDirectory();
    final path = documentDirectory.path + '/playlist.db';
    return path;
  }

  Future<void> createPlaylist(String name) async {
    var newItem = {
      'name': name,
      'songs': [],
    };
    playList.add(newItem);
    Box db = await Hive.openBox('playlist', path: await getPath());
    for (var each in playList) {
      // if it doesnt already exist add it to the database
      if (db.get(each['name']) == null) {
        db.put(each['name'], each);
        print('added ${each['name']} to database');
      }
    }
    refresh();
    notifyListeners();
  }

  Future<void> addToPlaylist(String playlistName, dynamic song) async {
    Box db = await Hive.openBox('playlist', path: await getPath());
    var dbPlaylist = db.get(playlistName);
    List songs = dbPlaylist['songs'];
    songs.add(song);
    db.put(playlistName, {
      'name': playlistName,
      'songs': songs,
    });
    print('succesfully added to $playlistName');
    // songcontroller needs to handle the bool because for every song thats played the bool is re evaluated
    SongController.isFavourite = await isFavourite(song);
    refresh();
  }

  // TODO still returns false on some occassions that are true
  static Future<bool> isFavourite(dynamic song) async {
    Box db = await Hive.openBox('playlist', path: await getPath());
    var dbPlaylist = db.get('Favourites');
    List songs = dbPlaylist['songs'];
    print('checking if ${song['title']} is favourite: ${songs.contains(song)}');
    print(songs);
    return songs.contains(song);
  }

  Future<void> refresh() async {
    print('refreshing');
    Box db = await Hive.openBox('playlist', path: await getPath());
    if (db.values.length != 0) {
      playList.clear();
      for (var each in db.values) {
        playList.add(each);
      }
    } else {
      // adds favourite to database for the first time
      for (var each in playList) {
        db.put(each['name'], each);
      }
    }
    notifyListeners();
  }

  Future<void> clear() async {
    Box db = await Hive.openBox('playlist', path: await getPath());
    await db.deleteFromDisk();
    print('deleted');
  }
}
