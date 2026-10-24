import 'package:cloud_firestore/cloud_firestore.dart';

import '../../shared/callable_helper.dart';
import '../models/pk_session.dart';

/// PK start server par. Live scores Firestore se (pk/{id}).
class PkService {
  PkService({CallableHelper? callable, FirebaseFirestore? firestore})
      : _call = callable ?? CallableHelper(),
        _db = firestore ?? FirebaseFirestore.instance;

  final CallableHelper _call;
  final FirebaseFirestore _db;

  Future<void> start({
    required String roomId,
    required String opponentRoomId,
    required int minutes,
  }) async {
    await _call.call('startPk', {
      'roomId': roomId,
      'opponentRoomId': opponentRoomId,
      'minutes': minutes,
    });
  }

  /// Room ka current PK session (rooms/{roomId}.pkSessionId ke through)
  Stream<PkSession?> watchRoomSession(String roomId) => _db
          .collection('rooms')
          .doc(roomId)
          .snapshots()
          .asyncExpand((room) {
        final sid = room.data()?['pkSessionId'] as String?;
        if (sid == null) return Stream.value(null);
        return _db.collection('pk').doc(sid).snapshots().map((s) {
          final d = s.data();
          if (d == null) return null;
          return PkSession.fromMap(s.id, d);
        });
      });
}
