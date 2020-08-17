import 'package:flutter/material.dart';
import 'package:musicPlayer/components/circleDisc.dart';
import 'package:musicPlayer/components/customButton.dart';
import 'package:musicPlayer/components/rotateWidget.dart';
import 'package:musicPlayer/models/config.dart';
import 'package:musicPlayer/models/songController.dart';
import 'package:provider/provider.dart';

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
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 20, top: 30, right: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        CustomButton(
                          diameter: 12,
                          child: Icons.arrow_back,
                          onPressed: () => Navigator.pop(context, isPlaying),
                        ),
                        Column(
                          children: <Widget>[
                            Text('Playing From',
                                style: TextStyle(
                                    fontSize: Config.textSize(context, 5),
                                    fontWeight: FontWeight.w400,
                                    fontFamily: 'Acme'),
                                textAlign: TextAlign.center),
                            SizedBox(height: 5),
                            Text(
                              controller.playlistName,
                              style: TextStyle(
                                  fontSize: Config.textSize(context, 3.5),
                                  fontFamily: 'Acme'),
                            ),
                          ],
                        ),
                        CustomButton(
                          diameter: 12,
                          child: Icons.more_vert,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    height: isPotrait ? 250 : 100,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        CustomButton(
                          diameter: 12,
                          child: Icons.repeat,
                        ),
                        isPotrait
                            ? Expanded(
                                child: RotateWidget(
                                    CircleDisc(10), controller.isPlaying))
                            : SizedBox.shrink(),
                        CustomButton(
                          diameter: 12,
                          child: Icons.shuffle,
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
                          padding: controller.nowPlaying == songList[index] &&
                                  controller.isPlaying
                              ? EdgeInsets.symmetric(vertical: padding)
                              : EdgeInsets.all(0),
                          child: ListTile(
                            onTap: () async {
                              nowPlaying = songList[index];
                              if (controller.nowPlaying == nowPlaying) {
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
                            selected: controller.nowPlaying == songList[index],
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
                              child: controller.nowPlaying == songList[index] &&
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
