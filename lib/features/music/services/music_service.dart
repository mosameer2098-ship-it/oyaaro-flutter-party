import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/music_track.dart';

/// Tracks admin ke `music_tracks` collection se aate hain. App koi music file bundle nahi karta.
class MusicService {
  MusicService({FirebaseFirestore? firestore, AudioPlayer? player})
      : _db = firestore ?? FirebaseFirestore.instance,
        _player = player ?? AudioPlayer();

  final FirebaseFirestore _db;
  final AudioPlayer _player;

  Stream<List<MusicTrack>> watchTracks() => _db
      .collection('music_tracks')
      .orderBy('title')
      .limit(100)
      .snapshots()
      .map((s) => s.docs.map((d) => MusicTrack.fromMap(d.id, d.data())).whereType<MusicTrack>().toList());

  Future<void> play(MusicTrack t) => _player.play(UrlSource(t.url));
  Future<void> pause() => _player.pause();
  Future<void> resume() => _player.resume();
  Future<void> stop() => _player.stop();

  Stream<PlayerState> get states => _player.onPlayerStateChanged;

  void dispose() => _player.dispose();
}
