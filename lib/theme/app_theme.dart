import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color darkBg = Color(0xFF050505);
  static const Color surface = Color(0xFF111111);
  static const Color limeAccent = Color(0xFFC0FF00);
  static const Color textMain = Color(0xFFF5F5F5);

  static ThemeData get theme => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: darkBg,
    colorScheme: const ColorScheme.dark(
      primary: limeAccent,
      surface: surface,
      onSurface: textMain,
    ),
    textTheme: GoogleFonts.interTextTheme(
      ThemeData.dark().textTheme,
    ),
    useMaterial3: true,
  );
}
