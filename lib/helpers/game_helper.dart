import 'package:oyaroo/core/brand.dart';
import 'package:oyaroo/core/game_rules.dart';
import 'package:oyaroo/helpers/formatters.dart';
import 'package:oyaroo/helpers/validation_helper.dart';

class GameHelper {
  static const minBet = 1;
  static const maxBet = 1000;
  static const crashTargets = <double>[1.5, 2.0, 3.0, 5.0];
  static const bagAmounts = [1000, 5000, 10000, 50000];
  static const bagUsers = [2, 5, 10, 20];

  static String? betError(int bet) {
    final empty = ValidationHelper.positiveInt(bet, 'Bet');
    if (empty != null) return empty;
    if (bet < minBet || bet > maxBet) {
      return 'Bet $minBet se $maxBet ${Brand.coinName} ke beech ho';
    }
    return null;
  }

  // Jeet Diamond mein jaati hai
  static String resultLabel(int payout) =>
      payout > 0 ? 'Jeet: +${formatCoins(payout)} Diamond' : 'Haar';

  static String kindLabel(GameKind k) => switch (k) {
        GameKind.slot => 'Slot',
        GameKind.wheel => 'Wheel',
        GameKind.crash => 'Crash',
        GameKind.fruit => 'Fruit',
        GameKind.bagSend => 'Bag',
      };
}
