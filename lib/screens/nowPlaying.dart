import 'dart:async';

import 'package:flutter/material.dart';
import 'package:musicPlayer/components/circleDisc.dart';
import 'package:musicPlayer/components/customButton.dart';
import 'package:musicPlayer/constants.dart';
import 'package:musicPlayer/models/Provider.dart';
import 'package:musicPlayer/screens/playingFrom.dart';
import 'package:musicPlayer/models/songController.dart';
import 'package:musicPlayer/components/rotateWidget.dart';
import 'package:provider/provider.dart';

class NowPlaying extends StatefulWidget {
  final currentSong;
  final bool isPlaying;
  NowPlaying({this.currentSong, this.isPlaying});
  @override
  _NowPlayingState createState() => _NowPlayingState();
}

class _NowPlayingState extends State<NowPlaying> {
  dynamic nowPlaying;
  bool isPlaying = false;
  SongController player;
  Timer timer;
  String timeLeft = '';
  String timePlayed = '0:00';
  int seconds = 1; //to avoid NaN error when dividing
  int currentTime = 0;
  int count = 0;

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  void formatTime() {
    if (player != null) {
      Duration duration = Duration(seconds: player.songLenght);
      seconds = player.songLenght;
      currentTime = 0;
      setState(() {
        timeLeft = '${duration.inMinutes}:${duration.inSeconds % 60}';
      });
    }
  }

  void getPosition() {
    if (mounted && player != null) {
      player.getPlayer().getPositionStream().listen(
        (event) {
          setState(() {
            currentTime = event.inSeconds;
          });
        },
      );
      player.getPlayer().durationStream.listen((event) {
        if (event != null) {
          Duration timeRemaining =
              Duration(seconds: event.inSeconds - currentTime);
          Duration playedTime = Duration(seconds: currentTime);
          setState(() {
            timeLeft =
                '${timeRemaining.inMinutes}:${timeRemaining.inSeconds % 60}';
            timePlayed = '${playedTime.inMinutes}:${playedTime.inSeconds % 60}';
          });
        }
      }).onError((error) => print('hmmmmm: $error'));
    }
  }

  Future<void> setUp(dynamic song) async {
    setState(() {
      isPlaying = true;
    });
    player = SongController(song);
    await player.setUp();
    formatTime();
    await player.play();
  }

  @override
  void initState() {
    nowPlaying = widget.currentSong;
    setUp(nowPlaying);
    super.initState();
  }

  @override
  void deactivate() {
    player.dispose();
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    getPosition();
    var isPotrait = MediaQuery.of(context).orientation == Orientation.portrait;
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.fromLTRB(20, 30, 20, 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  CustomButton(
                    diameter: 50,
                    child: Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  Text(
                    'Now Playing',
                    style: kHeadingText,
                  ),
                  CustomButton(
                    diameter: 50,
                    child: Icon(Icons.list),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => PlayingFrom()),
                      );
                    },
                  ),
                ],
              ),
              isPotrait
                  ? Expanded(
                      child: RotateWidget(
                          CircleDisc(nowPlaying['image']), isPlaying))
                  : SizedBox(height: 10),
              Text(
                nowPlaying['title'],
                style: kSubHeadingText,
                textAlign: TextAlign.center,
              ),
              Text(nowPlaying['artist']),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  CustomButton(
                    diameter: 50,
                    child: Icon(Icons.favorite_border),
                  ),
                  CustomButton(
                    diameter: 50,
                    child: Icon(Icons.playlist_add),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(timePlayed),
                  Text(timeLeft),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              LinearProgressIndicator(
                value: ((currentTime / seconds) * 100) / 100.0,
                backgroundColor: Colors.grey[300],
                valueColor:
                    AlwaysStoppedAnimation(Theme.of(context).accentColor),
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  CustomButton(
                    diameter: 40,
                    child: Icon(Icons.repeat_one),
                  ),
                  CustomButton(
                    diameter: 50,
                    child: Icon(Icons.fast_rewind),
                    onPressed: () async {
                      await player.dispose();
                      var allSongs =
                          Provider.of<ProviderClass>(context, listen: false)
                              .allSongs;
                      int current = allSongs.indexOf(nowPlaying);
                      setState(() {
                        try {
                          nowPlaying = allSongs[current -= 1];
                        } on RangeError catch (e) {
                          debugPrint(e.toString());
                          nowPlaying = allSongs.first;
                        }
                      });
                      await setUp(nowPlaying);
                    },
                  ),
                  CustomButton(
                    diameter: 80,
                    child: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                    onPressed: () {
                      isPlaying ? player.pause() : player.play();
                      setState(() {
                        isPlaying = !isPlaying;
                      });
                    },
                  ),
                  CustomButton(
                    diameter: 50,
                    child: Icon(Icons.fast_forward),
                    onPressed: () async {
                      await player.dispose();
                      var allSongs =
                          Provider.of<ProviderClass>(context, listen: false)
                              .allSongs;
                      int current = allSongs.indexOf(nowPlaying);
                      setState(() {
                        try {
                          nowPlaying = allSongs[current += 1];
                        } on RangeError catch (e) {
                          debugPrint(e.toString());
                          nowPlaying = allSongs.last;
                        }
                      });
                      await setUp(nowPlaying);
                    },
                  ),
                  CustomButton(
                    diameter: 40,
                    child: Icon(Icons.shuffle),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
