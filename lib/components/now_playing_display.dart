import 'package:flutter/material.dart';
import 'package:musicPlayer/util/config.dart';
import 'package:musicPlayer/providers/song_controller.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class NowPlayingDisplay extends StatefulWidget {
  final double iconSize;
  final bool isRotating;
  NowPlayingDisplay({this.iconSize, this.isRotating});

  @override
  _NowPlayingDisplay createState() => _NowPlayingDisplay();
}

class _NowPlayingDisplay extends State<NowPlayingDisplay>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  bool _isLoading = false;
  int _pageIndex = 0;

  @override
  void initState() {
    super.initState();
    _animationController = new AnimationController(
      vsync: this,
      duration: new Duration(seconds: 5),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  stopRotation() {
    _animationController.stop();
  }

  startRotation() {
    _animationController.repeat();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SongController>(
      builder: (context, controller, child) {
        widget.isRotating && !controller.useArt
            ? startRotation()
            : stopRotation();
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
              : AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _animationController.value * 6.3,
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 30),
                        child: Center(
                          child: Icon(
                            Icons.music_note,
                            color: Theme.of(context).splashColor,
                            size: Config.yMargin(context, widget.iconSize),
                          ),
                        ),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).scaffoldBackgroundColor,
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context).splashColor,
                              offset: Offset(5, 5),
                              blurRadius: 10,
                              spreadRadius: 1.0,
                            ),
                            BoxShadow(
                              color: Theme.of(context).backgroundColor,
                              offset: Offset(-5, -5),
                              blurRadius: 10,
                              spreadRadius: 1.0,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
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
                      padding: EdgeInsets.all(20),
                      child: _isLoading
                          ? CircularProgressIndicator(strokeWidth: 2)
                          : Text('Get lyrics'),
                      onPressed: () async {
                        setState(() {
                          _isLoading = true;
                        });
                        try {
                          await controller.getLyrics();
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
                    itemExtent: 30,
                    children: controller.lyrics.map((e) => Text(e)).toList(),
                    diameterRatio: 1.0,
                  ),
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
