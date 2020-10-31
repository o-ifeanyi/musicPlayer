import 'package:flutter/material.dart';
import 'package:musicPlayer/providers/all_songs.dart';
import 'package:musicPlayer/util/config.dart';
import 'package:musicPlayer/providers/playList_database.dart';
import 'package:musicPlayer/providers/song_controller.dart';
import 'package:musicPlayer/screens/library.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  SplashScreen(this.theme);
  final ThemeData theme;
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  CurvedAnimation _curvedAnimation;
  Animation _colorAnimation;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
      upperBound: 1.0,
    )..addListener(() {
        if (_controller.isCompleted) {
          // getAllSong called here to avoid laggy animation
          Provider.of<ProviderClass>(context, listen: false).init();
          // initialises things like shuffle, repeat, last played
          Provider.of<SongController>(context, listen: false).init();
          // populates playlist from database
          Provider.of<PlayListDB>(context, listen: false).refresh();
          Future.delayed(Duration(seconds: 2)).then((value) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => Library()),
            );
          });
        }
      });
    _curvedAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.decelerate);
    _colorAnimation = ColorTween(
      begin: Colors.white,
      end: widget.theme.scaffoldBackgroundColor,
    ).animate(_controller);
    _controller.forward();
    super.initState();
  }

  @override
  void deactivate() {
    _controller.dispose();
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    var isPotrait = MediaQuery.of(context).orientation == Orientation.portrait;
    double height = isPotrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    double width = MediaQuery.of(context).size.width;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: _colorAnimation.value,
          body: Container(
            height: height,
            width: width,
            padding: EdgeInsets.symmetric(
                vertical: isPotrait
                    ? _curvedAnimation.value * (height / 3.1)
                    : _curvedAnimation.value * (height / 10.5)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Opacity(
                  opacity: _curvedAnimation.value,
                  child: SizedBox(
                    width: Config.xMargin(context, _curvedAnimation.value * 55),
                    height:
                        Config.yMargin(context, _curvedAnimation.value * 25),
                    child: Image(
                      image: AssetImage('images/logo.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Opacity(
                  opacity: _curvedAnimation.value,
                  child: Text(
                    'Vybe player',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize:
                          Config.textSize(context, _curvedAnimation.value * 8),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
