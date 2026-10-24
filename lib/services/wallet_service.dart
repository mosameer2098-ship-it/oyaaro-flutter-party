import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:oyaroo/core/app_exception.dart';

// Sabhi coins ka badlav yahin se hota hai. Kharch hone wale coins exp (points) bhi dete hain.
class WalletService {
  static final _db = FirebaseFirestore.instance;
  static String get _uid => FirebaseAuth.instance.currentUser!.uid;

  static Future<void> change({int spend = 0, int gain = 0}) {
    final ref = _db.collection('users').doc(_uid);
    return _db.runTransaction((tx) async {
      final snap = await tx.get(ref);
      final coins = (snap.data()?['coins'] ?? 0) as int;
      if (coins < spend) throw const AppException('Coins kam hain');
      tx.update(ref, {
        'coins': coins - spend + gain,
        if (spend > 0) 'exp': FieldValue.increment(spend),
      });
    });
  }

  // Roz ke free gifts ki limit (din badalne par count reset)
  static Future<void> claimFreeGift(int limit) {
    final ref = _db.collection('users').doc(_uid);
    final today = DateTime.now().toIso8601String().substring(0, 10);
    return _db.runTransaction((tx) async {
      final d = (await tx.get(ref)).data() ?? {};
      final used = d['freeGiftDay'] == today ? (d['freeGiftCount'] ?? 0) as int : 0;
      if (used >= limit) {
        throw AppException('Aaj ke $limit free gifts khatam ho gaye');
      }
      tx.update(ref, {'freeGiftDay': today, 'freeGiftCount': used + 1});
    });
  }
}
