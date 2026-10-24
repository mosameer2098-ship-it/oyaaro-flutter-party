import 'package:oyaroo/core/result.dart';
import 'package:oyaroo/core/rockets.dart';
import 'package:oyaroo/services/room_service.dart';
import 'package:oyaroo/services/wallet_service.dart';

class RocketHandler {
  // Coins kaatna, phir room mein rocket message bhejna. Fail ho to coins wapas.
  Future<Result<void>> launch(String roomId, String senderName, String rocketId) async {
    final spec = Rockets.byId(rocketId);
    if (spec == null) return const Err<void>('Rocket nahi mila');

    final charged = await Result.guard(() => WalletService.change(spend: spec.price));
    if (charged is Err<void>) return charged;

    final sent = await Result.guard(() =>
        RoomService.sendMessage(roomId, senderName, rocketId, type: 'rocket'));
    if (sent is Err<void>) {
      await Result.guard(() => WalletService.change(gain: spec.price));
      return sent;
    }
    return const Ok<void>(null);
  }
}
