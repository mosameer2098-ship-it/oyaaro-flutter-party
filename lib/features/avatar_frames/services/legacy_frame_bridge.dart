import '../catalog/frame_catalog.dart';
import '../models/account_role.dart';
import '../models/frame_profile.dart';

/// Purana level-reward system (users.frames = [1..20], users.equippedFrame = int)
/// aur naya system (users.ownedFrames = ["std_0001"], users.equippedFrame = "std_0001")
/// dono ko ek FrameProfile mein laata hai. Isse purana data khona nahi padta.
class LegacyFrameBridge {
  const LegacyFrameBridge._();

  /// Level milestone m (1..20) ka naya frame id. Har milestone ko alag standard frame milta hai.
  static String milestoneToFrameId(int m) {
    final index = ((m - 1) * 50).clamp(0, FrameCatalog.standardCount - 1);
    return 'std_${(index + 1).toString().padLeft(4, '0')}';
  }

  static String? _equippedToId(dynamic value) {
    if (value is String && value.isNotEmpty) return value;
    if (value is num) {
      final m = value.toInt();
      if (m >= 1 && m <= 20) return milestoneToFrameId(m);
    }
    return null;
  }

  static FrameProfile profileFrom(Map<String, dynamic>? data) {
    final d = data ?? const <String, dynamic>{};
    final owned = <String>{};
    for (final v in (d['ownedFrames'] as List?) ?? const []) {
      if (v is String) owned.add(v);
    }
    for (final v in (d['frames'] as List?) ?? const []) {
      final id = _equippedToId(v);
      if (id != null) owned.add(id);
    }
    return FrameProfile(
      role: AccountRoleX.parse(d['role'] as String?),
      vip: (d['vip'] as num?)?.toInt() ?? 0,
      equippedId: _equippedToId(d['equippedFrame']),
      owned: owned,
    );
  }
}
