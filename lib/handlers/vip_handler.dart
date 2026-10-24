import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:oyaroo/core/result.dart';
import 'package:oyaroo/helpers/vip_helper.dart';
import 'package:oyaroo/services/vip_service.dart';

class VipHandler {
  // Pehle helper se check, phir server-side transaction
  Future<Result<void>> buy(int tier) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final snap = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final d = snap.data() ?? {};
    final blocker = VipHelper.buyBlocker(
      currentVip: (d['vip'] ?? 0) as int,
      exp: (d['exp'] ?? 0) as int,
      coins: (d['coins'] ?? 0) as int,
      tier: tier,
    );
    if (blocker != null) return Err<void>(blocker);
    return Result.guard(() => VipService.buy(tier));
  }
}
