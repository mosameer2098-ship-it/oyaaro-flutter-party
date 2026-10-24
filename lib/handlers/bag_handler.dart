import 'package:oyaroo/core/result.dart';
import 'package:oyaroo/helpers/game_helper.dart';
import 'package:oyaroo/services/economy_service.dart';

class BagHandler {
  Future<Result<void>> send(String roomId, int amount, int users) {
    if (!GameHelper.bagAmounts.contains(amount) || !GameHelper.bagUsers.contains(users)) {
      return Future<Result<void>>.value(const Err<void>('Amount ya users galat hain'));
    }
    return Result.guard(() => EconomyService.sendBag(roomId: roomId, amount: amount, users: users));
  }

  Future<Result<void>> claim(String bagId) async {
    return Result.guard(() async {
      await EconomyService.claimBag(bagId);
    });
  }
}
