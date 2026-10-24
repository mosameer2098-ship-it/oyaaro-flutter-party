import '../catalog/frame_catalog.dart';
import '../models/account_role.dart';
import '../models/frame_profile.dart';
import '../models/frame_spec.dart';

/// Ye decide karta hai ki profile par kaunsa frame dikhega.
/// Priority: 1) staff role frame  2) equip kiya hua owned frame  3) VIP frame  4) koi frame nahi.
class FrameResolver {
  const FrameResolver._();

  static FrameSpec? resolve(FrameProfile p) {
    final roleId = p.role.roleFrameId;
    if (p.role.isStaff && roleId != null) return FrameCatalog.byId(roleId);

    final eq = p.equippedId;
    if (eq != null && p.owned.contains(eq)) {
      final f = FrameCatalog.byId(eq);
      if (f != null && f.category != FrameCategory.role) return f;
    }

    if (p.vip > 0) return FrameCatalog.vipFrame(p.vip);
    return null;
  }

  /// Kya user ye frame equip kar sakta hai?
  static bool canEquip(FrameProfile p, String frameId) {
    if (p.role.isStaff) return false; // staff ka frame locked hai
    final f = FrameCatalog.byId(frameId);
    if (f == null) return false;
    switch (f.category) {
      case FrameCategory.role:
        return false;
      case FrameCategory.vip:
        return p.vip >= (f.vipLevel ?? 999);
      case FrameCategory.standard:
        return p.owned.contains(frameId);
    }
  }
}

/// Role parse helper, Firestore data ke liye
AccountRole roleFrom(String? raw) => AccountRoleX.parse(raw);
