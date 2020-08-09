import 'package:flutter/material.dart';
import 'package:musicPlayer/models/config.dart';

class CircleDisc extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 30),
      child: Center(
        child: Icon(
          Icons.music_note,
          color: Colors.grey[200],
          size: Config.yMargin(context, 15),
        ),
      ),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            offset: Offset(6, 6),
            blurRadius: 10,
          ),
          BoxShadow(
            color: Colors.white,
            offset: Offset(-6, -6),
            blurRadius: 15,
          ),
        ],
      ),
    );
  }
}
