import 'package:flutter/material.dart';
import 'package:musicPlayer/components/customButton.dart';
import 'package:musicPlayer/models/config.dart';

class CustomCard extends StatelessWidget {
  CustomCard(
      {this.width, this.height, this.label, this.numOfSongs, this.child});
  final double width;
  final double height;
  final String label;
  final int numOfSongs;
  final IconData child;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Config.yMargin(context, height),
      width: Config.yMargin(context, height),
      child: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                CustomButton(
                  child: child,
                  diameter: 12,
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: Config.textSize(context, 3.5),
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Acme'
                  ),
                ),
              ],
            ),
            numOfSongs != null
                ? Text(
                    '$numOfSongs Songs',
                    style: TextStyle(
                      fontSize: Config.textSize(context, 3),
                      fontFamily: 'Acme'
                    ),
                  )
                : SizedBox.shrink(),
          ],
        ),
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Theme.of(context).splashColor,
            offset: Offset(6, 6),
            blurRadius: 10,
            spreadRadius: 1.0,
          ),
          BoxShadow(
            color: Theme.of(context).backgroundColor,
            offset: Offset(-6, -6),
            blurRadius: 10,
            spreadRadius: 1.0,
          ),
        ],
      ),
    );
  }
}
