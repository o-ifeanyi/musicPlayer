import 'dart:async';

import 'package:flutter/material.dart';
import 'package:musicPlayer/components/circleDisc.dart';
import 'package:musicPlayer/components/customButton.dart';
import 'package:musicPlayer/models/config.dart';
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
    player = Provider.of<SongController>(context, listen: false);
    if (player.nowPlaying == null) {
      await player.setUp(widget.currentSong, context);
    } else if (player.nowPlaying == widget.currentSong) {
      
      print('same song');
    } else if (player.nowPlaying != widget.currentSong) {
      player.disposePlayer();
      nowPlaying = widget.currentSong;
      player.setUp(widget.currentSong, context);
    }
    setState(() {
        isPlaying = true;
      });
  }

  @override
  void initState() {
    setUp();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var isPotrait = MediaQuery.of(context).orientation == Orientation.portrait;
    return SafeArea(
      child: Scaffold(
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.fromLTRB(20, 30, 20, 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  CustomButton(
                    diameter: 12,
                    child: Icons.arrow_back,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  Text(
                    'Now Playing',
                    style: TextStyle(
                      fontSize: Config.textSize(context, 5),
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Acme',
                    ),
                  ),
                  CustomButton(
                    diameter: 12,
                    child: Icons.list,
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
                  ? Expanded(child: RotateWidget(CircleDisc(20), isPlaying))
                  : SizedBox(
                      height: Config.xMargin(context, 1),
                    ),
              SizedBox(
                height: Config.xMargin(context, 3),
              ),
              Consumer<SongController>(
                builder: (context, controller, child) {
                  return Text(
                    controller.nowPlaying['title'] ?? '',
                    style: TextStyle(
                      fontSize: Config.textSize(context, 3.5),
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Acme',
                    ),
                    textAlign: TextAlign.center,
                  );
                },
              ),
              SizedBox(
                height: Config.xMargin(context, 1),
              ),
              Consumer<SongController>(
                builder: (context, controller, child) {
                  return Text(
                    controller.nowPlaying['artist'] ?? '',
                    style: TextStyle(
                      fontSize: Config.textSize(context, 3),
                      fontFamily: 'Acme',
                    ),
                  );
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  CustomButton(
                    diameter: 12,
                    child: Icons.favorite_border,
                  ),
                  CustomButton(
                    diameter: 12,
                    child: Icons.playlist_add,
                  ),
                ],
              ),
              SizedBox(
                height: Config.xMargin(context, 6),
              ),
              Consumer<SongController>(
                builder: (context, controller, child) {
                  if (controller.duration != null) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          controller.timePlayed,
                          style: TextStyle(
                            fontSize: Config.textSize(context, 3),
                            fontFamily: 'Acme',
                          ),
                        ),
                        Text(
                          controller.timeLeft,
                          style: TextStyle(
                            fontSize: Config.textSize(context, 3),
                            fontFamily: 'Acme',
                          ),
                        ),
                      ],
                    );
                  } else {
                    return SizedBox.shrink();
                  }
                },
              ),
              SizedBox(
                height: Config.xMargin(context, 3),
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
                height: Config.xMargin(context, 6),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  CustomButton(
                    diameter: 12,
                    child: Icons.repeat_one,
                  ),
                  CustomButton(
                    diameter: 15,
                    child: Icons.fast_rewind,
                    onPressed: () async {
                      await player.skip(prev: true, context: context);
                    },
                  ),
                  CustomButton(
                    diameter: 18,
                    child: isPlaying ? Icons.pause : Icons.play_arrow,
                    onPressed: () {
                      isPlaying ? player.pause() : player.play();
                      setState(() {
                        isPlaying = !isPlaying;
                      });
                    },
                  ),
                  CustomButton(
                    diameter: 15,
                    child: Icons.fast_forward,
                    onPressed: () async {
                      await player.skip(next: true, context: context);
                    },
                  ),
                  CustomButton(diameter: 12, child: Icons.shuffle),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
