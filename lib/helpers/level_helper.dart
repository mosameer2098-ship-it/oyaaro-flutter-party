import 'package:oyaroo/core/level_rules.dart';
import 'package:oyaroo/helpers/coin_helper.dart';
import 'package:oyaroo/helpers/frame_helper.dart';

class LevelProgress {
  final int level;
  final double progress; // 0..1
  final int nextExp;
  const LevelProgress(this.level, this.progress, this.nextExp);
}

class LevelHelper {
  static LevelProgress progressOf(int exp) {
    final level = LevelRules.levelFor(exp);
    if (level >= LevelRules.maxLevel) return LevelProgress(level, 1.0, exp);
    final cur = LevelRules.requiredExp(level);
    final next = LevelRules.requiredExp(level + 1);
    final p = ((exp - cur) / (next - cur)).clamp(0.0, 1.0).toDouble();
    return LevelProgress(level, p, next);
  }

  static String milestoneReward(int m) =>
      '${CoinHelper.label(LevelRules.rewardCoins(m))} + ${FrameHelper.nameOf(m)} frame';

  static bool canClaim(int exp, int milestone) =>
      LevelRules.levelFor(exp) >= milestone * LevelRules.milestoneEvery;
}
