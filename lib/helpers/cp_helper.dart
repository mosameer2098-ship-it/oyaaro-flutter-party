import 'package:flutter/material.dart';
import 'package:oyaroo/core/cp_levels.dart';

class CpProgress {
  final int level;
  final double progress;
  final int nextExp;
  const CpProgress(this.level, this.progress, this.nextExp);
}

class CpHelper {
  static CpProgress progressOf(int exp) {
    final level = CpLevels.levelFor(exp);
    if (level >= CpLevels.maxLevel) return CpProgress(level, 1.0, exp);
    final cur = CpLevels.requiredExp(level);
    final next = CpLevels.requiredExp(level + 1);
    final p = ((exp - cur) / (next - cur)).clamp(0.0, 1.0).toDouble();
    return CpProgress(level, p, next);
  }

  static String titleOf(int level) => CpLevels.titles[level - 1];

  static Color colorOf(int level) => CpLevels.colorFor(level);
}
