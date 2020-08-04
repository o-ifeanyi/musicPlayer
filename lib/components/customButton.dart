import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  CustomButton({this.isRaised = false, this.diameter, this.onPressed, this.child});
  final double diameter;
  final bool isRaised;
  final Widget child;
  final Function onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        child: Center(
          child: child,
        ),
        height: diameter,
        width: diameter,
        decoration: BoxDecoration(
          gradient: isRaised
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white,
                    Colors.grey[200],
                    Colors.grey[300],
                    Colors.grey[400],
                  ],
                  stops: [
                    0.0,
                    0.4,
                    0.6,
                    0.8,
                  ],
                ) : null,
          color: Colors.grey[200],
          shape: BoxShape.circle,
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              offset: isRaised ? Offset(6, 6) : Offset(3, 3),
              blurRadius: 10,
              spreadRadius: 1.0,
            ),
            BoxShadow(
              color: Colors.white,
              offset: isRaised ? Offset(-6, -6) : Offset(-3, -3),
              blurRadius: 10,
              spreadRadius: 1.0,
            ),
          ],
        ),
      ),
    );
  }
}