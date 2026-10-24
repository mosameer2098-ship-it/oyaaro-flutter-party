import 'package:flutter/material.dart';

import '../models/theme_spec.dart';

/// 12 room themes + 12 couple themes. Server (buyTheme) mein bhi same id/price list.
class ThemeCatalog {
  const ThemeCatalog._();

  static const _roomNames = [
    'Midnight Violet', 'Neon Dusk', 'Aurora Night', 'Ruby Lounge', 'Emerald Club', 'Sapphire Sky',
    'Golden Hour', 'Cosmic Ink', 'Rose Haze', 'Ocean Glow', 'Amber Den', 'Starfield',
  ];

  static const _coupleNames = [
    'Blush Promise', 'Velvet Heart', 'Moonlit Pair', 'Rose Vow', 'Sunset Embrace', 'Twin Stars',
    'Lavender Bond', 'Golden Ring', 'Crystal Love', 'Ember Hearts', 'Aurora Vows', 'Eternal Garden',
  ];

  static final List<ThemeSpec> room = List.generate(12, (i) {
    final hue = i * 30.0;
    return ThemeSpec(
      id: 'room_${(i + 1).toString().padLeft(2, '0')}',
      name: _roomNames[i],
      kind: ThemeKind.room,
      price: 300 + i * 150,
      colors: [
        HSVColor.fromAHSV(1, hue, 0.75, 0.30).toColor(),
        HSVColor.fromAHSV(1, (hue + 25) % 360, 0.9, 0.08).toColor(),
      ],
    );
  });

  static final List<ThemeSpec> couple = List.generate(12, (i) {
    final hue = ((330 + i * 25) % 360).toDouble();
    return ThemeSpec(
      id: 'couple_${(i + 1).toString().padLeft(2, '0')}',
      name: _coupleNames[i],
      kind: ThemeKind.couple,
      price: 500 + i * 200,
      colors: [
        HSVColor.fromAHSV(1, hue, 0.55, 0.95).toColor(),
        HSVColor.fromAHSV(1, (hue + 40) % 360, 0.7, 0.85).toColor(),
        Colors.white,
      ],
    );
  });

  static final List<ThemeSpec> all = [...room, ...couple];

  static final Map<String, ThemeSpec> _byId = {for (final t in all) t.id: t};

  static ThemeSpec? byId(String id) => _byId[id];
}
