import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../shared/callable_helper.dart';
import '../models/room_role.dart';

/// Roles, seat requests aur room password. Writes server par, reads Firestore se.
class RoomRolesService {
  RoomRolesService({CallableHelper? callable, FirebaseFirestore? firestore})
      : _call = callable ?? CallableHelper(),
        _db = firestore ?? FirebaseFirestore.instance;

  final CallableHelper _call;
  final FirebaseFirestore _db;

  Future<void> setRole(String roomId, String uid, RoomRole role) async {
    await _call.call('setRoomRole', {'roomId': roomId, 'uid': uid, 'role': role.name});
  }

  Future<void> requestSeat(String roomId, int seatIndex) async {
    await _call.call('requestSeat', {'roomId': roomId, 'seatIndex': seatIndex});
  }

  Future<void> resolveSeat(String roomId, String uid, bool approve) async {
    await _call.call('resolveSeatRequest', {'roomId': roomId, 'uid': uid, 'approve': approve});
  }

  Future<void> setPassword(String roomId, String password) async {
    await _call.call('setRoomPassword', {'roomId': roomId, 'password': password});
  }

  Future<void> verifyPassword(String roomId, String password) async {
    await _call.call('verifyRoomPassword', {'roomId': roomId, 'password': password});
  }

  Stream<List<SeatRequest>> watchSeatRequests(String roomId) => _db
      .collection('rooms')
      .doc(roomId)
      .collection('seatRequests')
      .where('status', isEqualTo: 'pending')
      .snapshots()
      .map((s) => s.docs.map((d) => SeatRequest.fromMap(d.id, d.data())).toList());
}
