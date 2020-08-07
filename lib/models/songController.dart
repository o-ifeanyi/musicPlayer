import 'package:just_audio/just_audio.dart';

class SongController {
  final song;
  SongController(this.song);

  AudioPlayer player;
  Duration duration;
  int position;

  Future<void> setUp() async{
    player = AudioPlayer();
    duration = await player.setFilePath(song['path']);
  }

  get songLenght {
    return duration.inSeconds;
  }

  AudioPlayer getPlayer() {
    return player;
  }

  Future<void> play() async {
    await player.play();
  }

  Future<void> pause() async {
    await player.pause();
  }

  Future<void> stop() async {
    await player.stop();
  }

  Future<void> dispose() async {
    await player.dispose();
  }
  
}