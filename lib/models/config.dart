import 'package:flutter/cupertino.dart';

class Config {

  static double yMargin(BuildContext context, double height) {
    double viewPortHeight = MediaQuery.of(context).size.height;
    viewPortHeight = viewPortHeight > 950 ? 950 : viewPortHeight;
    return height * (viewPortHeight / 100);
  }

  static double xMargin(BuildContext context, double width) {
    double viewPortwidth = MediaQuery.of(context).size.width;
    viewPortwidth = viewPortwidth > 650 ? 650 : viewPortwidth;
    return width * (viewPortwidth / 100);
  }

  static double textSize(BuildContext context, double size) {
    double viewPortwidth = MediaQuery.of(context).size.width;
    viewPortwidth = viewPortwidth > 500 ? 500 : viewPortwidth;
    return size * (viewPortwidth / 100);
  }
}