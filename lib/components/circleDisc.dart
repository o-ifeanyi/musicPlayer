import 'package:flutter/material.dart';
import 'package:musicPlayer/models/config.dart';
import 'package:musicPlayer/models/songController.dart';
import 'package:provider/provider.dart';

class CircleDisc extends StatefulWidget {
  final double iconSize;
  final bool isRotating;
  CircleDisc({this.iconSize, this.isRotating});

  @override
  _CircleDiscState createState() => _CircleDiscState();
}

class _CircleDiscState extends State<CircleDisc>
    with SingleTickerProviderStateMixin {
  AnimationController animationController;

  @override
  void initState() {
    super.initState();
    animationController = new AnimationController(
      vsync: this,
      duration: new Duration(seconds: 5),
    );
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  stopRotation() {
    animationController.stop();
  }

  startRotation() {
    animationController.repeat();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SongController>(
      builder: (context, controller, child) {
        widget.isRotating && !controller.useArt ? startRotation() : stopRotation();
        return controller.useArt
            ? Container(
              margin: EdgeInsets.only(top: 30,),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                  image: controller.songArt == null
                      ? AssetImage('images/album_art.png')
                      : MemoryImage(controller.songArt),
                  fit: BoxFit.cover,
                ),
              ),
              child: null,
            )
            : AnimatedBuilder(
                animation: animationController,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: animationController.value * 6.3,
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
                            offset: Offset(6, 6),
                            blurRadius: 10,
                          ),
                          BoxShadow(
                            color: Theme.of(context).backgroundColor,
                            offset: Offset(-6, -6),
                            blurRadius: 15,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
      },
    );
  }
}
