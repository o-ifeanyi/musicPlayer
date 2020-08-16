import 'package:flutter/cupertino.dart';
import 'package:just_audio/just_audio.dart';
import 'package:musicPlayer/models/playListDB.dart';

class SongController extends ChangeNotifier {
  AudioPlayer player;
  Duration duration;
  int currentTime = 0;
  String timeLeft = '';
  String timePlayed = '';
  List
      allSongs; // this is assigned from library depending on the plalist that is opened
  static bool isFavourite = false;
  int currentSong;
  dynamic nowPlaying;
  bool isPlaying = false;
  int songLenght = 0;
  PlayListDB playListDB = PlayListDB();

  void setIsPlaying(bool val) {
    isPlaying = val;
    notifyListeners();
  }

  Future<void> setUp(dynamic song) async {
    nowPlaying = song;
    isFavourite = await playListDB.isFavourite(nowPlaying);
    playListDB.saveNowPlaying(nowPlaying);
    currentSong = allSongs.indexOf(nowPlaying);
    player = AudioPlayer();
    duration = await player.setFilePath(nowPlaying['path']);
    songLenght = duration.inSeconds;
    timeLeft = '${duration.inMinutes}:${duration.inSeconds % 60}';
    getPosition();
    play();
  }

  void getPosition() {
    player.getPositionStream().listen(
      (event) {
        currentTime = event.inSeconds;
        timePlayed = '${event.inMinutes}:${event.inSeconds % 60}';
        if (currentTime == songLenght) {
          skip(next: true);
        }
        notifyListeners();
      },
    ).onError((error) => print('hmmmmm: $error'));
  }

  Future<void> play() async {
    setIsPlaying(true);
    player.play();
  }

  Future<void> pause() async {
    setIsPlaying(false);
    player.pause();
  }

  Future<void> seek({bool forward = false, bool rewind = false}) async {
    if (forward) {
      await player.seek(Duration(seconds: currentTime + 10));
    } else {
      await player.seek(Duration(seconds: currentTime - 10));
    }
  }

  Future<void> skip(
      {bool next = false, bool prev = false, BuildContext context}) async {
    currentSong = allSongs.indexOf(nowPlaying);
    await disposePlayer();
    try {
      nowPlaying =
          next ? allSongs[currentSong += 1] : allSongs[currentSong -= 1];
    } on RangeError catch (e) {
      nowPlaying = allSongs.first;
      debugPrint(e.toString());
    } finally {
      await setUp(nowPlaying);
      notifyListeners();
    }
  }

  Future<void> stop() async {
    await player.stop();
  }

  Future<void> disposePlayer() async {
    if (player.playbackState == AudioPlaybackState.playing ||
        player.playbackState == AudioPlaybackState.paused) {
      await player.dispose();
    }
    setIsPlaying(false);
    currentTime = 0;
    timeLeft = '';
    timePlayed = '';
    notifyListeners();
  }
}
