import 'package:flutter/material.dart';
//splash color = dark shadow
//background color = white shadow

final List kThemes = [
  // light themes

  ThemeData(
    brightness: Brightness.light,
    splashColor: Colors.black.withOpacity(0.2),
    primaryColor: Color(0xFFD71D1D),
    backgroundColor: Colors.white,
    scaffoldBackgroundColor: Colors.grey[100],
    dividerColor: Colors.black45,
    fontFamily: 'Acme',
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
      inactiveTrackColor: Colors.black45,
    ),
    textSelectionTheme: TextSelectionThemeData(cursorColor: Color(0xFFD71D1D)),
    colorScheme:
        ColorScheme.fromSwatch().copyWith(secondary: Color(0xFFD71D1D)),
  ),
  ThemeData(
    brightness: Brightness.light,
    splashColor: Color(0xFFAD95A1),
    primaryColor: Color(0xFFD71D1D),
    dialogBackgroundColor: Color(0xFFF9D7E8),
    backgroundColor: Color(0xFFF9D7E8),
    scaffoldBackgroundColor: Color(0xFFEBCBDC),
    dividerColor: Colors.black45,
    fontFamily: 'Acme',
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
      inactiveTrackColor: Colors.black45,
    ),
    textSelectionTheme: TextSelectionThemeData(cursorColor: Color(0xFFD71D1D)),
    colorScheme:
        ColorScheme.fromSwatch().copyWith(secondary: Color(0xFFD71D1D)),
  ),
  ThemeData(
    brightness: Brightness.light,
    splashColor: Color(0xFF798EAD),
    primaryColor: Color(0xFFD71D1D),
    backgroundColor: Color(0xFFAECCF9),
    dialogBackgroundColor: Color(0xFFAECCF9),
    scaffoldBackgroundColor: Color(0xFFA5C1EB),
    dividerColor: Colors.black45,
    fontFamily: 'Acme',
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
      inactiveTrackColor: Colors.black45,
    ),
    textSelectionTheme: TextSelectionThemeData(cursorColor: Color(0xFFD71D1D)),
    colorScheme:
        ColorScheme.fromSwatch().copyWith(secondary: Color(0xFFD71D1D)),
  ),

  // Dark themes

  ThemeData(
    splashColor: Color(0xFF011025),
    dialogBackgroundColor: Color(0xFF0B2A3D),
    primaryColor: Colors.deepOrange,
    backgroundColor: Color(0xFF0B2A3D),
    scaffoldBackgroundColor: Color(0xFF031F32),
    dividerColor: Colors.white54,
    fontFamily: 'Acme',
    sliderTheme: SliderThemeData(
      trackHeight: 1.0,
      thumbColor: Colors.deepOrange,
      thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6),
      overlayColor: Colors.blueAccent.withOpacity(0.1),
      activeTrackColor: Colors.deepOrange,
      inactiveTrackColor: Colors.white54,
    ),
    textSelectionTheme: TextSelectionThemeData(cursorColor: Colors.deepOrange),
    colorScheme: ColorScheme.fromSwatch(
      primarySwatch: Colors.indigo,
      brightness: Brightness.dark,
    ).copyWith(secondary: Colors.deepOrange),
  ),
  ThemeData(
    backgroundColor: Color(0xFF31373D),
    splashColor: Color(0xFF1A1E21),
    scaffoldBackgroundColor: Color(0xFF282C31),
    primaryColor: Colors.pinkAccent,
    dividerColor: Colors.white54,
    fontFamily: 'Acme',
    sliderTheme: SliderThemeData(
      trackHeight: 1.0,
      thumbColor: Colors.pinkAccent,
      thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6),
      overlayColor: Colors.pinkAccent.withOpacity(0.1),
      activeTrackColor: Colors.pinkAccent,
      inactiveTrackColor: Colors.white54,
    ),
    textSelectionTheme: TextSelectionThemeData(cursorColor: Colors.pinkAccent),
    colorScheme: ColorScheme.fromSwatch().copyWith(
      secondary: Colors.pinkAccent,
      brightness: Brightness.dark,
    ),
  ),
  ThemeData(
    backgroundColor: Color(0xFF302326),
    splashColor: Color(0xFF21181B),
    scaffoldBackgroundColor: Color(0xFF2A1E21),
    dialogBackgroundColor: Color(0xFF302326),
    primaryColor: Colors.deepOrange,
    dividerColor: Colors.white54,
    fontFamily: 'Acme',
    sliderTheme: SliderThemeData(
      trackHeight: 1.0,
      thumbColor: Colors.deepOrange,
      thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6),
      overlayColor: Colors.pinkAccent.withOpacity(0.1),
      activeTrackColor: Colors.deepOrange,
      inactiveTrackColor: Colors.white54,
    ),
    textSelectionTheme: TextSelectionThemeData(cursorColor: Colors.deepOrange),
    colorScheme: ColorScheme.fromSwatch().copyWith(
      secondary: Colors.deepOrange,
      brightness: Brightness.dark,
    ),
  ),
  ThemeData(
    backgroundColor: Color(0xFF213330),
    dialogBackgroundColor: Color(0xFF213330),
    splashColor: Color(0xFF172321),
    scaffoldBackgroundColor: Color(0xFF1C2C29),
    primaryColor: Colors.deepOrange,
    dividerColor: Colors.white54,
    fontFamily: 'Acme',
    sliderTheme: SliderThemeData(
        trackHeight: 1.0,
        thumbColor: Colors.deepOrange,
        thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6),
        overlayColor: Colors.pinkAccent.withOpacity(0.1),
        activeTrackColor: Colors.deepOrange,
        inactiveTrackColor: Colors.white54),
    textSelectionTheme: TextSelectionThemeData(cursorColor: Colors.deepOrange),
    colorScheme: ColorScheme.fromSwatch().copyWith(
      secondary: Colors.deepOrange,
      brightness: Brightness.dark,
    ),
  ),
  ThemeData(
    backgroundColor: Color(0xFF252436),
    dialogBackgroundColor: Color(0xFF252436),
    splashColor: Color(0xFF181925),
    scaffoldBackgroundColor: Color(0xFF1F1F2E),
    primaryColor: Colors.pinkAccent,
    dividerColor: Colors.white54,
    fontFamily: 'Acme',
    sliderTheme: SliderThemeData(
      trackHeight: 1.0,
      thumbColor: Colors.pinkAccent,
      thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6),
      overlayColor: Colors.pinkAccent.withOpacity(0.1),
      activeTrackColor: Colors.pinkAccent,
      inactiveTrackColor: Colors.white54,
    ),
    textSelectionTheme: TextSelectionThemeData(cursorColor: Colors.pinkAccent),
    colorScheme: ColorScheme.fromSwatch().copyWith(
      secondary: Colors.pinkAccent,
      brightness: Brightness.dark,
    ),
  ),
];
