import 'package:oyaroo/core/game_rules.dart';
import 'package:oyaroo/core/result.dart';
import 'package:oyaroo/helpers/game_helper.dart';
import 'package:oyaroo/services/economy_service.dart';

// Game server par chalta hai. Validation client par bhi hai, server par bhi.
class GameHandler {
  Future<Result<GameOutcome>> play(
    GameSpec game,
    int bet, {
    int? pick,
    double? target,
    bool advanced = false,
    int draws = 1,
  }) async {
    final betErr = GameHelper.betError(bet);
    if (betErr != null) return Err<GameOutcome>(betErr);
    if (game.kind == GameKind.fruit && (pick == null || pick < 1 || pick > 12)) {
      return const Err<GameOutcome>('Ek fruit cell chunein');
    }
    if (game.kind == GameKind.crash &&
        (target == null || !GameHelper.crashTargets.contains(target))) {
      return const Err<GameOutcome>('Target multiplier chunein');
    }
    if (game.kind == GameKind.wheel && draws != 1 && draws != 10) {
      return const Err<GameOutcome>('1 ya 10 draw chunein');
    }
    return Result.guard(() => EconomyService.playGame(
          gameId: game.id,
          bet: bet,
          pick: pick,
          target: target,
          advanced: advanced,
          draws: draws,
        ));
  }
}
