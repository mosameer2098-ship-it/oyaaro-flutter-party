import 'package:oyaroo/core/result.dart';
import 'package:oyaroo/services/zego_voice_service.dart';

// Room ke mic ka state aur seat ke saath sync. Screen sirf ye call karti hai.
class RoomMicController {
  final String roomId;
  final String uid;
  String _name = 'User';
  bool _ready = false;
  bool _publishing = false;
  bool micOn = true;
  bool? _lastSeatMuted;

  RoomMicController({required this.roomId, required this.uid});

  Future<Result<void>> join(String name) async {
    _name = name;
    final r = await Result.guard(() async {
      await ZegoVoiceService.init();
      await ZegoVoiceService.joinRoom(roomId, uid, _name);
    });
    _ready = r is Ok<void>;
    return r;
  }

  Future<Result<void>> startPublishing() async {
    _publishing = true;
    final r = await Result.guard(() => ZegoVoiceService.startMic(roomId, uid));
    if (r is Err<void>) _publishing = false;
    return r;
  }

  Future<Result<void>> stopPublishing() async {
    _publishing = false;
    return Result.guard(() => ZegoVoiceService.stopMic());
  }

  Future<Result<void>> toggle() async {
    micOn = !micOn;
    return Result.guard(() => ZegoVoiceService.setMicOn(micOn));
  }

  // Seats badalne par mic sync: host auto publish, kick par band, host-mute par mute
  void sync(bool isHost, List<Map<String, dynamic>> seats) {
    if (!_ready) return;
    if (isHost) {
      if (!_publishing) startPublishing();
      return;
    }
    final myIndex = seats.indexWhere((s) => s['uid'] == uid);
    if (myIndex == -1) {
      _lastSeatMuted = null;
      if (_publishing) stopPublishing();
      return;
    }
    final muted = seats[myIndex]['muted'] == true;
    if (_lastSeatMuted != null && _lastSeatMuted != muted && muted != !micOn) {
      micOn = !muted;
      Result.guard(() => ZegoVoiceService.setMicOn(micOn));
    }
    _lastSeatMuted = muted;
  }

  void dispose() {
    Result.guard(() => ZegoVoiceService.leave(roomId));
  }
}
