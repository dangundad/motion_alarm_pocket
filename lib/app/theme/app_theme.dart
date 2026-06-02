import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// "Sentry" — a dark-first, tactical identity for the motion alarm.
///
/// Deep slate surfaces with a crimson primary (alarm), an amber armed state,
/// and a steel-blue tertiary. Headings and the timer use Rajdhani (a
/// condensed, instrument-panel face); body text uses Noto Sans. The app ships
/// dark by default; the light scheme is a coherent slate-on-white variant.
abstract final class AppTheme {
  // Tactical palette.
  static const Color _crimson = Color(0xFFE11D48); // primary / alarm
  static const Color _amber = Color(0xFFF59E0B); // secondary / armed
  static const Color _steel = Color(0xFF38BDF8); // tertiary / accent

  static const Color _slateDeep = Color(0xFF0F172A); // background
  static const Color _slateSurface = Color(0xFF131C2E); // surface / cards

  // Body uses Noto Sans; headings + timer override to Rajdhani below.
  static final TextTheme _baseText = GoogleFonts.notoSansTextTheme();

  static TextTheme _tacticalText(TextTheme base) {
    final rajdhani = GoogleFonts.rajdhani().fontFamily;
    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(fontFamily: rajdhani),
      displayMedium: base.displayMedium?.copyWith(fontFamily: rajdhani),
      displaySmall: base.displaySmall?.copyWith(fontFamily: rajdhani),
      headlineLarge: base.headlineLarge
          ?.copyWith(fontFamily: rajdhani, fontWeight: FontWeight.w700),
      headlineMedium: base.headlineMedium
          ?.copyWith(fontFamily: rajdhani, fontWeight: FontWeight.w700),
      headlineSmall: base.headlineSmall
          ?.copyWith(fontFamily: rajdhani, fontWeight: FontWeight.w700),
      titleLarge: base.titleLarge
          ?.copyWith(fontFamily: rajdhani, fontWeight: FontWeight.w600),
    );
  }

  static const FlexSubThemesData _subThemes = FlexSubThemesData(
    cardRadius: 18,
    filledButtonRadius: 16,
    elevatedButtonRadius: 16,
    outlinedButtonRadius: 16,
    inputDecoratorRadius: 14,
    inputDecoratorIsFilled: true,
    segmentedButtonRadius: 12,
    filledButtonSchemeColor: SchemeColor.primary,
    defaultRadius: 16,
    thickBorderWidth: 1.5,
    sliderTrackHeight: 6,
  );

  static final FlexSchemeColor _darkColors = FlexSchemeColor.from(
    primary: _crimson,
    secondary: _amber,
    tertiary: _steel,
    brightness: Brightness.dark,
  );

  static final FlexSchemeColor _lightColors = FlexSchemeColor.from(
    primary: _crimson,
    secondary: const Color(0xFFB45309), // deeper amber reads on white
    tertiary: const Color(0xFF0369A1),
    brightness: Brightness.light,
  );

  static ThemeData get light => FlexThemeData.light(
        colors: _lightColors,
        textTheme: _tacticalText(_baseText),
        useMaterial3: true,
        subThemesData: _subThemes,
        visualDensity: FlexColorScheme.comfortablePlatformDensity,
        surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
        blendLevel: 4,
      );

  static ThemeData get dark => FlexThemeData.dark(
        colors: _darkColors,
        textTheme: _tacticalText(_baseText),
        useMaterial3: true,
        subThemesData: _subThemes,
        visualDensity: FlexColorScheme.comfortablePlatformDensity,
        surfaceMode: FlexSurfaceMode.highScaffoldLowSurface,
        blendLevel: 6,
        scaffoldBackground: _slateDeep,
        surface: _slateSurface,
      );

  // ── Semantic status colors (state-driven, not theme-driven) ──────────────
  /// Crimson — the alarm is actively sounding.
  static const Color alarm = _crimson;

  /// Amber — armed and watching for motion.
  static const Color armed = _amber;

  /// Steel — the arming countdown is running.
  static const Color arming = _steel;

  /// Slate gray — disarmed / idle.
  static const Color disarmed = Color(0xFF64748B);

  static Color cardBackgroundOf(BuildContext context) =>
      Theme.of(context).colorScheme.surfaceContainer;
}
