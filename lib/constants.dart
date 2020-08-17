import 'package:flutter/material.dart';
//splash color = dark shadow
//background color = white shadow

final kDarkTheme = ThemeData(
  brightness: Brightness.dark,
  backgroundColor: Color(0xFF31373D),
  splashColor: Color(0xFF1A1E21),
  scaffoldBackgroundColor: Color(0xFF282C31),
  accentColor: Color(0xFFF86300),
  dividerColor: Colors.white54,
);

final kLightTheme = ThemeData(
  brightness: Brightness.light,
  splashColor: Colors.black.withOpacity(0.2),
  backgroundColor: Colors.white,
  scaffoldBackgroundColor: Colors.grey[100],
  accentColor: Color(0xFF789FFF),
  dividerColor: Colors.black45,
);