import 'package:oyaroo/core/result.dart';
import 'package:oyaroo/services/room_service.dart';

class RoomHandler {
  Future<Result<String>> createRoom(String rawName) async {
    final name = rawName.trim();
    if (name.isEmpty) return const Err<String>('Room ka naam likhein');
    if (name.length > 40) return const Err<String>('Room ka naam 40 letters se chhota ho');
    return Result.guard(() => RoomService.createRoom(name));
  }

  // VIP user room mein aaye to entry announce hoti hai
  Future<Result<void>> announceEntry(String roomId, String name, int vip) {
    if (vip <= 0) return Future.value(const Ok<void>(null));
    return Result.guard(() => RoomService.sendMessage(roomId, name, 'VIP$vip', type: 'entry'));
  }
}
