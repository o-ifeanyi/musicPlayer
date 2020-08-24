import 'package:flutter/material.dart';
import 'package:musicPlayer/models/config.dart';
import 'package:musicPlayer/screens/library.dart';

class SplashScreen extends StatefulWidget {
  SplashScreen(this.isDark);
  final bool isDark;
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  AnimationController controller;
  CurvedAnimation curvedAnimation;
  Animation colorAnimation;
  bool isDark;

  @override
  void initState() {
    controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
      upperBound: 1.0,
    )..addListener(() {
        setState(() {
          if (controller.isCompleted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => Library()),
            );
          }
        });
      });
    curvedAnimation =
        CurvedAnimation(parent: controller, curve: Curves.decelerate);
    colorAnimation = ColorTween(
            begin: Colors.white,
            end: widget.isDark ? Color(0xFF282C31) : Colors.grey[100])
        .animate(controller);
    super.initState();
  }

  @override
  void deactivate() {
    controller.dispose();
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    var isPotrait = MediaQuery.of(context).orientation == Orientation.portrait;
    double height = isPotrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    double width = MediaQuery.of(context).size.width;
    double padding = isPotrait
        ? curvedAnimation.value * (height / 3.1)
        : curvedAnimation.value * (height / 10.5);
    controller.forward();

    return Scaffold(
      backgroundColor: colorAnimation.value,
      body: Container(
        height: height,
        width: width,
        padding: EdgeInsets.symmetric(vertical: padding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: Config.xMargin(context, curvedAnimation.value * 60),
              height: Config.yMargin(context, curvedAnimation.value * 30),
              child: Opacity(
                opacity: curvedAnimation.value,
                child: Image(
                  image: AssetImage('images/logo.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Opacity(
              opacity: curvedAnimation.value,
              child: Text(
                'Flutter Music',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: Config.textSize(context, curvedAnimation.value * 8),
                  fontWeight: FontWeight.w400,
                  fontFamily: 'Acme',
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
