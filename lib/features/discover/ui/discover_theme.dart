import 'package:flutter/material.dart';

/// Premium dark-purple / neon palette. Sirf is feature ke liye.
class DiscoverColors {
  static const bgTop = Color(0xFF1A0736);
  static const bgBottom = Color(0xFF0B0214);
  static const surface = Color(0xFF26104A);
  static const surfaceHigh = Color(0xFF331862);
  static const neonPurple = Color(0xFFB388FF);
  static const neonPink = Color(0xFFFF4DFF);
  static const neonCyan = Color(0xFF18FFFF);
  static const online = Color(0xFF69F0AE);
  static const danger = Color(0xFFFF5252);
  static const textDim = Color(0xFFB8A9D9);
}

class DiscoverTheme {
  static const backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [DiscoverColors.bgTop, DiscoverColors.bgBottom],
  );

  static BoxDecoration card({Color? color}) => BoxDecoration(
        color: color ?? DiscoverColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: DiscoverColors.neonPurple.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: DiscoverColors.neonPink.withValues(alpha: 0.12),
            blurRadius: 16,
            spreadRadius: 1,
          ),
        ],
      );

  static ThemeData apply(ThemeData base) => base.copyWith(
        scaffoldBackgroundColor: DiscoverColors.bgBottom,
        colorScheme: base.colorScheme.copyWith(
          primary: DiscoverColors.neonPurple,
          secondary: DiscoverColors.neonPink,
          surface: DiscoverColors.surface,
        ),
        textTheme: base.textTheme.apply(bodyColor: Colors.white, displayColor: Colors.white),
      );
}
