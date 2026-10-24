import 'package:cloud_functions/cloud_functions.dart';
import 'package:livekit_client/livekit_client.dart';

class LiveKitVoiceService {
  LiveKitVoiceService._();

  static Room? _room;
  static String? _roomId;

  static Future<void> connect(String roomId) async {
    if (_room != null && _roomId == roomId) return;

    await disconnect();

    final result = await FirebaseFunctions.instance
        .httpsCallable('getLiveKitToken')
        .call(<String, dynamic>{'roomId': roomId});

    final data = Map<String, dynamic>.from(result.data as Map);
    final url = data['url'] as String?;
    final token = data['token'] as String?;

    if (url == null || token == null || url.isEmpty || token.isEmpty) {
      throw StateError('LiveKit server abhi configured nahi hai.');
    }

    final room = Room();
    try {
      await room.connect(url, token);
      _room = room;
      _roomId = roomId;
    } catch (_) {
      await room.disconnect();
      rethrow;
    }
  }

  static Future<void> setMicEnabled(bool enabled) async {
    final room = _room;
    if (room == null) {
      throw StateError('Voice room se connection nahi hai.');
    }
    await room.localParticipant?.setMicrophoneEnabled(enabled);
  }

  static Future<void> disconnect() async {
    final room = _room;
    _room = null;
    _roomId = null;
    if (room != null) await room.disconnect();
  }
}
