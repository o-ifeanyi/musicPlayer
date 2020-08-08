import 'dart:io';
import 'package:audiotagger/audiotagger.dart';
import 'package:flutter/cupertino.dart';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class ProviderClass extends ChangeNotifier {
  ProviderClass () {
    print('searching');
    getAllSongs();
  }
  List allSongs = [];

  Future<void> getAllSongs() async {
    PermissionStatus permissionStatus = await Permission.storage.request();
    if (permissionStatus.isGranted && Platform.isAndroid) {
      List<Directory> deviceStorages = await getExternalStorageDirectories();
      List<Directory> pathToStorage = [];
      for (var dir in deviceStorages) {
        // adds path of differnt storage to list
        pathToStorage.add(Directory(dir.path.split("Android")[0]));
      }
      // gets all the folders in each storage. or adds to allsongs list if an mp3 is found
      List<FileSystemEntity> allFolders = await getAllFolders(pathToStorage);
      // goes through all folders to find mp3, if a folder is found it recurses into it to find mp3
      for (FileSystemEntity folder in allFolders) {
        if (FileSystemEntity.isFileSync(folder.path) &&
            basename(folder.path).endsWith('mp3')) {
          allSongs.add(await songInfo(folder.path));
          notifyListeners();
        } else if (FileSystemEntity.isDirectorySync(folder.path)) {
          getAllFiles(folder.path);
        }
      }
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

  // recursively goes into all folders to return mp3 except the android folder
  void getAllFiles(String path) async {
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
    var filePath = file.toString().replaceAll('\'', '').split('File: ').last;
    var audioTagger = Audiotagger();
    var info = await audioTagger.readTagsAsMap(
      path: filePath,
    );
    return {
      'path': filePath,
      'title': info['title'],
      'artist': info['artist'],
    };
  }
}
