import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:support/utils/color.dart';

// Set Theme for app.

class MyTheme {
  static final lightTheme = ThemeData(
      useMaterial3: true,
      fontFamily: GoogleFonts.poppins().fontFamily,
      colorSchemeSeed: primaryColor,
      floatingActionButtonTheme:
          FloatingActionButtonThemeData(foregroundColor: primaryColor),
      elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
        foregroundColor: colorWhite,
        backgroundColor: primaryColor,
        surfaceTintColor: primaryColor,
      )));
}
