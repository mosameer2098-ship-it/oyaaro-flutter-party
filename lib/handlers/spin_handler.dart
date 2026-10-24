import 'package:oyaroo/core/game_rules.dart';
import 'package:oyaroo/core/catalog.dart';
import 'package:oyaroo/core/result.dart';
import 'package:oyaroo/services/economy_service.dart';

// Lucky spin: server par, jeet diamond mein
class SpinHandler {
  Future<Result<int>> spin() async {
    final r = await Result.guard(() => EconomyService.playGame(
          gameId: 'lucky_spin',
          bet: Catalog.spinCost,
        ));
    if (r is Err<GameOutcome>) return Err<int>(r.message);
    return Ok<int>((r as Ok<GameOutcome>).value.payout);
  }
}
