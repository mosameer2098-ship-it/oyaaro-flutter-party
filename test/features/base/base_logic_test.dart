import 'package:flutter_test/flutter_test.dart';

import '../../../lib/features/base/moderation/handlers/moderation_handler.dart';
import '../../../lib/features/base/moderation/models/report.dart';
import '../../../lib/features/base/referral/handlers/referral_handler.dart';
import '../../../lib/features/base/roles/handlers/room_roles_handler.dart';
import '../../../lib/features/base/roles/models/room_role.dart';
import '../../../lib/features/base/roles/models/room_role.dart' as roles;
import '../../../lib/features/base/tasks/models/checkin_result.dart';

void main() {
  group('room roles', () {
    test('role parse: unknown value member banta hai', () {
      expect(RoomRolePerms.parse('host'), RoomRole.host);
      expect(RoomRolePerms.parse('admin'), RoomRole.admin);
      expect(RoomRolePerms.parse('zzz'), RoomRole.member);
      expect(RoomRolePerms.parse(null), RoomRole.member);
    });

    test('permissions: sirf host role badal sakta hai', () {
      expect(RoomRole.host.canManageRoles, isTrue);
      expect(RoomRole.admin.canManageRoles, isFalse);
      expect(RoomRole.moderator.canApproveSeat, isTrue);
      expect(RoomRole.member.canApproveSeat, isFalse);
    });

    test('canSetRole: admin host ka role nahi badal sakta, host target blocked', () {
      expect(RoomRolesHandler.canSetRole(myRole: RoomRole.admin, target: RoomRole.moderator), isNotNull);
      expect(RoomRolesHandler.canSetRole(myRole: RoomRole.host, target: RoomRole.host), isNotNull);
      expect(RoomRolesHandler.canSetRole(myRole: RoomRole.host, target: RoomRole.moderator), isNull);
    });

    test('SeatRequest parse', () {
      final r = roles.SeatRequest.fromMap('u1', {'seatIndex': 3, 'status': 'pending'});
      expect(r.seatIndex, 3);
      expect(r.isPending, isTrue);
    });
  });

  group('moderation', () {
    test('khud ko report nahi, khali target nahi', () {
      expect(ModerationHandler.validate(targetUid: 'a', myUid: 'a', reason: ReportReason.spam), isNotNull);
      expect(ModerationHandler.validate(targetUid: '', myUid: 'a', reason: ReportReason.spam), isNotNull);
    });

    test('other reason ke liye detail zaroori', () {
      expect(
        ModerationHandler.validate(targetUid: 'b', myUid: 'a', reason: ReportReason.other, details: 'a'),
        isNotNull,
      );
      expect(
        ModerationHandler.validate(targetUid: 'b', myUid: 'a', reason: ReportReason.other, details: 'abc'),
        isNull,
      );
    });

    test('preset reason valid hai', () {
      expect(ModerationHandler.validate(targetUid: 'b', myUid: 'a', reason: ReportReason.abuse), isNull);
    });
  });

  group('referral', () {
    test('code 8 characters, A-Z aur 2-9 only', () {
      expect(ReferralHandler.validateCode('ABCD2345'), isNull);
      expect(ReferralHandler.validateCode('abcd2345'), isNull); // upper case me convert
      expect(ReferralHandler.validateCode('ABC'), isNotNull);
      expect(ReferralHandler.validateCode('ABCD0O11'), isNotNull); // 0,1,O allowed nahi
    });
  });

  group('check-in', () {
    test('streak reward 50 se shuru, 7 din par cap', () {
      expect(CheckInResult.nextReward(0), 50);
      expect(CheckInResult.nextReward(2), 150);
      expect(CheckInResult.nextReward(50), 350);
    });
  });
}
