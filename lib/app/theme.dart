import 'package:flutter/material.dart';

/// Oyaaro palette: cream/ivory base with soft yellow accents.
abstract final class OyaaroColors {
  static const background = Color(0xFFF7F5F2);
  static const cream = Color(0xFFFFF8E5);
  static const yellow = Color(0xFFFFC629);
  static const navBackground = Color(0xFFFFF0D8);
  static const navIndicator = Color(0xFFFFE4A5);
  static const ink = Color(0xFF29202B);
  static const muted = Color(0xFF938B91);
  static const tabInactive = Color(0xFF9C946D);
  static const chipBorder = Color(0xFFF0E4C4);
  static const dotInactive = Color(0xFFD9CFA9);
}

ThemeData buildOyaaroTheme() {
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: OyaaroColors.background,
    colorScheme: ColorScheme.fromSeed(
      seedColor: OyaaroColors.yellow,
      brightness: Brightness.light,
    ),
  );
}
