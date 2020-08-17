import 'package:flutter/material.dart';
import 'package:musicPlayer/models/config.dart';

class CircleDisc extends StatelessWidget {
  final double iconSize;
  CircleDisc(this.iconSize);
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 30),
      child: Center(
        child: Icon(
          Icons.music_note,
          color: Theme.of(context).splashColor,
          size: Config.yMargin(context, iconSize),
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
    );
  }
}
