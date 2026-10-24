import '../catalog/vip_levels_catalog.dart';
import '../catalog/vip_privileges_catalog.dart';
import '../models/vip_level.dart';
import '../models/vip_privilege.dart';

/// Pure VIP logic. UI aur server dono se alag, test karna aasaan.
class VipRules {
  const VipRules._();

  /// Level tak ki saari privileges (cumulative)
  static List<VipPrivilege> privilegesUpTo(int level) =>
      VipPrivilegesCatalog.all.where((p) => p.minLevel <= level).toList();

  /// Null = khareed sakte hain. Warna wajah.
  static String? buyBlocker({
    required int currentLevel,
    required int target,
    required int points,
    required int coins,
  }) {
    final t = VipLevelsCatalog.byLevel(target);
    if (currentLevel >= target) return 'VIP $target aap pehle le chuke hain';
    if (currentLevel != target - 1) return 'Pehle VIP ${target - 1} lo';
    if (points < t.points) return 'Points chahiye ${t.points}, aapke $points hain';
    if (coins < t.price) return 'Coins kam hain (${t.price} chahiye)';
    return null;
  }

  /// Agla level (null agar max par ho)
  static VipLevel? nextLevel(int current) =>
      current >= VipLevelsCatalog.count ? null : VipLevelsCatalog.byLevel(current + 1);

  /// Agle level tak progress 0..1
  static double progress({required int current, required int points}) {
    final next = nextLevel(current);
    if (next == null) return 1;
    final prevPoints = current == 0 ? 0 : VipLevelsCatalog.byLevel(current).points;
    final span = next.points - prevPoints;
    if (span <= 0) return 1;
    return ((points - prevPoints) / span).clamp(0.0, 1.0).toDouble();
  }
}
