import 'package:audio_session/audio_session.dart';
import 'package:audiotagger/audiotagger.dart';
import 'package:flutter/cupertino.dart';
// import 'package:flutter_media_notification/flutter_media_notification.dart';
import 'package:just_audio/just_audio.dart';
import 'package:musicPlayer/models/exception.dart';
import 'package:musicPlayer/models/song.dart';
import 'package:musicPlayer/providers/playList_database.dart';
import 'package:musicPlayer/services/lyrics.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SongController extends ChangeNotifier {
  AudioPlayer player;
  Duration duration;
  int currentTime = 0;
  int songLenght = 0;
  int currentSongIndex;
  String timeLeft = '';
  String timePlayed = '';
  String playlistName; // this is assigned from playlist screen
  List<Song> allSongs; // this is assigned from playlist screen
  List<String> lyrics = [];
  bool isFavourite = false;
  bool isShuffled = false;
  bool isRepeat = false;
  bool isPlaying = false;
  bool useArt = false;
  Song nowPlaying;
  Song lastPlayed;
  dynamic songArt;
  AppLifecycleState state;
  PlayListDB playListDB = PlayListDB();

  void init() async {
    await SharedPreferences.getInstance().then((pref) {
      isShuffled = pref.getBool('shuffle') ?? false;
      isRepeat = pref.getBool('repeat') ?? false;
      useArt = pref.getBool('useArt') ?? false;
    });
    lastPlayed = await playListDB.lastPlayed();
    notifyListeners();
  }

  Future<void> setFavourite(Song song) async {
    isFavourite = await playListDB.isFavourite(song);
    notifyListeners();
  }

  Future<void> manageLyrics({BuildContext context, bool delete}) async {
    final audioTagger = Audiotagger();
    String lyricsValue = delete ? '' : lyrics.join('\n').trim();
    bool successful = await audioTagger.writeTag(
      path: nowPlaying?.path,
      tagField: 'lyrics',
      value: lyricsValue,
    );
    successful
        ? playListDB.showToast(
            delete ? 'Lyrics deleted' : 'Lyrics saved', context)
        : playListDB.showToast('Something went wrong', context,
            isSuccess: false);
    if (!delete) return;
    lyrics = [];
    notifyListeners();
  }

  Future<void> getLyrics(BuildContext context) async {
    final audioTagger = Audiotagger();
    var info;
    try {
      info = await audioTagger.readTagsAsMap(path: nowPlaying?.path);
    } catch (e) {
      debugPrint(e.toString());
    }
    if (info == null || info['lyrics'] == '') {
      try {
        lyrics = await Lyrics.getLyrics(nowPlaying?.artist, nowPlaying?.title)
            .timeout(
          Duration(seconds: 20),
          onTimeout: () =>
              throw CustomException('Taking too long, try again later'),
        );
        playListDB.showToast('Done', context);
      } on CustomException catch (err) {
        playListDB.showToast(err.message, context, isSuccess: false);
      } catch (error) {
        print(error);
      }
    } else {
      lyrics = (info['lyrics'] as String).split('\n');
    }
    notifyListeners();
  }

  Future<void> setUseArt(bool value) async {
    await SharedPreferences.getInstance().then((pref) {
      pref.setBool('useArt', value);
    });
    useArt = value;
    if (nowPlaying.path != null && useArt) {
      await Audiotagger().readArtwork(path: nowPlaying.path).then((value) {
        // not sure if this is a fix yet
        // songArt that were blank had lenght less than 20k
        value.length < 20000 ? songArt = null : songArt = value;
      }).catchError((e) => songArt = null);
    }
    notifyListeners();
  }

  void setIsPlaying(bool val) {
    isPlaying = val;
    notifyListeners();
  }

  Future<void> setUp(Song song) async {
    if (song != null) {
      nowPlaying = song;
      currentSongIndex =
          allSongs.indexWhere((element) => element.path == nowPlaying.path);
      player = AudioPlayer();
      duration = await player.setFilePath(nowPlaying.path);
      songLenght = duration.inSeconds;
      timeLeft = '${duration.inMinutes}:${duration.inSeconds % 60}';
      if (useArt) {
        await Audiotagger().readArtwork(path: nowPlaying.path).then((value) {
          // not sure if this is a fix yet
          // songArt that were blank had lenght less than 20k
          value.length < 20000 ? songArt = null : songArt = value;
        }).catchError((e) => songArt = null);
      }
      isFavourite = await playListDB.isFavourite(nowPlaying);
      playListDB.saveNowPlaying(nowPlaying);
      getPosition();
      play();
      handleInterruptions();
    }
  }

  void getPosition() {
    player.positionStream.listen(
      (event) async {
        currentTime = event.inSeconds;
        timePlayed = '${event.inMinutes}:${event.inSeconds % 60}';
        if (currentTime >= songLenght) {
          await skip(next: true);
          // refresh notification
          showNotification();
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

  Future<void> seek(position) async {
    await player.seek(Duration(seconds: currentTime + position.toInt()));
  }

  Future<void> skip({bool next = false, bool prev = false}) async {
    currentSongIndex =
        allSongs.indexWhere((element) => element.path == nowPlaying.path);
    List shuffled = [...allSongs];
    await disposePlayer();
    try {
      if (isRepeat) {
        nowPlaying = nowPlaying;
      } else if (isShuffled) {
        shuffled.shuffle();
        currentSongIndex =
            shuffled.indexWhere((element) => element.path == nowPlaying.path);
        nowPlaying = next
            ? shuffled[currentSongIndex += 1]
            : shuffled[currentSongIndex -= 1];
      } else {
        nowPlaying = next
            ? allSongs[currentSongIndex += 1]
            : allSongs[currentSongIndex -= 1];
      }
    } on RangeError catch (e) {
      nowPlaying = allSongs.first;
      debugPrint(e.toString());
    } finally {
      await setUp(nowPlaying);
      notifyListeners();
    }
  }

  Future<void> playlistControlOptions(Song playlistNowPlaying) async {
    // if nothing is currently playing
    if (nowPlaying?.path == null) {
      await setUp(playlistNowPlaying);
      setIsPlaying(true);
      // if the song currently playing is taped on
    } else if (nowPlaying?.path == playlistNowPlaying.path) {
      isPlaying ? pause() : play();
      // if a different song is selected
    } else if (nowPlaying?.path != playlistNowPlaying.path) {
      disposePlayer();
      await setUp(playlistNowPlaying);
      setIsPlaying(true);
    }
  }

  Future<void> stop() async {
    await player.stop();
  }

  Future<void> disposePlayer() async {
    try {
      await player.dispose();
    } catch (e) {
      debugPrint(e.toString());
    }
    setIsPlaying(false);
    currentTime = 0;
    timeLeft = '';
    timePlayed = '';
    lyrics = [];
    notifyListeners();
  }

  void settings({bool repeat = false, bool shuffle = false}) {
    isShuffled = shuffle;
    isRepeat = repeat;
    notifyListeners();
  }

  void showNotification() {
    if (state != AppLifecycleState.paused) {
      return;
    } else {
      print("Here show notification");
      // MediaNotification.showNotification(
      //   title: nowPlaying.title,
      //   author: nowPlaying.artist,
      //   isPlaying: isPlaying,
      // );
    }
  }

  void handleInterruptions() {
    AudioSession.instance.then((session) async {
      player.playbackEventStream.listen((event) {
        // Activate session only if a song is playing
        if (player.playing) {
          session.setActive(true);
        }
      }).onError((e) => print(e));
      session.interruptionEventStream.listen((event) {
        if (event.begin) {
          // Another app started playing audio and we should pause.
          switch (event.type) {
            case AudioInterruptionType.duck:
            case AudioInterruptionType.pause:
            // online media like youtube false under unknown
            case AudioInterruptionType.unknown:
              pause();
              // refresh notification
              showNotification();
              break;
            default:
          }
        } else {
          // else block runs at the end of an interruption
          switch (event.type) {
            default:
          }
        }
      });
      session.becomingNoisyEventStream.listen((_) {
        // earphones unpluged
        pause();
      });
    });
  }
}
