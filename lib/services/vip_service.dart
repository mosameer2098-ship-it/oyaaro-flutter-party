import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:oyaroo/core/app_exception.dart';
import 'package:oyaroo/core/vip.dart';

// VIP tier ek ek karke khareedne hote hain. Points = user ka exp.
class VipService {
  static final _db = FirebaseFirestore.instance;
  static DocumentReference<Map<String, dynamic>> get _ref =>
      _db.collection('users').doc(FirebaseAuth.instance.currentUser!.uid);

  static Future<void> buy(int tier) {
    final t = Vip.byLevel(tier);
    final ref = _ref;
    return _db.runTransaction((tx) async {
      final d = (await tx.get(ref)).data() ?? {};
      final vip = (d['vip'] ?? 0) as int;
      final exp = (d['exp'] ?? 0) as int;
      final coins = (d['coins'] ?? 0) as int;
      if (vip >= tier) throw AppException('VIP $tier aap pehle le chuke hain');
      if (vip != tier - 1) throw AppException('Pehle VIP ${tier - 1} lo');
      if (exp < t.points) {
        throw AppException('VIP $tier ke liye ${t.points} points chahiye. Aapke $exp hain');
      }
      if (coins < t.price) throw const AppException('Coins kam hain');
      tx.update(ref, {'coins': coins - t.price, 'vip': tier});
    });
  }
}
