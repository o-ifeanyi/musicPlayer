import 'package:flutter/material.dart';
import 'package:musicPlayer/models/config.dart';

class CustomButton extends StatefulWidget {
  CustomButton(
      {this.diameter, this.onPressed, this.child, this.isToggled = false});
  final double diameter;
  final IconData child;
  final Function onPressed;
  final bool isToggled;

  @override
  _CustomButtonState createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton>
    with SingleTickerProviderStateMixin {
  double _scale;
  AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
      lowerBound: 0.0,
      upperBound: 0.3,
    )..addListener(() {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    _scale = 1 - _controller.value;
    return GestureDetector(
      onTap: widget.onPressed,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      child: Transform.scale(
        scale: _scale,
        child: Container(
          child: Center(
            child: Icon(
              widget.child,
              size: Config.textSize(context, 5),
            ),
          ),
          height: Config.xMargin(context, widget.diameter),
          width: Config.xMargin(context, widget.diameter),
          decoration: BoxDecoration(
            color: widget.isToggled ? Theme.of(context).accentColor : Theme.of(context).scaffoldBackgroundColor,
            shape: BoxShape.circle,
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
        ),
      ),
    );
  }
}
