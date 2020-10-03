import 'package:flutter/material.dart';
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
                Container(
                  height: Config.xMargin(context, 12),
                  width: Config.xMargin(context, 12),
                  child: Icon(
                    child,
                    size: Config.textSize(context, 5),
                    color: Theme.of(context).iconTheme.color.withOpacity(0.8),
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    shape: BoxShape.circle,
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Theme.of(context).splashColor,
                        offset: Offset(3, 3),
                        blurRadius: 5,
                        spreadRadius: 1.0,
                      ),
                      BoxShadow(
                        color: Theme.of(context).backgroundColor,
                        offset: Offset(-3, -3),
                        blurRadius: 5,
                        spreadRadius: 1.0,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: Config.xMargin(context, 30),
                  child: Text(
                      label,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: Config.textSize(context, 3.5),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                ),
              ],
            ),
            numOfSongs != null
                ? Text(
                    '$numOfSongs Songs',
                    style: TextStyle(
                      fontSize: Config.textSize(context, 3),
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
    );
  }
}
