import 'package:flutter/material.dart';
import 'package:musicPlayer/util/config.dart';
import 'package:musicPlayer/providers/song_controller.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'cirecle_disc.dart';

class NowPlayingDisplay extends StatefulWidget {
  @override
  _NowPlayingDisplay createState() => _NowPlayingDisplay();
}

class _NowPlayingDisplay extends State<NowPlayingDisplay> {
  bool _isLoading = false;
  int _pageIndex = 0;

  @override
  Widget build(BuildContext context) {
    TextStyle customTextStyle = TextStyle(
      fontSize: Config.textSize(context, 3.5),
      fontWeight: FontWeight.w400,
    );
    return Consumer<SongController>(
      builder: (context, controller, child) {
        List<Widget> display = [
          controller.useArt
              ? Container(
                  margin: EdgeInsets.only(top: 30),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    image: DecorationImage(
                      image: controller.songArt == null
                          ? AssetImage('images/album_art.jpg')
                          : MemoryImage(controller.songArt),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: null,
                )
              : CircleDisc(iconSize: 16),
          Stack(
            children: [
              Container(
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                margin: EdgeInsets.only(top: 30),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: Theme.of(context).textTheme.bodyText1.color)),
                child: controller.lyrics.isEmpty
                    ? Center(
                        child: FlatButton(
                          splashColor: Theme.of(context).accentColor.withOpacity(0.5),
                          padding: EdgeInsets.all(20),
                          child: _isLoading
                              ? CircularProgressIndicator(strokeWidth: 2)
                              : Text('Get lyrics'),
                          onPressed: () async {
                            setState(() {
                              _isLoading = true;
                            });
                            try {
                              await controller.getLyrics(context);
                            } catch (err) {
                              print(err);
                            }
                            setState(() {
                              _isLoading = false;
                            });
                          },
                        ),
                      )
                    : ListWheelScrollView(
                        itemExtent: 35,
                        children: controller.lyrics
                            .map((eachLine) => Text(
                                  eachLine,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                ))
                            .toList(),
                        diameterRatio: 1.0,
                      ),
              ),
              if (controller.lyrics.isNotEmpty) ...[
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: IconButton(
                    icon: Icon(
                      Icons.save_alt_outlined,
                      size: Config.textSize(context, 5),
                    ),
                    onPressed: () async => await controller.manageLyrics(
                      context: context,
                      delete: false,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 10,
                  left: 10,
                  child: IconButton(
                    icon: Icon(
                      Icons.delete_outlined,
                      size: Config.textSize(context, 5),
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text(
                              'Delete lyrics for "${controller.nowPlaying?.title}"?',
                              style: customTextStyle,
                            ),
                            actions: [
                              FlatButton(
                                textColor: Theme.of(context).accentColor,
                                onPressed: () => Navigator.pop(context),
                                child: Text(
                                  'No',
                                ),
                              ),
                              FlatButton(
                                textColor: Theme.of(context).accentColor,
                                onPressed: () async {
                                  await controller.manageLyrics(
                                    context: context,
                                    delete: true,
                                  );
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  'Yes',
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                )
              ]
            ],
          ),
        ];
        return Container(
          child: Column(
            children: [
              Expanded(
                child: PageView(
                  children: display,
                  onPageChanged: (int newIndex) {
                    setState(() {
                      _pageIndex = newIndex;
                    });
                  },
                ),
              ),
              SizedBox(height: 10),
              AnimatedSmoothIndicator(
                count: display.length,
                activeIndex: _pageIndex,
                effect: WormEffect(
                    dotWidth: 7,
                    dotHeight: 7,
                    spacing: 10,
                    activeDotColor: Theme.of(context).accentColor),
              ),
            ],
          ),
        );
      },
    );
  }
}