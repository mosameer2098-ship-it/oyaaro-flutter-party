import '../models/level_reward.dart';

/// Reward schedule. Ye hamara apna schedule hai. Values server ke saath
/// claimLevelMilestone mein same rakhni hain (server hi final authority hai).
class LevelRewardCatalog {
  const LevelRewardCatalog._();

  static const maxLevel = 100;

  static const _coinLevels = [
    2, 4, 6, 8, 10, 12, 15, 18, 20, 22, 25, 27, 30, 33, 36, 40, 43, 46, 50,
    53, 56, 60, 63, 66, 70, 73, 76, 80, 83, 86, 90, 93, 96, 100,
  ];

  /// Stars: 10 se pehle 0, phir har 20 level par ek star (max 5)
  static int starsFor(int level) => level < 10 ? 0 : (level ~/ 20 + 1).clamp(1, 5);

  static final Map<RewardKind, List<LevelReward>> sections = {
    RewardKind.badge: [
      for (final l in [1, for (var x = 10; x <= 100; x += 10) x])
        LevelReward(kind: RewardKind.badge, level: l),
    ],
    RewardKind.coins: [
      for (final l in _coinLevels)
        LevelReward(kind: RewardKind.coins, level: l, coins: 7500 * l),
    ],
    RewardKind.medal: [
      for (var l = 10; l <= 100; l += 10)
        LevelReward(kind: RewardKind.medal, level: l, stars: starsFor(l)),
    ],
    RewardKind.frame: [
      for (final l in [1, 5, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100])
        LevelReward(kind: RewardKind.frame, level: l, stars: starsFor(l)),
    ],
    RewardKind.theme: [
      for (var l = 15; l <= 95; l += 10)
        LevelReward(kind: RewardKind.theme, level: l, stars: starsFor(l)),
    ],
    RewardKind.vehicle: [
      for (final l in [25, 35, 45, 55, 65, 75, 85, 95, 100])
        LevelReward(kind: RewardKind.vehicle, level: l, stars: starsFor(l)),
    ],
    RewardKind.customId: const [
      LevelReward(kind: RewardKind.customId, level: 8, digits: 7, days: 10),
      LevelReward(kind: RewardKind.customId, level: 16, digits: 7, days: 20),
      LevelReward(kind: RewardKind.customId, level: 24, digits: 7, days: 30),
      LevelReward(kind: RewardKind.customId, level: 35, digits: 6, days: 20),
      LevelReward(kind: RewardKind.customId, level: 45, digits: 6, days: 30),
      LevelReward(kind: RewardKind.customId, level: 65, digits: 6, days: 30),
      LevelReward(kind: RewardKind.customId, level: 75, digits: 5, days: 60),
      LevelReward(kind: RewardKind.customId, level: 95, digits: 5, days: 100),
      LevelReward(kind: RewardKind.customId, level: 100, digits: 5, days: 180),
    ],
    RewardKind.background: const [
      LevelReward(kind: RewardKind.background, level: 20),
    ],
    RewardKind.superMic: const [
      LevelReward(kind: RewardKind.superMic, level: 50),
    ],
    RewardKind.openingPage: const [
      LevelReward(kind: RewardKind.openingPage, level: 80, days: 7),
      LevelReward(kind: RewardKind.openingPage, level: 90, days: 7),
      LevelReward(kind: RewardKind.openingPage, level: 100, days: 7),
    ],
    RewardKind.entrance: const [
      LevelReward(kind: RewardKind.entrance, level: 60, days: 7),
      LevelReward(kind: RewardKind.entrance, level: 80, days: 7),
      LevelReward(kind: RewardKind.entrance, level: 100, days: 7),
    ],
  };
}
