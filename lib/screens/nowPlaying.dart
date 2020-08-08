import 'dart:async';

import 'package:flutter/material.dart';
import 'package:musicPlayer/components/circleDisc.dart';
import 'package:musicPlayer/components/customButton.dart';
import 'package:musicPlayer/constants.dart';
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

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  Future<void> setUp() async {
    setState(() {
      isPlaying = true;
    });
    player = Provider.of<SongController>(context, listen: false);
    await player.setUp(widget.currentSong, context);
  }

  @override
  void initState() {
    setUp();

    super.initState();
  }

  @override
  void deactivate() {
    player.disposePlayer();
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
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
                  ? Expanded(child: RotateWidget(CircleDisc(), isPlaying))
                  : SizedBox(height: 10),
              Consumer<SongController>(
                builder: (context, controller, child) {
                  return Text(
                    controller.nowPlaying['title'] ?? '',
                    style: kSubHeadingText,
                    textAlign: TextAlign.center,
                  );
                },
              ),
              Consumer<SongController>(
                builder: (context, controller, child) {
                  return Text(controller.nowPlaying['artist'] ?? '');
                },
              ),
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
              Consumer<SongController>(
                builder: (context, controller, child) {
                  if (controller.duration != null) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(controller.timePlayed),
                        Text(controller.timeLeft),
                      ],
                    );
                  } else {
                    return SizedBox.shrink();
                  }
                },
              ),
              SizedBox(
                height: 20,
              ),
              Consumer<SongController>(
                builder: (context, controller, child) {
                  if (controller.duration != null) {
                    return LinearProgressIndicator(
                      value: ((controller.currentTime /
                                  controller.duration.inSeconds) *
                              100) /
                          100.0,
                      backgroundColor: Colors.grey[300],
                      valueColor:
                          AlwaysStoppedAnimation(Theme.of(context).accentColor),
                    );
                  } else {
                    return SizedBox.shrink();
                  }
                },
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
                      await player.skip(prev: true, context: context);
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
                      await player.skip(next: true, context: context);
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
