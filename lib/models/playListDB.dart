import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:musicPlayer/models/Provider.dart';
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

  List recentList = [];

  static Future<String> getPath() async {
    Directory documentDirectory = await getApplicationDocumentsDirectory();
    final path = documentDirectory.path + '/playlist.db';
    return path;
  }

  static Future<String> getRecentPath() async {
    Directory documentDirectory = await getApplicationDocumentsDirectory();
    final path = documentDirectory.path + '/recent.db';
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
      }
    }
    refresh();
    notifyListeners();
  }

  Future<void> addToPlaylist(String playlistName, dynamic song) async {
    Box db = await Hive.openBox('playlist', path: await getPath());
    var dbPlaylist = db.get(playlistName);
    List songs = dbPlaylist['songs'];
    bool notFound = songs.every((element) => element['path'] != song['path']);
    if (notFound) {
      songs.add(song);
      db.put(playlistName, {
        'name': playlistName,
        'songs': songs,
      });
      // if its already in favourites remove it.
      // hence the heart icon can be toggled to either add or remove from favourites
    } else if (!notFound && playlistName == 'Favourites') {
      songs.remove(song);
      db.put(playlistName, {
        'name': playlistName,
        'songs': songs,
      });
    }
    // songcontroller needs to handle the bool because for every song thats played the bool is re evaluated
    SongController.isFavourite = await isFavourite(song);
    refresh();
  }

  Future<bool> isFavourite(dynamic song) async {
    Box db = await Hive.openBox('playlist', path: await getPath());
    var dbPlaylist = db.get('Favourites');
    List songs = dbPlaylist['songs'];
    return songs.where((element) => element['path'] == song['path']).isNotEmpty;
  }

  Future<void> saveNowPlaying(dynamic song) async {
    Box db = await Hive.openBox('recent', path: await getRecentPath());
    List songs = db.get('Recently played');
    bool notFound = songs.every((element) => element['path'] != song['path']);
    if (notFound && songs.length < 20) {
      songs.add(song);
    } else if (notFound && songs.length == 20) {
      songs.removeAt(0);
      songs.add(song);
    }
    db.put('Recently played', songs);
  }

  Future<void> getRecentlyPlayed() async {
    Box db = await Hive.openBox('recent', path: await getRecentPath());
    List songs = db.get('Recently played');
    recentList.clear();
    recentList.addAll(songs.reversed);
    notifyListeners();
  }

  static Future<dynamic> lastPlayed(BuildContext context) async {
    Box db = await Hive.openBox('recent', path: await getRecentPath());
    List songs = db.get('Recently played');
    if (songs != null && songs.isNotEmpty) {
      return songs.last;
    } else {
      return Provider.of<ProviderClass>(context, listen: false)
          .allSongs.first;
    }
  }

  Future<void> refresh() async {
    getRecentlyPlayed();
    Box db = await Hive.openBox('playlist', path: await getPath());
    Box recentdb = await Hive.openBox('recent', path: await getRecentPath());
    if (db.values.length != 0) {
      playList.clear();
      for (var each in db.values) {
        playList.add(each);
      }
    } else {
      // else block runs just the first time, when db is empty
      for (var each in playList) {
        db.put(each['name'], each);
      }
      recentdb.put('Recently played', []);
    }
    notifyListeners();
  }

  Future<void> clear() async {
    Box db = await Hive.openBox('playlist', path: await getPath());
    Box recentdb = await Hive.openBox('recent', path: await getRecentPath());
    await db.deleteFromDisk();
    await recentdb.deleteFromDisk();
    print('deleted');
  }
}
