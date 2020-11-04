import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive/hive.dart';
import 'package:musicPlayer/components/toast.dart';
import 'package:musicPlayer/models/song.dart';
import 'package:path_provider/path_provider.dart';

class PlayListDB extends ChangeNotifier {
  List<Map<dynamic, dynamic>> playList = [];

  List<Song> recentList = [];

  Future<String> getPlaylistPath() async {
    Directory documentDirectory = await getApplicationDocumentsDirectory();
    final path = documentDirectory.path + '/playlist.db';
    return path;
  }

  Future<String> getRecentPath() async {
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
    Box db = await Hive.openBox('playlist', path: await getPlaylistPath());
    for (var each in playList) {
      // if it doesnt already exist add it to the database
      if (db.get(each['name']) == null) {
        db.put(each['name'], each);
      }
    }
    refresh();
  }

  Future<void> addToPlaylist(String playlistName, Song song) async {
    Box db = await Hive.openBox('playlist', path: await getPlaylistPath());
    var dbPlaylist = db.get(playlistName);
    List songs = dbPlaylist['songs'];
    bool found = songs.any((element) => element['path'] == song.path);
    if (!found) {
      songs.add(song.toMap());
      db.put(playlistName, {
        'name': playlistName,
        'songs': songs,
      });
    }
    refresh();
  }

  Future<void> removeFromPlaylist(String playlistName, Song song) async {
    if (playlistName == 'Recently played') {
      Box recentdb = await Hive.openBox('recent', path: await getRecentPath());
      List recentSongs = recentdb.get('Recently played');
      recentSongs.removeWhere((element) => element['path'] == song.path);
      recentdb.put('Recently played', recentSongs);
    } else {
      Box db = await Hive.openBox('playlist', path: await getPlaylistPath());
      var dbPlaylist = db.get(playlistName);
      List songs = dbPlaylist['songs'];
      songs.removeWhere((element) => element['path'] == song.path);
      db.put(playlistName, {
        'name': playlistName,
        'songs': songs,
      });
    }
    refresh();
  }

  Future<bool> isFavourite(Song song) async {
    Box db = await Hive.openBox('playlist', path: await getPlaylistPath());
    var dbPlaylist = db.get('Favourites');
    List songs = dbPlaylist['songs'];
    return songs.any((element) => element['path'] == song.path);
  }

  Future<void> removeFromDevice(Song song) async {
    // delete from all created playlist
    Box db = await Hive.openBox('playlist', path: await getPlaylistPath());
    for (var eachDB in db.values) {
      List songs = eachDB['songs'];
      // ? because first thing in the list is createplaylist with no songs list
      songs?.removeWhere((element) => element['path'] == song.path);
      db.put(eachDB['name'], {
        'name': eachDB['name'],
        'songs': songs,
      });
    }
    // delete from recently played
    Box recentdb = await Hive.openBox('recent', path: await getRecentPath());
    List songs = recentdb.get('Recently played');
    songs.removeWhere((element) => element['path'] == song.path);
    recentdb.put('Recently played', songs);
    // delete from device
    var deviceFile = File(song.path);
    if (deviceFile.existsSync()) {
      deviceFile.deleteSync();
    }
    refresh();
  }

  Future<void> saveNowPlaying(Song song) async {
    Box db = await Hive.openBox('recent', path: await getRecentPath());
    List songs = db.get('Recently played');
    bool found = songs.any((element) => element['path'] == song.path);
    if (!found && songs.length < 20) {
      songs.add(song.toMap());
    } else if (!found && songs.length == 20) {
      songs.removeAt(0);
      songs.add(song.toMap());
    } else if (found) {
      songs.removeWhere((element) => element['path'] == song.path);
      songs.add(song.toMap());
    }
    db.put('Recently played', songs);
  }

