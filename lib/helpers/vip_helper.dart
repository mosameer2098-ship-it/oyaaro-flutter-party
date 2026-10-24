import 'package:oyaroo/core/vip.dart';
import 'package:oyaroo/helpers/coin_helper.dart';

class VipHelper {
  // null = khareed sakte hain, warna wajah (text)
  static String? buyBlocker({
    required int currentVip,
    required int exp,
    required int coins,
    required int tier,
  }) {
    if (tier < 1 || tier > Vip.all.length) return 'VIP tier galat hai';
    final t = Vip.byLevel(tier);
    if (currentVip >= tier) return 'VIP $tier aap pehle le chuke hain';
    if (currentVip != tier - 1) return 'Pehle VIP ${tier - 1} lo';
    if (exp < t.points) return 'Points chahiye ${t.points}, aapke $exp hain';
    if (!CoinHelper.canAfford(coins, t.price)) {
      return CoinHelper.shortfall(coins, t.price);
    }
    return null;
  }

  static String priceLabel(int tier) => CoinHelper.label(Vip.byLevel(tier).price);
}
