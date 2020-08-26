import 'package:flutter/material.dart';
import 'package:musicPlayer/components/circleDisc.dart';
import 'package:musicPlayer/components/customButton.dart';
import 'package:musicPlayer/components/rotateWidget.dart';
import 'package:musicPlayer/models/config.dart';
import 'package:musicPlayer/models/songController.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlayingFrom extends StatefulWidget {
  @override
  _PlayingFromState createState() => _PlayingFromState();
}

class _PlayingFromState extends State<PlayingFrom> {
  dynamic nowPlaying;
  bool isPlaying = false;
  double padding = 10.0;
  @override
  void initState() {
    isPlaying = Provider.of<SongController>(context, listen: false).isPlaying;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isPotrait = MediaQuery.of(context).orientation == Orientation.portrait;

    return WillPopScope(
      onWillPop: () {
        //when opened from nowPlaying a bool is expected
        Navigator.pop(context, isPlaying);
        return;
      },
      child: SafeArea(
        child: Scaffold(
          body: Consumer<SongController>(
            builder: (context, controller, child) {
              return Column(
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.keyboard_arrow_down),
                    onPressed: () {
                      Navigator.pop(context, isPlaying);
                    },
                  ),
                  Text('Playing From - ${controller.playlistName}',
                      style: TextStyle(
                          fontSize: Config.textSize(context, 5),
                          fontWeight: FontWeight.w400,
                          fontFamily: 'Acme'),
                      textAlign: TextAlign.center),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    height: isPotrait ? 250 : 100,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        CustomButton(
                          diameter: 12,
                          child: Icons.repeat_one,
                          isToggled: controller.isRepeat,
                          onPressed: () async {
                            controller.settings(repeat: !controller.isRepeat);
                            SharedPreferences.getInstance().then((pref) {
                              pref.setBool('repeat', controller.isRepeat);
                              pref.setBool('shuffle', controller.isShuffled);
                            });
                          },
                        ),
                        isPotrait
                            ? Expanded(
                                child: RotateWidget(
                                    CircleDisc(10), controller.isPlaying))
                            : SizedBox.shrink(),
                        CustomButton(
                          diameter: 12,
                          child: Icons.shuffle,
                          isToggled: controller.isShuffled,
                          onPressed: () {
                            controller.settings(shuffle: !controller.isShuffled);
                            SharedPreferences.getInstance().then((pref) {
                              pref.setBool('shuffle', controller.isShuffled);
                              pref.setBool('repeat', controller.isRepeat);
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: controller.allSongs.length,
                      itemBuilder: (context, index) {
                        List songList = controller.allSongs;
                        return AnimatedPadding(
                          duration: Duration(milliseconds: 400),
                          padding: controller.nowPlaying['path'] == songList[index]['path'] &&
                                  controller.isPlaying
                              ? EdgeInsets.symmetric(vertical: padding)
                              : EdgeInsets.all(0),
                          child: ListTile(
                            onTap: () async {
                              nowPlaying = songList[index];
                              if (controller.nowPlaying['path'] == nowPlaying['path']) {
                                Navigator.pop(context, isPlaying);
                              } else {
                                await controller
                                    .playlistControlOptions(nowPlaying);
                              }
                              setState(() {
                                isPlaying = controller.isPlaying;
                                isPlaying ? padding = 10.0 : padding = 0.0;
                              });
                            },
                            selected: controller.nowPlaying['path'] == songList[index]['path'],
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 20),
                            title: Text(
                              songList[index]['title'],
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: Config.textSize(context, 3.5),
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'Acme'),
                            ),
                            subtitle: Text(
                              songList[index]['artist'],
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: Config.textSize(context, 3),
                                  fontFamily: 'Acme'),
                            ),
                            trailing: CustomButton(
                              diameter: 12,
                              isToggled: controller.nowPlaying['path'] == songList[index]['path'],
                              child: controller.nowPlaying['path'] == songList[index]['path'] &&
                                      isPlaying
                                  ? Icons.pause
                                  : Icons.play_arrow,
                              onPressed: () async {
                                nowPlaying = songList[index];
                                await controller
                                    .playlistControlOptions(nowPlaying);
                                setState(() {
                                  isPlaying = controller.isPlaying;
                                  isPlaying ? padding = 10.0 : padding = 0.0;
                                });
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
