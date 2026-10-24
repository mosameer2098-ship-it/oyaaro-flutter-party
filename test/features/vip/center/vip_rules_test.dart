import 'package:flutter_test/flutter_test.dart';

import '../../../../lib/features/vip/center/catalog/vip_levels_catalog.dart';
import '../../../../lib/features/vip/center/catalog/vip_privileges_catalog.dart';
import '../../../../lib/features/vip/center/logic/vip_rules.dart';
import '../../../../lib/features/vip/center/models/vip_level.dart';

void main() {
  test('9 tiers, har tier ka creature alag', () {
    expect(VipLevelsCatalog.count, 9);
    expect(VipLevelsCatalog.all.map((l) => l.creature).toSet().length, 9);
  });

  test('points aur price v15/server ke saath match (VIP 1 = 1000 points, 500 coins)', () {
    expect(VipLevelsCatalog.byLevel(1).points, 1000);
    expect(VipLevelsCatalog.byLevel(1).price, 500);
    expect(VipLevelsCatalog.byLevel(9).points, 3500000);
  });

  test('privileges cumulative: upar wale level par zyada privileges', () {
    var prev = 0;
    for (var l = 1; l <= 9; l++) {
      final n = VipRules.privilegesUpTo(l).length;
      expect(n >= prev, isTrue);
      prev = n;
    }
    expect(VipRules.privilegesUpTo(1).every((p) => p.minLevel == 1), isTrue);
    expect(VipPrivilegesCatalog.all.map((p) => p.id).toSet().length, VipPrivilegesCatalog.all.length);
  });

  test('buy: sequential, points aur coins check', () {
    expect(VipRules.buyBlocker(currentLevel: 0, target: 2, points: 99999, coins: 99999), isNotNull);
    expect(VipRules.buyBlocker(currentLevel: 0, target: 1, points: 10, coins: 99999), isNotNull);
    expect(VipRules.buyBlocker(currentLevel: 0, target: 1, points: 1000, coins: 10), isNotNull);
    expect(VipRules.buyBlocker(currentLevel: 0, target: 1, points: 1000, coins: 500), isNull);
    expect(VipRules.buyBlocker(currentLevel: 1, target: 1, points: 99999, coins: 99999), isNotNull);
  });

  test('progress 0..1 aur max level par 1', () {
    final p = VipRules.progress(current: 0, points: 500);
    expect(p, closeTo(0.5, 0.001));
    expect(VipRules.progress(current: 9, points: 0), 1);
    expect(VipRules.nextLevel(9), isNull);
    expect(VipRules.nextLevel(0)?.level, 1);
  });

  test('titles', () {
    expect(VipLevelsCatalog.byLevel(5).title, 'VIP 5  Shark');
  });
}
