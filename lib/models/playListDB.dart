import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

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

  Future<String> getPath() async {
    Directory documentDirectory = await getApplicationDocumentsDirectory();
    final path = documentDirectory.path + '/playlist.db';
    return path;
  }

  //TODO: favourites should be added to the db when app runs for the first time

  createPlaylist(String name) async {
    var newItem = {
      'name': name,
      'songs': [],
    };
    playList.add(newItem);
    Box db = await Hive.openBox('playlist', path: await getPath());
    for (var each in playList) {
      if (db.get(each['name']) != each) {
        db.put(each['name'], each);
        print('added');
      }
    }
    refresh();
    notifyListeners();
  }

  addToPlaylist(String playlistName, dynamic song) async{
    Box db = await Hive.openBox('playlist', path: await getPath());
    var dbPlaylist = db.get(playlistName);
    List songs = dbPlaylist['songs'];
    songs.add(song);
    db.put(playlistName, {
      'name': playlistName,
      'songs': songs,
    });
    print('succesfully added to $playlistName');
    refresh();
  }

  isFavourite(dynamic song) async{
    Box db = await Hive.openBox('playlist', path: await getPath());
    var dbPlaylist = db.get('Favourites');
    List songs = dbPlaylist['songs'];
    print('checking if ${song['title']} is favourite: ${songs.contains(song)}');
    notifyListeners();
    return songs.contains(song);
  }

  refresh() async {
    print('refreshing');
    Box db = await Hive.openBox('playlist', path: await getPath());
    if (db.values.length != 0) {
      playList.clear();
      for (var each in db.values) {
        playList.add(each);
      }
    }
    notifyListeners();
  }

  clear() async {
    Box db = await Hive.openBox('playlist', path: await getPath());
    await db.deleteFromDisk();
    print('deleted');
  }
}
