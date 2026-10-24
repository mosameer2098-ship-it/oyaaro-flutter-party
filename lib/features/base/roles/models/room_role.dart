/// Room ke andar role. Host sabse upar. Permissions yahin se decide hoti hain.
enum RoomRole { host, admin, moderator, member }

extension RoomRolePerms on RoomRole {
  int get level => switch (this) {
        RoomRole.host => 4,
        RoomRole.admin => 3,
        RoomRole.moderator => 2,
        RoomRole.member => 1,
      };

  bool get canApproveSeat => level >= RoomRole.moderator.level;
  bool get canMuteOrKick => level >= RoomRole.moderator.level;
  bool get canManageRoles => this == RoomRole.host;
  bool get canLockRoom => this == RoomRole.host;

  static RoomRole parse(String? v) => switch (v) {
        'host' => RoomRole.host,
        'admin' => RoomRole.admin,
        'moderator' => RoomRole.moderator,
        _ => RoomRole.member,
      };
}

class SeatRequest {
  const SeatRequest({required this.uid, required this.seatIndex, required this.status});
  final String uid;
  final int seatIndex;
  final String status; // pending | approved | rejected

  bool get isPending => status == 'pending';

  static SeatRequest fromMap(String uid, Map<String, dynamic> d) => SeatRequest(
        uid: uid,
        seatIndex: (d['seatIndex'] as num?)?.toInt() ?? 0,
        status: d['status'] as String? ?? 'pending',
      );
}
