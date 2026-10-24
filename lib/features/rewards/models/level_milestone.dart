/// Har 10 level par ek milestone (1..20). Reward: coins + frame.
class LevelMilestone {
  const LevelMilestone({
    required this.index,
    required this.level,
    required this.coins,
    required this.reached,
    required this.claimed,
  });

  final int index;
  final int level;
  final int coins;
  final bool reached;
  final bool claimed;

  bool get canClaim => reached && !claimed;

  static List<LevelMilestone> build({required int exp, required List<int> claimedIndexes}) {
    final currentLevel = _levelFor(exp);
    return [
      for (var i = 1; i <= 20; i++)
        LevelMilestone(
          index: i,
          level: i * 10,
          coins: 500 * i,
          reached: currentLevel >= i * 10,
          claimed: claimedIndexes.contains(i),
        ),
    ];
  }

  static int _levelFor(int exp) {
    var level = 1;
    while (level < 200 && exp >= 100 * level * (level + 1)) {
      level++;
    }
    return level;
  }
}
