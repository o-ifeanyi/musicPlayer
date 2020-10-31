import 'dart:io';

class Song {
  String path;
  String title;
  String artist;
  String genre;
  String album;
  String year;
  DateTime dateAdded;

  Song.fromMap(Map<dynamic, dynamic> info, {String filePath}) {
    if (info == null) {
      return;
    }
    var date;
    try {
      // if coming from db filepath will be null
      date = File(filePath ?? info['path']).lastAccessedSync();
    } catch (err) {
      // date = something...
      print(err);
    }
    // if coming from db filepath will be null
    this.path = filePath ?? info['path'];
    this.title = info['title'] != ''
        ? info['title']
        : filePath.split('/').last.split('.mp3').first;
    this.artist = info['artist'] != '' ? info['artist'] : 'Unknown artist';
    this.genre = info['genre'];
    this.album = info['album'];
    this.year = info['year'];
    this.dateAdded = date;
  }

  Map<dynamic, dynamic> toMap() {
    return {
      'path': this.path,
      'title': this.title,
      'artist': this.artist,
      'genre': this.genre,
      'album': this.album,
      'year': this.year,
    };
  }
}
