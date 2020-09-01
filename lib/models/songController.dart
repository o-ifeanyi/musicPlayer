import 'package:audio_session/audio_session.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_media_notification/flutter_media_notification.dart';
import 'package:just_audio/just_audio.dart';
import 'package:musicPlayer/models/playListDB.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SongController extends ChangeNotifier {
  SongController() {
    init();
  }
  AudioPlayer player;
  Duration duration;
  int currentTime = 0;
  String timeLeft = '';
  String timePlayed = '';
  String playlistName; // this is assigned from playlist screen
  List allSongs; // this is assigned from playlist screen
  static bool isFavourite = false;
  bool isShuffled = false;
  bool isRepeat = false;
  int currentSong;
  Map nowPlaying = {};
  bool isPlaying = false;
  int songLenght = 0;
  AppLifecycleState state;
  PlayListDB playListDB = PlayListDB();

  void init() async {
    await SharedPreferences.getInstance().then((pref) {
      isShuffled = pref.getBool('shuffle') ?? false;
      isRepeat = pref.getBool('repeat') ?? false;
    });
    notifyListeners();
  }

  void handleInterruptions() {
    AudioSession.instance.then((session) async {
      player.playbackStateStream.listen((event) {
        // Activate session only if a song is playing
        if (event == AudioPlaybackState.playing) {
          session.setActive(true);
        }
      }).onError((e) => print(e));
      session.interruptionEventStream.listen((event) {
        if (event.begin) {
          print('event began');
          switch (event.type) {
            case AudioInterruptionType.duck:
            case AudioInterruptionType.pause:
            case AudioInterruptionType.unknown:
              // Another app started playing audio and we should pause.
              pause();
              break;
          }
        } else {
          print('event ended');
          switch (event.type) {
            case AudioInterruptionType.duck:
            case AudioInterruptionType.pause:
            case AudioInterruptionType.unknown:
              // The interruption ended and we should resume.
              play();
              break;
          }
        }
      });
      session.becomingNoisyEventStream.listen((_) {
        // earphones unpluged
        pause();
      });
    });
  }

  void settings({bool repeat = false, bool shuffle = false}) {
    isShuffled = shuffle;
    isRepeat = repeat;
    notifyListeners();
  }

  void setIsPlaying(bool val) {
    isPlaying = val;
    notifyListeners();
  }

  Future<void> setUp(dynamic song) async {
    nowPlaying = song;
    isFavourite = await playListDB.isFavourite(nowPlaying);
    playListDB.saveNowPlaying(nowPlaying);
    currentSong =
        allSongs.indexWhere((element) => element['path'] == nowPlaying['path']);
    player = AudioPlayer();
    duration = await player.setFilePath(nowPlaying['path']);
    songLenght = duration.inSeconds;
    timeLeft = '${duration.inMinutes}:${duration.inSeconds % 60}';
    getPosition();
    play();
    handleInterruptions();
  }

  void getPosition() {
    player.getPositionStream().listen(
      (event) async {
        currentTime = event.inSeconds;
        timePlayed = '${event.inMinutes}:${event.inSeconds % 60}';
        if (currentTime >= songLenght) {
          await skip(next: true);
          if (state == AppLifecycleState.paused) {
            MediaNotification.showNotification(
              title: nowPlaying['title'],
              author: nowPlaying['artist'],
              isPlaying: isPlaying,
            );
          }
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
    if (forward)
      await player.seek(Duration(seconds: currentTime + 10));
    else
      await player.seek(Duration(seconds: currentTime - 10));
  }

  Future<void> skip(
      {bool next = false, bool prev = false, BuildContext context}) async {
    currentSong =
        allSongs.indexWhere((element) => element['path'] == nowPlaying['path']);
    List shuffled = [...allSongs];
    await disposePlayer();
    try {
      if (isRepeat) {
        nowPlaying = nowPlaying;
      } else if (isShuffled) {
        shuffled.shuffle();
        currentSong = shuffled
            .indexWhere((element) => element['path'] == nowPlaying['path']);
        nowPlaying =
            next ? shuffled[currentSong += 1] : shuffled[currentSong -= 1];
      } else {
        nowPlaying =
            next ? allSongs[currentSong += 1] : allSongs[currentSong -= 1];
      }
    } on RangeError catch (e) {
      nowPlaying = allSongs.first;
      debugPrint(e.toString());
    } finally {
      await setUp(nowPlaying);
      notifyListeners();
    }
  }

  Future<void> playlistControlOptions(dynamic playlistNowPlaying) async {
    // if nothing is currently playing
    if (nowPlaying['path'] == null) {
      await setUp(playlistNowPlaying);
      setIsPlaying(true);
      // if the song currently playing is taped on
    } else if (nowPlaying['path'] == playlistNowPlaying['path']) {
      isPlaying ? pause() : play();
      // if a different song is selected
    } else if (nowPlaying['path'] != playlistNowPlaying['path']) {
      disposePlayer();
      await setUp(playlistNowPlaying);
      setIsPlaying(true);
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
