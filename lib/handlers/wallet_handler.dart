import 'package:oyaroo/core/result.dart';
import 'package:oyaroo/core/wallet_rules.dart';
import 'package:oyaroo/services/economy_service.dart';

class WalletHandler {
  Future<Result<void>> convert(int diamonds) async {
    if (diamonds < WalletRules.convertDiamonds) {
      return const Err<void>('Kam se kam ${WalletRules.convertDiamonds} diamond convert karein');
    }
    if (diamonds % WalletRules.convertDiamonds != 0) {
      return const Err<void>('${WalletRules.convertDiamonds} ke multiple mein convert karein');
    }
    return Result.guard(() async {
      await EconomyService.convertDiamonds(diamonds);
    });
  }
}
