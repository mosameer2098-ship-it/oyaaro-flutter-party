import 'package:permission_handler/permission_handler.dart';
import 'package:zego_express_engine/zego_express_engine.dart';

class ZegoVoiceService {
  // ==== YAHAN APNA ZEGO APP ID AUR APP SIGN DAALEIN ====
  static const int appId = 0;
  static const String appSign = '';
  // =====================================================

  static bool _engineReady = false;

  static Future<void> init() async {
    if (_engineReady) return;
    await Permission.microphone.request();
    await ZegoExpressEngine.createEngineWithProfile(
      ZegoEngineProfile(appId, ZegoScenario.Communication, appSign: appSign),
    );
    await ZegoExpressEngine.instance.enableCamera(false);
    ZegoExpressEngine.onRoomStreamUpdate =
        (roomID, updateType, streamList, extendedData) {
      if (updateType == ZegoUpdateType.Add) {
        for (final s in streamList) {
          ZegoExpressEngine.instance.startPlayingStream(s.streamID);
        }
      }
    };
    _engineReady = true;
  }

  static Future<void> joinRoom(String roomId, String uid, String name) async {
    await ZegoExpressEngine.instance.loginRoom(roomId, ZegoUser(uid, name));
  }

  static Future<void> startMic(String roomId, String uid) async {
    await ZegoExpressEngine.instance.startPublishingStream('${roomId}_$uid');
  }

  static Future<void> stopMic() async {
    await ZegoExpressEngine.instance.stopPublishingStream();
  }

  static Future<void> setMicOn(bool on) async {
    await ZegoExpressEngine.instance.muteMicrophone(!on);
  }

  static Future<void> leave(String roomId) async {
    if (!_engineReady) return;
    await stopMic();
    await ZegoExpressEngine.instance.logoutRoom(roomId);
    await ZegoExpressEngine.destroyEngine();
    _engineReady = false;
  }
}
