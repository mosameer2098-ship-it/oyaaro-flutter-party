import 'package:flutter_test/flutter_test.dart';

import '../../../../lib/features/level/center/catalog/level_reward_catalog.dart';
import '../../../../lib/features/level/center/logic/level_rules.dart';
import '../../../../lib/features/level/center/models/level_reward.dart';

void main() {
  test('cumulative EXP strictly badhta hai', () {
    for (var l = 2; l <= 100; l++) {
      expect(LevelRules.cumulativeExp(l) > LevelRules.cumulativeExp(l - 1), isTrue);
    }
  });

  test('levelFromExp: 0 par level 1, threshold par wahi level', () {
    expect(LevelRules.levelFromExp(0), 1);
    expect(LevelRules.levelFromExp(LevelRules.cumulativeExp(10)), 10);
    expect(LevelRules.levelFromExp(LevelRules.cumulativeExp(10) - 1), 9);
    expect(LevelRules.levelFromExp(999999999999), 100);
  });

  test('progress 0..1 aur max par 1', () {
    expect(LevelRules.progress(0), closeTo(0, 0.001));
    expect(LevelRules.progress(LevelRules.cumulativeExp(100)), 1);
    final p = LevelRules.progress(LevelRules.cumulativeExp(5) + 1);
    expect(p >= 0 && p <= 1, isTrue);
  });

  test('reward state: locked, claimable, claimed', () {
    const r = LevelReward(kind: RewardKind.coins, level: 10, coins: 75000);
    expect(LevelRules.stateOf(reward: r, current: 9, claimed: {}), RewardState.locked);
    expect(LevelRules.stateOf(reward: r, current: 10, claimed: {}), RewardState.claimable);
    expect(LevelRules.stateOf(reward: r, current: 10, claimed: {r.key}), RewardState.claimed);
  });

  test('catalog: badge levels 1,10..100 and 11 entries', () {
    final badges = LevelRewardCatalog.sections[RewardKind.badge]!;
    expect(badges.map((b) => b.level).toList(), [1, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100]);
  });

  test('catalog: coins sorted aur positive', () {
    final coins = LevelRewardCatalog.sections[RewardKind.coins]!;
    for (var i = 1; i < coins.length; i++) {
      expect(coins[i].level > coins[i - 1].level, isTrue);
    }
    expect(coins.every((c) => c.coins > 0), isTrue);
  });

  test('stars rule', () {
    expect(LevelRewardCatalog.starsFor(5), 0);
    expect(LevelRewardCatalog.starsFor(10), 1);
    expect(LevelRewardCatalog.starsFor(100), 5);
  });

  test('reward keys har section mein unique', () {
    final keys = <String>[];
    for (final list in LevelRewardCatalog.sections.values) {
      for (final r in list) {
        keys.add(r.key);
      }
    }
    expect(keys.toSet().length, keys.length);
  });
}
