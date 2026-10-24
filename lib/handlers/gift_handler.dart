import 'package:oyaroo/core/result.dart';
import 'package:oyaroo/helpers/gift_helper.dart';
import 'package:oyaroo/services/economy_service.dart';

// Room gift. Coin kat-na aur diamond dena server karta hai.
class GiftHandler {
  Future<Result<void>> send(String roomId, String senderName, String gift) {
    if (GiftHelper.find(gift) == null) {
      return Future.value(const Err<void>('Gift nahi mila'));
    }
    return Result.guard(() => EconomyService.sendGift(type: 'room', target: roomId, gift: gift));
  }
}
