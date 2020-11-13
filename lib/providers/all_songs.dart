import 'dart:io';
import 'package:audiotagger/audiotagger.dart';
import 'package:audiotagger/models/tag.dart';
import 'package:flutter/cupertino.dart';
import 'package:musicPlayer/models/song.dart';
import 'package:musicPlayer/providers/playList_database.dart';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class ProviderClass extends ChangeNotifier {
  ProviderClass({this.themeData});

  ThemeData themeData;
  List<Song> allSongs = [];
  List<Song> recentlyAdded = [];

  getTheme() => themeData;

  setTheme(ThemeData themeData) {
    themeData = themeData;
    notifyListeners();
  }

  void init() async {
    await getAllSongs();
    sortList();
  }

  Future<void> editSongInfo(BuildContext context, Song newSong, {String imagePath}) async {
    final tagger = Audiotagger();
    final playlistDB = PlayListDB();
    final path = newSong.path;
    final tag = Tag(
      title: newSong.title,
      artist: newSong.artist,
      album: newSong.album,
      genre: newSong.genre,
      year: newSong.year,
      artwork: imagePath, // ignored if it is null
    );
    final successful = await tagger.writeTags(
      path: path,
      tag: tag,
    );
    Song editedSong = await songInfo(path);
    int index = allSongs.indexWhere((song) => song.path == newSong.path);
    // replace
    allSongs.replaceRange(index, index + 1, [editedSong]);
    index = recentlyAdded.indexWhere((song) => song.path == newSong.path);
    recentlyAdded.replaceRange(index, index + 1, [editedSong]);
    await playlistDB.replaceSong(newSong);
    successful
        ? playlistDB.showToast('Edited successfully', context)
        : playlistDB.showToast('Something went wrong', context, isSuccess: false);

    notifyListeners();
  }

  void sortList() {
    List<Song> newList = List.from(allSongs);
    newList.sort((b, a) => a.dateAdded.compareTo(b.dateAdded));
    // sort arranged it from old to new hence the reverse
    recentlyAdded.addAll(newList);
    // sort all songs in alphabetical order
    allSongs
        .sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
    notifyListeners();
  }

  void removeSong(Song song) {
    allSongs.removeWhere((element) => element.path == song.path);
    recentlyAdded.removeWhere((element) => element.path == song.path);
    notifyListeners();
  }

  Future<void> getAllSongs() async {
    PermissionStatus permissionStatus = await Permission.storage.request();
    if (permissionStatus.isGranted && Platform.isAndroid) {
      // externalStorageDirectories includes:
      // /storage/emulated/0/Android/data/com.onuifeanyi.vybeplayer/files
      // /storage/1A1C-1205/Android/data/com.onuifeanyi.vybeplayer/files
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

  Future<Song> songInfo(String file) async {
    var audioTagger = Audiotagger();
    var info;
    // var date;
    try {
      info = await audioTagger.readTagsAsMap(
        path: file,
      );
      // date = File(file).lastAccessedSync();
    } catch (e) {
      debugPrint(e.toString());
    }
    return Song.fromMap(info, filePath: file);
  }
}
