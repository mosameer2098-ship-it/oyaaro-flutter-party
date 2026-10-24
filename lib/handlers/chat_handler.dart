import 'package:oyaroo/core/result.dart';
import 'package:oyaroo/helpers/gift_helper.dart';
import 'package:oyaroo/services/chat_service.dart';
import 'package:oyaroo/services/economy_service.dart';
import 'package:oyaroo/services/room_service.dart';

class ChatHandler {
  Future<Result<void>> sendRoomMessage(String roomId, String name, String raw) async {
    final text = raw.trim();
    if (text.isEmpty) return const Err<void>('Message khali hai');
    if (text.length > 300) return const Err<void>('Message 300 letters se chhota ho');
    return Result.guard(() => RoomService.sendMessage(roomId, name, text));
  }

  Future<Result<(String, String)>> openDm(String otherUid) =>
      Result.guard(() => ChatService.openConversation(otherUid));

  Future<Result<void>> sendDm(String convId, String raw) async {
    final text = raw.trim();
    if (text.isEmpty) return const Err<void>('Message khali hai');
    return Result.guard(() => ChatService.send(convId, text));
  }

  // CP / friend gift: server par settle hota hai
  Future<Result<void>> sendGiftDm(String convId, String gift) {
    if (GiftHelper.find(gift) == null) {
      return Future.value(const Err<void>('Gift nahi mila'));
    }
    return Result.guard(() => EconomyService.sendGift(type: 'dm', target: convId, gift: gift));
  }
}
