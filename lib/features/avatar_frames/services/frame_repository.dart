import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/frame_profile.dart';
import 'frame_resolver.dart';
import 'legacy_frame_bridge.dart';

class FrameException implements Exception {
  final String message;
  const FrameException(this.message);
  @override
  String toString() => message;
}

abstract class FrameRepository {
  Stream<FrameProfile> watch(String uid);
  Future<void> equip(String frameId);
}

/// Firestore: users/{uid} ke fields role, vip, equippedFrame, ownedFrames, frames (legacy)
class FirestoreFrameRepository implements FrameRepository {
  FirestoreFrameRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _db = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  @override
  Stream<FrameProfile> watch(String uid) => _db
      .collection('users')
      .doc(uid)
      .snapshots()
      .map((doc) => LegacyFrameBridge.profileFrom(doc.data()));

  /// Client check karta hai. Server par bhi same rule hona chahiye (server/avatar_frames_functions.js).
  @override
  Future<void> equip(String frameId) async {
    final user = _auth.currentUser;
    if (user == null) throw const FrameException('Login karein');
    final ref = _db.collection('users').doc(user.uid);
    try {
      await _db.runTransaction((tx) async {
        final snap = await tx.get(ref);
        final profile = LegacyFrameBridge.profileFrom(snap.data());
        if (!FrameResolver.canEquip(profile, frameId)) {
          throw const FrameException('Ye frame aapke liye available nahi hai');
        }
        tx.update(ref, {'equippedFrame': frameId});
      });
    } on FirebaseException catch (e) {
      throw FrameException(e.code == 'permission-denied'
          ? 'Permission nahi hai'
          : 'Frame equip nahi ho saka. Dobara koshish karein');
    }
  }
}
