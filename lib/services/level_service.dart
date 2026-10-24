import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:oyaroo/core/app_exception.dart';
import 'package:oyaroo/core/level_rules.dart';

class LevelService {
  static final _db = FirebaseFirestore.instance;
  static DocumentReference<Map<String, dynamic>> get _ref =>
      _db.collection('users').doc(FirebaseAuth.instance.currentUser!.uid);

  // Milestone = 1..20 (level 10, 20, ... 200). Coins + frame milta hai.
  static Future<void> claim(int milestone) {
    final ref = _ref;
    return _db.runTransaction((tx) async {
      final d = (await tx.get(ref)).data() ?? {};
      final exp = (d['exp'] ?? 0) as int;
      final level = LevelRules.levelFor(exp);
      final claimed = List<int>.from(d['claimedLevels'] ?? []);
      if (level < milestone * LevelRules.milestoneEvery) {
        throw AppException('Level ${milestone * LevelRules.milestoneEvery} tak pahunchna hoga');
      }
      if (claimed.contains(milestone)) {
        throw const AppException('Ye reward aap le chuke hain');
      }
      tx.update(ref, {
        'coins': ((d['coins'] ?? 0) as int) + LevelRules.rewardCoins(milestone),
        'frames': FieldValue.arrayUnion([milestone]),
        'claimedLevels': FieldValue.arrayUnion([milestone]),
      });
    });
  }

  static Future<void> equip(int milestone) {
    final ref = _ref;
    return _db.runTransaction((tx) async {
      final d = (await tx.get(ref)).data() ?? {};
      final owned = List<int>.from(d['frames'] ?? []);
      if (!owned.contains(milestone)) {
        throw const AppException('Ye frame aapke paas nahi hai');
      }
      tx.update(ref, {'equippedFrame': milestone});
    });
  }
}
