import '../../shared/feature_action.dart';
import '../services/pk_service.dart';

class PkHandler {
  PkHandler(this._service);

  final PkService _service;

  static const allowedMinutes = [1, 5, 10, 15];

  static String? validate({
    required String roomId,
    required String opponentRoomId,
    required int minutes,
  }) {
    if (opponentRoomId.isEmpty) return 'Opponent room chuniye';
    if (opponentRoomId == roomId) return 'Apne hi room se PK nahi ho sakta';
    if (!allowedMinutes.contains(minutes)) return 'Time 1, 5, 10 ya 15 min chuniye';
    return null;
  }

  Future<String?> start({
    required String roomId,
    required String opponentRoomId,
    required int minutes,
  }) {
    final v = validate(roomId: roomId, opponentRoomId: opponentRoomId, minutes: minutes);
    if (v != null) return Future.value(v);
    return FeatureAction.run(() => _service.start(
          roomId: roomId,
          opponentRoomId: opponentRoomId,
          minutes: minutes,
        ));
  }
}
