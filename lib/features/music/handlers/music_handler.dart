import '../../shared/feature_action.dart';
import '../models/music_track.dart';
import '../services/music_service.dart';

class MusicHandler {
  MusicHandler(this._service);

  final MusicService _service;

  Future<String?> play(MusicTrack t) => FeatureAction.run(() => _service.play(t));
  Future<String?> pause() => FeatureAction.run(() => _service.pause());
  Future<String?> resume() => FeatureAction.run(() => _service.resume());
  Future<String?> stop() => FeatureAction.run(() => _service.stop());
}
