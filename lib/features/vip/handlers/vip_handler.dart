import '../../shared/feature_action.dart';
import '../catalog/vip_catalog.dart';
import '../models/vip_tier.dart';
import '../services/vip_service.dart';

/// Pehle client par saaf wajah dikhao, phir server call.
class VipHandler {
  VipHandler(this._service);

  final VipService _service;

  /// null = khareed sakte hain. Warna wajah (text).
  static String? blocker({
    required int currentVip,
    required int exp,
    required int coins,
    required VipTier tier,
  }) {
    if (currentVip >= tier.level) return 'VIP ${tier.level} aap pehle le chuke hain';
    if (currentVip != tier.level - 1) return 'Pehle VIP ${tier.level - 1} lo';
    if (exp < tier.points) return 'Points chahiye ${tier.points}, aapke $exp hain';
    if (coins < tier.price) return 'Coins kam hain (${tier.price} chahiye)';
    return null;
  }

  Future<String?> buy({
    required int currentVip,
    required int exp,
    required int coins,
    required int level,
  }) async {
    final tier = VipCatalog.byLevel(level);
    final why = blocker(currentVip: currentVip, exp: exp, coins: coins, tier: tier);
    if (why != null) return why;
    return FeatureAction.run(() => _service.buy(level));
  }
}
