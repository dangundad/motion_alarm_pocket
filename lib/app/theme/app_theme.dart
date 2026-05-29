import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class AppTheme {
  static final TextTheme _textTheme = GoogleFonts.notoSansTextTheme();

  static ThemeData get light => FlexThemeData.light(
        scheme: FlexScheme.redM3,
        textTheme: _textTheme,
        useMaterial3: true,
        visualDensity: FlexColorScheme.comfortablePlatformDensity,
      );

  static ThemeData get dark => FlexThemeData.dark(
        scheme: FlexScheme.redM3,
        textTheme: _textTheme,
        useMaterial3: true,
        visualDensity: FlexColorScheme.comfortablePlatformDensity,
      );
}
