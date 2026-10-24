import 'package:oyaroo/core/brand.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Sab coin badlav server (Cloud Functions) par hote hain. Client sirf call karta hai.
class RechargeService {
  static final _fn = FirebaseFunctions.instance;

  static Future<void> confirmOnline(int amount, String paymentId) async {
    await _fn.httpsCallable('confirmOnlineRecharge').call({
      'amount': amount,
      'paymentId': paymentId,
    });
  }

  static Future<void> agentTransfer(String toUid, int amount) async {
    await _fn.httpsCallable('agentTransfer').call({'toUid': toUid, 'amount': amount});
  }

  static Future<void> setRole(String uid, String role) async {
    await _fn.httpsCallable('adminSetRole').call({'uid': uid, 'role': role});
  }

  static Future<void> addStock(String agentUid, int coins) async {
    await _fn.httpsCallable('adminAddStock').call({'agentUid': agentUid, 'coins': coins});
  }

  static Stream<DocumentSnapshot<Map<String, dynamic>>> myStock() =>
      FirebaseFirestore.instance
          .collection('agents')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .snapshots();

  static Stream<QuerySnapshot<Map<String, dynamic>>> recentRecharges() =>
      FirebaseFirestore.instance
          .collection('recharges')
          .orderBy('createdAt', descending: true)
          .limit(50)
          .snapshots();
}
