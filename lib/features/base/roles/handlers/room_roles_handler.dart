import '../../../shared/feature_action.dart';
import '../models/room_role.dart';
import '../services/room_roles_service.dart';

/// Permission check client par (UI ke liye), server par bhi enforce hota hai.
class RoomRolesHandler {
  RoomRolesHandler(this._service);

  final RoomRolesService _service;

  static String? canSetRole({required RoomRole myRole, required RoomRole target}) {
    if (!myRole.canManageRoles) return 'Sirf host role badal sakta hai';
    if (target == RoomRole.host) return 'Host ka role nahi badal sakte';
    return null;
  }

  Future<String?> setRole({
    required String roomId,
    required String uid,
    required RoomRole myRole,
    required RoomRole role,
  }) {
    final why = canSetRole(myRole: myRole, target: role);
    if (why != null) return Future.value(why);
    return FeatureAction.run(() => _service.setRole(roomId, uid, role));
  }

  Future<String?> resolveSeat({
    required String roomId,
    required String uid,
    required RoomRole myRole,
    required bool approve,
  }) {
    if (!myRole.canApproveSeat) return Future.value('Seat approve karne ki permission nahi hai');
    return FeatureAction.run(() => _service.resolveSeat(roomId, uid, approve));
  }

  Future<String?> setPassword(String roomId, String password, RoomRole myRole) {
    if (!myRole.canLockRoom) return Future.value('Sirf host password set kar sakta hai');
    if (password.isNotEmpty && (password.length < 4 || password.length > 12)) {
      return Future.value('Password 4 se 12 characters ka ho');
    }
    return FeatureAction.run(() => _service.setPassword(roomId, password));
  }

  Future<String?> joinWithPassword(String roomId, String password) =>
      FeatureAction.run(() => _service.verifyPassword(roomId, password));
}
