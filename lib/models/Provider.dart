import 'dart:io';
import 'package:audiotagger/audiotagger.dart';
import 'package:flutter/cupertino.dart';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class ProviderClass extends ChangeNotifier {
  ProviderClass(this._themeData);

  ThemeData _themeData;
  List allSongs = [];
  List recentlyAdded = [];

  getTheme() => _themeData;

  setTheme(ThemeData themeData) {
    _themeData = themeData;
    notifyListeners();
  }

  void init() async {
    await getAllSongs();
    recentActivity();
  }

  void recentActivity() {
    List newList1 = allSongs;
    newList1.sort((b, a) => a['recentlyAdded'].compareTo(b['recentlyAdded']));
    // sort arranged it from old to new hence the reverse
    recentlyAdded.addAll(newList1);
    // sort all songs in alphabetical order
    allSongs.sort(
        (a, b) => a['title'].toLowerCase().compareTo(b['title'].toLowerCase()));
    notifyListeners();
  }

  void removeSong(dynamic song) {
    allSongs.removeWhere((element) => element['path'] == song['path']);
    recentlyAdded.removeWhere((element) => element['path'] == song['path']);
    notifyListeners();
  }

  Future<void> getAllSongs() async {
    PermissionStatus permissionStatus = await Permission.storage.request();
    if (permissionStatus.isGranted && Platform.isAndroid) {
      List<Directory> deviceStorages = await getExternalStorageDirectories();
      List<Directory> pathToStorage = [];
      for (var dir in deviceStorages) {
        // adds path of differnt storage to list
        pathToStorage.add(Directory(dir.path.split("Android")[0]));
      }
      // gets all the folders in eachFile storage. or adds to allsongs list if an mp3 is found
      List<FileSystemEntity> allFolders = await getAllFolders(pathToStorage);
      // goes through all folders to find mp3, if a folder is found it recurses into it to find mp3
      await searchFolders(allFolders);
    } else {
      permissionStatus = await Permission.storage.request();
    }
    notifyListeners();
  }

  // returns a list of everything in the storage path (device and memory card). including mp3
  Future<List<FileSystemEntity>> getAllFolders(List paths) async {
    List<FileSystemEntity> allFolders = [];
    for (var dir in paths) {
      allFolders.addAll([...dir.listSync()]);
    }
    return allFolders;
  }

  Future<void> searchFolders(List folders) async {
    for (FileSystemEntity eachFile in folders) {
      if (FileSystemEntity.isFileSync(eachFile.path) &&
          basename(eachFile.path).endsWith('mp3')) {
        allSongs.add(await songInfo(eachFile.path));
        notifyListeners();
      } else if (FileSystemEntity.isDirectorySync(eachFile.path)) {
        await getAllFiles(eachFile.path);
      }
    }
  }

  // recursively goes into all folders to return mp3 except the android folder
  Future<void> getAllFiles(String path) async {
    for (FileSystemEntity file in Directory(path).listSync()) {
      if (FileSystemEntity.isFileSync(file.path) &&
          basename(file.path).endsWith('mp3')) {
        allSongs.add(await songInfo(file.path));
        notifyListeners();
      } else if (FileSystemEntity.isDirectorySync(file.path) &&
          !basename(file.path).startsWith('.') &&
          !file.path.contains('/Android')) {
        getAllFiles(file.path);
      } else {
        // print('no mp3 found');
      }
    }
  }

  Future<Map<String, dynamic>> songInfo(String file) async {
    var audioTagger = Audiotagger();
    var info;
    var fileInfo;
    var date;
    try {
      info = await audioTagger.readTagsAsMap(
        path: file,
      );
      fileInfo = File(file);
      date = fileInfo.lastAccessedSync();
    } catch (e) {
      debugPrint(e.toString());
    }
    return {
      'path': file,
              'title':
          info != null && info['title'] != ''
              ? info['title']
              : file.split('/').last.split('.mp3').first,
      'artist': info != null && info['artist'] != ''
          ? info['artist']
          : 'Unknown artist',
      'recentlyAdded': date ?? 999999,
    };
  }
}
