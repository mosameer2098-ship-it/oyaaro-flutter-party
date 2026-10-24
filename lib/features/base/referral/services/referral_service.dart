import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../shared/callable_helper.dart';

class ReferralService {
  ReferralService({CallableHelper? callable, FirebaseFirestore? firestore})
      : _call = callable ?? CallableHelper(),
        _db = firestore ?? FirebaseFirestore.instance;

  final CallableHelper _call;
  final FirebaseFirestore _db;

  Future<String> ensureCode() async {
    final res = await _call.call('ensureReferralCode');
    return res['code'] as String? ?? '';
  }

  Future<int> redeem(String code) async {
    final res = await _call.call('redeemReferral', {'code': code});
    return (res['reward'] as num?)?.toInt() ?? 0;
  }

  Stream<String?> watchMyCode() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return _db.collection('users').doc(uid).snapshots().map((d) => d.data()?['referralCode'] as String?);
  }
}
