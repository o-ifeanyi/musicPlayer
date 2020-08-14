import 'dart:async';

import 'package:flutter/material.dart';
import 'package:musicPlayer/components/circleDisc.dart';
import 'package:musicPlayer/components/createPlayList.dart';
import 'package:musicPlayer/components/customButton.dart';
import 'package:musicPlayer/models/config.dart';
import 'package:musicPlayer/models/playListDB.dart';
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
      await player.setUp(widget.currentSong);
      setState(() {
        isPlaying = player.isPlaying;
      });
    } else if (player.nowPlaying == widget.currentSong) {
      setState(() {
        isPlaying = widget.isPlaying;
      });
    } else if (player.nowPlaying != widget.currentSong) {
      player.disposePlayer();
      nowPlaying = widget.currentSong;
      await player.setUp(nowPlaying);
      setState(() {
        isPlaying = player.isPlaying;
      });
    }
  }

  @override
  void initState() {
    setUp();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var isPotrait = MediaQuery.of(context).orientation == Orientation.portrait;
    return WillPopScope(
      onWillPop: () {
        //when opened from playlist a bool is expected
        Navigator.pop(context, isPlaying);
        return;
      },
      child: SafeArea(
        child: Scaffold(
          body: Consumer<SongController>(
            builder: (context, controller, child) {
              return Container(
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
                            Navigator.pop(context, isPlaying);
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
                        ? Expanded(
                            child: RotateWidget(CircleDisc(20), isPlaying))
                        : SizedBox(
                            height: Config.xMargin(context, 1),
                          ),
                    SizedBox(
                      height: Config.xMargin(context, 3),
                    ),
                    Text(
                      controller.nowPlaying['title'] ?? '',
                      style: TextStyle(
                        fontSize: Config.textSize(context, 3.5),
                        fontWeight: FontWeight.w400,
                        fontFamily: 'Acme',
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: Config.xMargin(context, 1),
                    ),
                    Text(
                      controller.nowPlaying['artist'] ?? '',
                      style: TextStyle(
                        fontSize: Config.textSize(context, 3),
                        fontFamily: 'Acme',
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        CustomButton(
                          diameter: 12,
                          child: SongController.isFavourite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          onPressed: () async {
                            await Provider.of<PlayListDB>(context,
                                    listen: false)
                                .addToPlaylist(
                                    'Favourites', controller.nowPlaying);
                          },
                        ),
                        CustomButton(
                          diameter: 12,
                          child: Icons.playlist_add,
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return CreatePlayList(
                                  height: 35,
                                  width: 35,
                                  isCreateNew: false,
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                    SizedBox(
                      height: Config.xMargin(context, 6),
                    ),
                    controller.duration != null
                        ? Row(
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
                          )
                        : SizedBox.shrink(),
                    SizedBox(
                      height: Config.xMargin(context, 3),
                    ),
                    controller.duration != null
                        ? LinearProgressIndicator(
                            value: ((controller.currentTime /
                                        controller.duration.inSeconds) *
                                    100) /
                                100.0,
                            backgroundColor: Colors.grey[300],
                            valueColor: AlwaysStoppedAnimation(
                                Theme.of(context).accentColor),
                          )
                        : SizedBox.shrink(),
                    SizedBox(
                      height: Config.xMargin(context, 6),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        CustomButton(
                          diameter: 12,
                          child: Icons.skip_previous,
                          onPressed: () async {
                            await player.skip(prev: true, context: context);
                            setState(() {
                              isPlaying = player.isPlaying;
                            });
                          },
                        ),
                        CustomButton(
                          diameter: 15,
                          child: Icons.replay_10,
                          onPressed: () async {
                            await player.seek(rewind: true);
                          },
                        ),
                        CustomButton(
                          diameter: 18,
                          child: isPlaying ? Icons.pause : Icons.play_arrow,
                          onPressed: () {
                            isPlaying ? player.pause() : player.play();
                            setState(() {
                              isPlaying = player.isPlaying;
                            });
                          },
                        ),
                        CustomButton(
                          diameter: 15,
                          child: Icons.forward_10,
                          onPressed: () async {
                            player.seek(forward: true);
                          },
                        ),
                        CustomButton(
                          diameter: 12,
                          child: Icons.skip_next,
                          onPressed: () async {
                            await player.skip(next: true, context: context);
                            setState(() {
                              isPlaying = player.isPlaying;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
