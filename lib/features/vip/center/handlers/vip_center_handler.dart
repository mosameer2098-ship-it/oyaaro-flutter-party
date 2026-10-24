import '../../../shared/feature_action.dart';
import '../logic/vip_rules.dart';
import '../../services/vip_service.dart';

/// Client par pehle saaf wajah, phir server call (buyVip). Server wahi rules check karta hai.
class VipCenterHandler {
  VipCenterHandler(this._service);

  final VipService _service;

  Future<String?> buy({
    required int currentLevel,
    required int target,
    required int points,
    required int coins,
  }) {
    final why = VipRules.buyBlocker(
      currentLevel: currentLevel,
      target: target,
      points: points,
      coins: coins,
    );
    if (why != null) return Future.value(why);
    return FeatureAction.run(() => _service.buy(target));
  }
}
