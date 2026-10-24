/// Level formula. App ke core/level_rules.dart se same hona chahiye.
class LevelMath {
  const LevelMath._();

  static const maxLevel = 200;

  static int requiredExp(int level) => 100 * (level - 1) * level;

  static int levelFor(int exp) {
    var level = 1;
    while (level < maxLevel && exp >= requiredExp(level + 1)) {
      level++;
    }
    return level;
  }

  /// 0..1 progress current level mein
  static double progressFor(int exp) {
    final level = levelFor(exp);
    if (level >= maxLevel) return 1;
    final cur = requiredExp(level);
    final next = requiredExp(level + 1);
    return ((exp - cur) / (next - cur)).clamp(0.0, 1.0).toDouble();
  }
}
