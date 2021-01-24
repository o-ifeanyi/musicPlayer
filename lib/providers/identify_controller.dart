import 'dart:convert';

import 'package:acr_cloud_sdk/acr_cloud_sdk.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:musicPlayer/components/identied_songinfo.dart';
import 'package:musicPlayer/models/exception.dart';
import 'package:musicPlayer/models/song.dart';
import 'package:musicPlayer/providers/playList_database.dart';
import 'package:musicPlayer/services/lyrics.dart';
import 'package:musicPlayer/services/secrets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IdentifyController extends ChangeNotifier {
  AnimationController controller;
  BuildContext context;
  bool isSearching = false;
  bool isSearchingLyrics = false;
  List<String> lyrics = [];
  List<Song> identifiedHistory = [];
  AcrCloudSdk arc = AcrCloudSdk();
  final playlistDB = PlayListDB();

  void init() async {
    arc
      ..init(
        host: kHost,
        accessKey: kAccessKey,
        accessSecret: kAccessSecret,
        setLog: true,
      )
      ..songModelStream.listen(searchSong);
  }

  Future<void> startSearch() async {
    lyrics = [];
    isSearching = true;
    notifyListeners();
    controller.repeat(period: Duration(seconds: 1));
    await arc.start();
  }

  Future<void> stopSearch() async {
    isSearching = false;
    notifyListeners();
    controller.stop();
    await arc.stop();
  }

  void searchSong(SongModel song) async {
    var data = song?.metadata;

    if (data != null && data.music.length > 0) {
      await stopSearch();
      final firstItem = data.music[0];
      final identifiedSong = Song(
        title: firstItem.title,
        artist: firstItem.artists.first.name,
        album: firstItem.album.name,
        year: firstItem.releaseDate,
      );
      await _saveIdentifiedSong(identifiedSong);
      await showModalBottomSheet(
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        context: context,
        builder: (context) => IdentifiedSong(identifiedSong),
      );
    } else {
      playlistDB.showToast('Song not found', context, isSuccess: false);
    }
    stopSearch();
  }

  Future<void> _saveIdentifiedSong(Song song) async {
    await SharedPreferences.getInstance().then((pref) {
      final history = pref.getStringList('history') ?? [];
      history.add(json.encode(song.toMap()));
      pref.setStringList('history', history);
    });
  }

  Future<void> loadIdentifiedSong() async {
    await SharedPreferences.getInstance().then((pref) {
      final history = pref.getStringList('history') ?? [];
      identifiedHistory =
          history.map((e) => Song.fromMap(json.decode(e))).toList();
      notifyListeners();
    });
  }

  Future<void> removeHistoryItem(int index) async {
    await SharedPreferences.getInstance().then((pref) {
      final history = pref.getStringList('history') ?? [];
      history.removeAt(index);
      pref.setStringList('history', history);
    });
    await loadIdentifiedSong();
  }

  Future<void> clearHistory() async {
    await SharedPreferences.getInstance().then((pref) {
      pref.setStringList('history', []);
    });
    await loadIdentifiedSong();
  }

  Future<void> searchLyrics(String artist, String title) async {
    try {
      isSearchingLyrics = true;
      notifyListeners();
      lyrics = await Lyrics.getLyrics(artist, title).timeout(
        Duration(seconds: 20),
        onTimeout: () =>
            throw CustomException('Taking too long, try again later'),
      );
    } on CustomException catch (error) {
      playlistDB.showToast(error.message, context, isSuccess: false);
    } catch (error) {
      print(error);
    } finally {
      isSearchingLyrics = false;
      notifyListeners();
    }
  }

  void reset() {
    lyrics = [];
  }
}
