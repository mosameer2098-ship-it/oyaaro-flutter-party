// Coin ka hisaab: format, label, bonus, cut. Sab money math yahin se.
import 'package:oyaroo/core/brand.dart';
import 'package:oyaroo/helpers/formatters.dart';

class CoinHelper {
  static const bonusPercent = 10;

  static String format(num v) => formatCoins(v);

  static String label(num v) => '${formatCoins(v)} ${Brand.coinName}';

  static int bonusOf(int coins) => coins * bonusPercent ~/ 100;

  static bool canAfford(num balance, num cost) => balance >= cost;

  static String shortfall(num balance, num cost) =>
      'Aapko ${label(cost - balance)} aur chahiye';
}
