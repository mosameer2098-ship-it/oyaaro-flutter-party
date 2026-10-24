import 'package:oyaroo/core/catalog.dart';
import 'package:oyaroo/core/result.dart';
import 'package:oyaroo/services/room_service.dart';

class SeatHandler {
  Future<Result<void>> take(String roomId, int index) =>
      Result.guard(() => RoomService.takeSeat(roomId, index));

  Future<Result<void>> leave(String roomId) =>
      Result.guard(() => RoomService.leaveSeat(roomId));

  Future<Result<void>> setMyMuted(String roomId, bool muted) =>
      Result.guard(() => RoomService.setMuted(roomId, muted));

  Future<Result<void>> hostSetMuted(String roomId, int index, bool muted) =>
      Result.guard(() => RoomService.setSeatMuted(roomId, index, muted));

  Future<Result<void>> kick(String roomId, int index) =>
      Result.guard(() => RoomService.kickFromSeat(roomId, index));

  Future<Result<void>> setSeatCount(String roomId, int count) async {
    if (count < 1 || count > Catalog.maxSeats) {
      return Err<void>('Seat count 1 se ${Catalog.maxSeats} ke beech hona chahiye');
    }
    return Result.guard(() => RoomService.setSeatCount(roomId, count));
  }
}
