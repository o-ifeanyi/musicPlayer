import 'package:flutter/material.dart';
import 'package:musicPlayer/components/customButton.dart';

class CustomCard extends StatelessWidget {
  CustomCard(
      {this.width,
      this.height,
      this.onPressed,
      this.label,
      this.numOfSongs,
      this.child});
  final double width;
  final double height;
  final String label;
  final int numOfSongs;
  final Icon child;
  final Function onPressed;
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
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
                    isRaised: false,
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
              numOfSongs != null
                  ? Text('$numOfSongs Songs')
                  : SizedBox.shrink(),
            ],
          ),
        ),
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Colors.grey[200],
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
      ),
    );
  }
}
