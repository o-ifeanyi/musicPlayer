import 'package:flutter/material.dart';
import 'package:musicPlayer/models/config.dart';

class CustomButton extends StatelessWidget {
  CustomButton(
      {this.diameter, this.onPressed, this.child});
  final double diameter;
  final IconData child;
  final Function onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        child: Center(
          child: Icon(child, size: Config.textSize(context, 5),),
        ),
        height: Config.xMargin(context, diameter),
        width: Config.xMargin(context, diameter),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          shape: BoxShape.circle,
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
