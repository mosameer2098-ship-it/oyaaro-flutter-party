import 'package:flutter_test/flutter_test.dart';
import '../../../lib/features/avatar_frames/avatar_frames.dart';

void main() {
  test('staff role ka frame sabse upar, user change nahi kar sakta', () {
    const p = FrameProfile(role: AccountRole.admin, vip: 5, equippedId: 'std_0001', owned: {'std_0001'});
    expect(FrameResolver.resolve(p)?.id, 'role_admin');
    expect(FrameResolver.canEquip(p, 'std_0001'), isFalse);
  });

  test('equip kiya hua owned frame, VIP se pehle', () {
    const p = FrameProfile(vip: 3, equippedId: 'std_0002', owned: {'std_0002'});
    expect(FrameResolver.resolve(p)?.id, 'std_0002');
  });

  test('owned nahi hai to VIP frame fallback', () {
    const p = FrameProfile(vip: 3, equippedId: 'std_0002');
    expect(FrameResolver.resolve(p)?.id, 'vip_3');
  });

  test('kuch nahi to null', () {
    expect(FrameResolver.resolve(const FrameProfile()), isNull);
  });

  test('canEquip: owned standard ok, VIP level check', () {
    const p = FrameProfile(vip: 2, owned: {'std_0010'});
    expect(FrameResolver.canEquip(p, 'std_0010'), isTrue);
    expect(FrameResolver.canEquip(p, 'std_0011'), isFalse);
    expect(FrameResolver.canEquip(p, 'vip_2'), isTrue);
    expect(FrameResolver.canEquip(p, 'vip_3'), isFalse);
  });

  test('AccountRole parse', () {
    expect(roleFrom('superadmin'), AccountRole.superAdmin);
    expect(roleFrom('superbd'), AccountRole.superBd);
    expect(roleFrom(null), AccountRole.user);
  });
}
