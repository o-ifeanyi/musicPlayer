import 'package:flutter/material.dart';
import 'package:musicPlayer/components/customButton.dart';

class CustomCard extends StatelessWidget {
  CustomCard(
      {this.width, this.height, this.label, this.numOfSongs, this.child});
  final double width;
  final double height;
  final String label;
  final int numOfSongs;
  final Icon child;

  @override
  Widget build(BuildContext context) {
    return Container(
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
                  diameter: 50,
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            numOfSongs != null ? Text('$numOfSongs Songs') : SizedBox.shrink(),
          ],
        ),
      ),
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            offset: Offset(6, 6),
            blurRadius: 10,
            spreadRadius: 1.0,
          ),
          BoxShadow(
            color: Colors.white,
            offset: Offset(-6, -6),
            blurRadius: 10,
            spreadRadius: 1.0,
          ),
        ],
      ),
    );
  }
}