  Future<void> getRecentlyPlayed() async {
    Box db = await Hive.openBox('recent', path: await getRecentPath());
    List songs = db.get('Recently played');
    if (songs.isNotEmpty) {
      recentList.clear();
      for (var each in songs) {
        // most recent song to be at the top
        recentList.insert(0, Song.fromMap(each));
      }
    }
    notifyListeners();
  }

  Future<void> editPlaylistName(String playlistName, String newName) async {
    Box db = await Hive.openBox('playlist', path: await getPlaylistPath());
    var playList = db.get(playlistName);
    db.put(newName, {
      'name': newName,
      'songs': playList['songs'],
    });
    db.delete(playlistName);
    refresh();
  }

  Future<void> replaceSong(Song newSong) async {
    // replace in all created playlist
    Box db = await Hive.openBox('playlist', path: await getPlaylistPath());
    for (var eachDB in db.values) {
      List songs = eachDB['songs'];
      if (songs != null) {
        // ? because first thing in the list is createplaylist with no songs list
        final index = songs.indexWhere((song) => song['path'] == newSong.path);
        if (index != -1 && index != null) {
          songs.replaceRange(index, index + 1, [newSong.toMap()]);
        }
      }
      db.put(eachDB['name'], {
        'name': eachDB['name'],
        'songs': songs,
      });
    }
    // replace in recently played
    Box recentdb = await Hive.openBox('recent', path: await getRecentPath());
    List songs = recentdb.get('Recently played');
    final index = songs.indexWhere((song) => song['path'] == newSong.path);
    if (index != -1) {
      songs.replaceRange(index, index + 1, [newSong.toMap()]);
    }
    recentdb.put('Recently played', songs);
    refresh();
  }

  Future<void> deletePlaylist(String playlistName) async {
    Box db = await Hive.openBox('playlist', path: await getPlaylistPath());
    db.delete(playlistName);
    refresh();
  }

  Future<dynamic> lastPlayed() async {
    Box db = await Hive.openBox('recent', path: await getRecentPath());
    List songs = db.get('Recently played');
    if (songs != null && songs.isNotEmpty) {
      return Song.fromMap(songs.last);
    } else {
      return null;
    }
  }

  void showToast(String message, BuildContext context) {
    final fToast = FToast();
    fToast.init(context);
    fToast.removeQueuedCustomToasts();
    fToast.showToast(
        gravity: ToastGravity.BOTTOM,
        toastDuration: Duration(seconds: 2),
        child: CustomToast(message));
  }

  List<Song> extract(List songs) {
    // returns a list of type Song from a list of type Map
    List<Song> newList = [];
    songs.forEach((song) {
      newList.add(Song.fromMap(song));
    });
    return newList;
  }

  Future<void> init() async {
    return refresh();
  }

  Future<void> refresh() async {
    Box db = await Hive.openBox('playlist', path: await getPlaylistPath());
    if (db.values.length != 0) {
      playList.clear();
      for (var each in db.values) {
        // createplaylist should always be first
        if (each['name'] == 'Create playlist') {
          playList.insert(0, each);
          // followed by favourites
        } else if (each['name'] == 'Favourites') {
          playList.insert(1, each);
        } else {
          playList.add(each);
        }
      }
      await getRecentlyPlayed();
    } else {
      Box recentdb = await Hive.openBox('recent', path: await getRecentPath());
      // else block runs just the first time, when db is empty
      // happens when app is run for the first time or after playlist is reset
      db.put('Create playlist', {'name': 'Create playlist'});
      db.put('Favourites', {
        'name': 'Favourites',
        'songs': [],
      });
      recentdb.put('Recently played', []);
      refresh();
    }
    notifyListeners();
  }

  Future<void> clear() async {
    Box db = await Hive.openBox('playlist', path: await getPlaylistPath());
    Box recentdb = await Hive.openBox('recent', path: await getRecentPath());
    await db.deleteFromDisk();
    await recentdb.deleteFromDisk();
    refresh();
  }
}
