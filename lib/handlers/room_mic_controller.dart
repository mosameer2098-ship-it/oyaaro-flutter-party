import 'package:oyaroo/core/result.dart';
import 'package:oyaroo/services/livekit_voice_service.dart';

class RoomMicController {
  final String roomId;
  final String uid;

  bool _ready = false;
  bool _publishing = false;
  bool micOn = true;
  bool? _lastSeatMuted;

  RoomMicController({required this.roomId, required this.uid});

  Future<Result<void>> join(String name) async {
    // Name is maintained by the room's existing Firestore seat data.
    final result = await Result.guard(() async {
      await LiveKitVoiceService.connect(roomId);
    });
    _ready = result is Ok<void>;
    return result;
  }

  Future<Result<void>> startPublishing() async {
    if (!_ready) {
      return const Err<void>('Voice room se connection nahi hai.');
    }

    final result = await Result.guard(
      () => LiveKitVoiceService.setMicEnabled(micOn),
    );
    _publishing = result is Ok<void>;
    return result;
  }

  Future<Result<void>> stopPublishing() async {
    _publishing = false;
    if (!_ready) return const Ok<void>(null);

    return Result.guard(() => LiveKitVoiceService.setMicEnabled(false));
  }

  Future<Result<void>> toggle() async {
    final nextValue = !micOn;
    final result = await Result.guard(() async {
      if (_ready && _publishing) {
        await LiveKitVoiceService.setMicEnabled(nextValue);
      }
    });

    if (result is Ok<void>) micOn = nextValue;
    return result;
  }

  void sync(bool isHost, List<Map<String, dynamic>> seats) {
    if (!_ready) return;

    if (isHost) {
      if (!_publishing) startPublishing();
      return;
    }

    final myIndex = seats.indexWhere((seat) => seat['uid'] == uid);

    if (myIndex == -1) {
      _lastSeatMuted = null;
      if (_publishing) stopPublishing();
      return;
    }

    final muted = seats[myIndex]['muted'] == true;

    if (_lastSeatMuted != null && _lastSeatMuted != muted) {
      micOn = !muted;
      if (_publishing) {
        Result.guard(() => LiveKitVoiceService.setMicEnabled(micOn));
      }
    }

    _lastSeatMuted = muted;
  }

  void dispose() {
    _ready = false;
    _publishing = false;
    Result.guard(LiveKitVoiceService.disconnect);
  }
}
