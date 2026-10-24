import '../catalog/level_reward_catalog.dart';
import '../models/level_reward.dart';

enum RewardState { locked, claimable, claimed }

/// Pure level logic. Ye PLACEHOLDER formula hai. Integration par
/// shared LevelMath (v15) se replace karein taaki ek hi formula rahe.
class LevelRules {
  const LevelRules._();

  static const maxLevel = LevelRewardCatalog.maxLevel;

  /// Is level tak pahunchne ke liye total EXP
  static int cumulativeExp(int level) {
    if (level <= 1) return 0;
    final l = level.clamp(1, maxLevel);
    return 500 * l * l * l;
  }

  static int levelFromExp(int exp) {
    var lv = 1;
    while (lv < maxLevel && exp >= cumulativeExp(lv + 1)) {
      lv++;
    }
    return lv;
  }

  /// Agle level tak progress 0..1
  static double progress(int exp) {
    final cur = levelFromExp(exp);
    if (cur >= maxLevel) return 1;
    final a = cumulativeExp(cur);
    final b = cumulativeExp(cur + 1);
    return ((exp - a) / (b - a)).clamp(0.0, 1.0).toDouble();
  }

  static int expToNext(int exp) {
    final cur = levelFromExp(exp);
    if (cur >= maxLevel) return 0;
    return cumulativeExp(cur + 1) - exp;
  }

  static RewardState stateOf({
    required LevelReward reward,
    required int current,
    required Set<String> claimed,
  }) {
    if (claimed.contains(reward.key)) return RewardState.claimed;
    if (current >= reward.level) return RewardState.claimable;
    return RewardState.locked;
  }
}
