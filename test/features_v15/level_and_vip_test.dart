import 'package:flutter_test/flutter_test.dart';

import '../../lib/features/shared/level_math.dart';
import '../../lib/features/rewards/models/level_milestone.dart';
import '../../lib/features/vip/catalog/vip_catalog.dart';
import '../../lib/features/vip/handlers/vip_handler.dart';

void main() {
  test('level formula: exp 0 => level 1, requiredExp(2)=200', () {
    expect(LevelMath.levelFor(0), 1);
    expect(LevelMath.requiredExp(2), 200);
    expect(LevelMath.levelFor(200), 2);
  });

  test('milestones: level 10 par milestone 1 reached', () {
    final exp = LevelMath.requiredExp(10);
    final list = LevelMilestone.build(exp: exp, claimedIndexes: const []);
    expect(list.length, 20);
    expect(list.first.reached, isTrue);
    expect(list[1].reached, isFalse);
    expect(list.first.canClaim, isTrue);
  });

  test('VIP blocker: points kam hon to wajah', () {
    final why = VipHandler.blocker(
      currentVip: 0,
      exp: 10,
      coins: 99999,
      tier: VipCatalog.byLevel(1),
    );
    expect(why, isNotNull);
  });

  test('VIP blocker: sab theek ho to null', () {
    final why = VipHandler.blocker(
      currentVip: 0,
      exp: 5000,
      coins: 5000,
      tier: VipCatalog.byLevel(1),
    );
    expect(why, isNull);
  });
}
