import 'package:cloud_firestore/cloud_firestore.dart';

import '../../shared/callable_helper.dart';
import '../models/wheel_round.dart';

/// Round server par banta hai (scheduled). Client sirf latest round dekhta hai aur bet lagata hai.
class WheelService {
  WheelService({CallableHelper? callable, FirebaseFirestore? firestore})
      : _call = callable ?? CallableHelper(),
        _db = firestore ?? FirebaseFirestore.instance;

  final CallableHelper _call;
  final FirebaseFirestore _db;

  Stream<WheelRound?> watchLatestRound() => _db
      .collection('wheel_rounds')
      .orderBy('startAt', descending: true)
      .limit(1)
      .snapshots()
      .map((s) => s.docs.isEmpty ? null : WheelRound.fromMap(s.docs.first.id, s.docs.first.data()));

  Future<void> placeBet({
    required String roundId,
    required String segmentId,
    required int amount,
  }) async {
    await _call.call('placeWheelBet', {
      'roundId': roundId,
      'segmentId': segmentId,
      'amount': amount,
    });
  }
}
