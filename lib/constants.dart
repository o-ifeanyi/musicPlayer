import 'package:flutter/material.dart';
//splash color = dark shadow
//background color = white shadow


final List kThemes = [
  ThemeData(
    brightness: Brightness.light,
    splashColor: Colors.black.withOpacity(0.2),
    primaryColor: Color(0xFFD71D1D),
    cursorColor: Color(0xFFD71D1D),
    accentColor: Color(0xFFD71D1D),
    backgroundColor: Colors.white,
    scaffoldBackgroundColor: Colors.grey[100],
    dividerColor: Colors.black45,
    iconTheme: IconThemeData(
      color: Colors.black,
      opacity: 0.8,
    ),
    sliderTheme: SliderThemeData(
      trackHeight: 1.0,
      thumbColor: Color(0xFFD71D1D),
      thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6),
      overlayColor: Color(0xFFD71D1D).withOpacity(0.1),
      activeTrackColor: Color(0xFFD71D1D),
      inactiveTrackColor: Colors.black.withOpacity(0.2),
    ),
  ),
  ThemeData(
    brightness: Brightness.light,
    splashColor: Colors.black.withOpacity(0.2),
    accentColor: Colors.blueAccent,
    backgroundColor: Colors.white,
    scaffoldBackgroundColor: Colors.grey[100],
    dividerColor: Colors.black45,
    iconTheme: IconThemeData(
      color: Colors.black,
      opacity: 0.8,
    ),
    sliderTheme: SliderThemeData(
      trackHeight: 1.0,
      thumbColor: Colors.blueAccent,
      thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6),
      overlayColor: Colors.blueAccent.withOpacity(0.1),
      activeTrackColor: Colors.blueAccent,
      inactiveTrackColor: Colors.black.withOpacity(0.2),
    ),
  ),
  ThemeData(
    brightness: Brightness.dark,
    backgroundColor: Color(0xFF31373D),
    splashColor: Color(0xFF1A1E21),
    scaffoldBackgroundColor: Color(0xFF282C31),
    primaryColor: Colors.pinkAccent,
    accentColor: Colors.pinkAccent,
    cursorColor: Colors.pinkAccent,
    dividerColor: Colors.white54,
    sliderTheme: SliderThemeData(
      trackHeight: 1.0,
      thumbColor: Colors.pinkAccent,
      thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6),
      overlayColor: Colors.pinkAccent.withOpacity(0.1),
      activeTrackColor: Colors.pinkAccent,
      inactiveTrackColor: Color(0xFF1A1E21),
    ),
  ),
  ThemeData(
    brightness: Brightness.dark,
    backgroundColor: Color(0xFF31373D),
    splashColor: Color(0xFF1A1E21),
    scaffoldBackgroundColor: Color(0xFF282C31),
    primaryColor: Colors.deepOrange,
    accentColor: Colors.deepOrange,
    cursorColor: Colors.deepOrange,
    dividerColor: Colors.white54,
    sliderTheme: SliderThemeData(
      trackHeight: 1.0,
      thumbColor: Colors.deepOrange,
      thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6),
      overlayColor: Colors.deepOrange.withOpacity(0.1),
      activeTrackColor: Colors.deepOrange,
      inactiveTrackColor: Color(0xFF1A1E21),
    ),
  ),
];
