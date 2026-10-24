import 'account_role.dart';

/// Ek user ke frame se related data. Firestore se aata hai.
class FrameProfile {
  final AccountRole role;
  final int vip;
  final String? equippedId;
  final Set<String> owned;

  const FrameProfile({
    this.role = AccountRole.user,
    this.vip = 0,
    this.equippedId,
    this.owned = const {},
  });
}
