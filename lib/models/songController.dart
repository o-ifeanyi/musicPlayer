import 'package:flutter/cupertino.dart';
import 'package:just_audio/just_audio.dart';
import 'package:musicPlayer/models/Provider.dart';
import 'package:provider/provider.dart';

class SongController extends ChangeNotifier {
  AudioPlayer player;
  Duration duration;
  int currentTime = 0;
  String timeLeft = '';
  String timePlayed = '';
  List allSongs;
  int currentSong;
  dynamic nowPlaying;

  Future<void> setUp(dynamic song, BuildContext context) async {
    allSongs = Provider.of<ProviderClass>(context, listen: false).allSongs;
    nowPlaying = song;
    currentSong = allSongs.indexOf(song);
    player = AudioPlayer();
    duration = await player.setFilePath(nowPlaying['path']);
    timeLeft = '${duration.inMinutes}:${duration.inSeconds % 60}';
    getPosition();
    play();
  }

  void getPosition() {
    player.getPositionStream().listen(
      (event) {
        currentTime = event.inSeconds;
        timePlayed = '${event.inMinutes}:${event.inSeconds % 60}';
        notifyListeners();
      },
    ).onError((error) => print('hmmmmm: $error'));
  }

  Future<void> play() async {
    await player.play();
  }

  Future<void> pause() async {
    await player.pause();
  }

  Future<void> skip(
      {bool next = false, bool prev = false, BuildContext context}) async {
    currentSong = allSongs.indexOf(nowPlaying);
    try {
      nowPlaying =
          next ? allSongs[currentSong += 1] : allSongs[currentSong -= 1];
      await disposePlayer();
      await setUp(nowPlaying, context);
    } on RangeError catch (e) {
      nowPlaying = allSongs.first;
      await disposePlayer();
      await setUp(nowPlaying, context);
      notifyListeners();
      debugPrint(e.toString());
    }
  }

  Future<void> stop() async {
    await player.stop();
  }

  Future<void> disposePlayer() async {
    await player.dispose();
    currentTime = 0;
    timeLeft = '';
    timePlayed = '';
    notifyListeners();
  }
}
