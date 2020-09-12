import 'package:flutter/cupertino.dart';

class ShareClass extends ChangeNotifier {
  List markedSongs = [];
  bool isReadyToMark = false;

  void isMarking() {
    markedSongs.length > 0 ? isReadyToMark = true : isReadyToMark = false;
    notifyListeners();
  }

  void add(dynamic song) {
    markedSongs.add(song);
    notifyListeners();
  }

  void remove(dynamic song) {
    markedSongs.removeWhere((element) => element['path'] == song['path']);
    isMarking();
    notifyListeners();
  }

  void reset({bool notify = false}) {
    isReadyToMark = false;
    markedSongs.clear();
    if (notify) {
      notifyListeners();
    }
  }

  bool isMarked(dynamic song) {
    return markedSongs.any((element) => element['path'] == song['path']);
  }
}
