import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Host app login ke baad ise start kare. Har [interval] par users/{uid}.lastSeen update hota hai.
/// Online list isi field par chalti hai, isliye ye zaroori hai. Bina heartbeat ke koi online nahi dikhega.
class PresenceHeartbeat {
  PresenceHeartbeat({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    this.interval = const Duration(seconds: 60),
  })  : _db = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;
  final Duration interval;
  Timer? _timer;

  Future<void> start() async {
    await beat();
    _timer?.cancel();
    _timer = Timer.periodic(interval, (_) => beat());
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  /// Network error par app crash nahi hona chahiye, isliye error ignore hota hai.
  Future<void> beat() async {
    final user = _auth.currentUser;
    if (user == null) return;
    try {
      await _db.collection('users').doc(user.uid).set(
        {'lastSeen': FieldValue.serverTimestamp()},
        SetOptions(merge: true),
      );
    } catch (_) {}
  }
}
