import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:oyaroo/core/catalog.dart';
import 'dart:math';

class UserService {
  static final _users = FirebaseFirestore.instance.collection('users');

  static Future<String> _uniqueShortId() async {
    final random = Random.secure();
    for (var attempt = 0; attempt < 12; attempt++) {
      final id = (10000000 + random.nextInt(90000000)).toString();
      final match = await _users.where('shortId', isEqualTo: id).limit(1).get();
      if (match.docs.isEmpty) return id;
    }
    throw StateError('Unique user ID generate nahi ho payi. Dobara try karein.');
  }

  static Future<void> ensureUser() async {
    final u = FirebaseAuth.instance.currentUser;
    if (u == null) return;

    final ref = _users.doc(u.uid);
    final snap = await ref.get();
    final data = snap.data() ?? <String, dynamic>{};
    final displayName = (u.displayName ?? '').trim();
    final existingName = (data['name'] as String?)?.trim() ?? '';
    final name = existingName.isNotEmpty
        ? existingName
        : (displayName.isNotEmpty ? displayName : 'User ${u.uid.substring(0, 5)}');

    final updates = <String, dynamic>{};
    if (!snap.exists) {
      updates.addAll({
        'bio': '',
        'coins': Catalog.startCoins,
        'exp': 0,
        'vip': 0,
        'frames': <int>[],
        'claimedLevels': <int>[],
        'equippedFrame': null,
        'familyId': null,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    if ((data['name'] as String?)?.trim().isEmpty ?? true) {
      updates['name'] = name;
    }
    if ((data['nameLower'] as String?) != name.toLowerCase()) {
      updates['nameLower'] = name.toLowerCase();
    }
    if ((data['shortId'] as String?)?.isNotEmpty != true) {
      updates['shortId'] = await _uniqueShortId();
    }

    if (updates.isNotEmpty) {
      await ref.set(updates, SetOptions(merge: true));
    }
  }

  static Future<String> myName() async {
    final u = FirebaseAuth.instance.currentUser!;
    final snap = await _users.doc(u.uid).get();
    return (snap.data()?['name'] as String?) ?? u.displayName ?? 'User';
  }

  static Future<int> myVip() async {
    final u = FirebaseAuth.instance.currentUser!;
    final snap = await _users.doc(u.uid).get();
    return (snap.data()?['vip'] ?? 0) as int;
  }

  static Stream<DocumentSnapshot<Map<String, dynamic>>> profileStream(String uid) =>
      _users.doc(uid).snapshots();

  static Future<void> updateProfile({required String name, required String bio}) =>
      _users.doc(FirebaseAuth.instance.currentUser!.uid).update({
        'name': name,
        'nameLower': name.trim().toLowerCase(),
        'bio': bio,
      });
}
