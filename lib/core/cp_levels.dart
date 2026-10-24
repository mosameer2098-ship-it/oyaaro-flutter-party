import 'package:flutter/material.dart';

// CP bond ke 15 levels. Bond exp = partners ke beech messages.
class CpLevels {
  static const maxLevel = 15;
  static const titles = [
    'Jaan-Pehchan', 'Dost', 'Achha Dost', 'Pakka Dost', 'Jigri Dost',
    'Yaar', 'Bestie', 'Shaan', 'Sirtaaj', 'Mehboob',
    'Hamsafar', 'Rooh', 'Dil ka Tukda', 'Soulmate', 'Legend',
  ];

  static int requiredExp(int level) => 20 * (level - 1) * level ~/ 2;

  static int levelFor(int exp) {
    var level = 1;
    while (level < maxLevel && exp >= requiredExp(level + 1)) {
      level++;
    }
    return level;
  }

  // Har level ka alag rang
  static Color colorFor(int level) =>
      HSVColor.fromAHSV(1, ((level - 1) * 24) % 360.0, 0.7, 0.95).toColor();
}
