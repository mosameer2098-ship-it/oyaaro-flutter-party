// User level: max 200, har 10 level par reward milta hai (coins + frame)
class LevelRules {
  static const maxLevel = 200;
  static const milestoneEvery = 10;
  static const milestoneCount = 20; // 200 / 10

  // Level L tak pahunchne ke liye total exp
  static int requiredExp(int level) => 100 * (level - 1) * level;

  static int levelFor(int exp) {
    var level = 1;
    while (level < maxLevel && exp >= requiredExp(level + 1)) {
      level++;
    }
    return level;
  }

  static int rewardCoins(int milestone) => 500 * milestone;

  // Level 1-10 = tier 1, 11-20 = tier 2 ...
  static int tierOf(int level) => ((level - 1) ~/ milestoneEvery) + 1;
}
