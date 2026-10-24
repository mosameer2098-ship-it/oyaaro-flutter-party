import 'package:flutter/material.dart';

class FrameSpec {
  final int milestone; // 1..20 (level = milestone * 10)
  final String name;
  final List<Color> colors;
  const FrameSpec(this.milestone, this.name, this.colors);
}

// 20 frames, har milestone ka alag rang aur naam
class Frames {
  static const _names = [
    'Bronze', 'Silver', 'Gold', 'Emerald', 'Sapphire', 'Ruby', 'Amethyst',
    'Onyx', 'Opal', 'Pearl', 'Coral', 'Jade', 'Topaz', 'Garnet', 'Aqua',
    'Crimson', 'Violet', 'Platinum', 'Cosmic', 'Royal',
  ];

  static final List<FrameSpec> all = List.generate(20, (i) {
    final hue = i * 18.0;
    return FrameSpec(i + 1, _names[i], [
      HSVColor.fromAHSV(1, hue, 0.75, 0.95).toColor(),
      HSVColor.fromAHSV(1, (hue + 40) % 360, 0.85, 0.7).toColor(),
    ]);
  });

  static FrameSpec byMilestone(int m) => all[m - 1];
}
