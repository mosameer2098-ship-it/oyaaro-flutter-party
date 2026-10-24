import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Har gift bhejne par sender ko us gift ka medal milta hai (users.medals map)
class MedalService {
  static final _db = FirebaseFirestore.instance;

  static Future<void> award(String giftName) {
    final ref = _db.collection('users').doc(FirebaseAuth.instance.currentUser!.uid);
    return _db.runTransaction((tx) async {
      final d = (await tx.get(ref)).data() ?? {};
      final medals = Map<String, dynamic>.from(d['medals'] ?? {});
      medals[giftName] = ((medals[giftName] ?? 0) as int) + 1;
      tx.update(ref, {'medals': medals});
    });
  }
}
