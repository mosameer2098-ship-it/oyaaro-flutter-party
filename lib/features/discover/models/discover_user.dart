/// Ek user ka public profile. Saari values real data se aati hain. Missing hone par null.
class DiscoverUser {
  final String uid;
  final String name;
  final String? shortId; // User ID jo profile par dikhti hai
  final String? photoUrl;
  final int? level; // null = app ne level ka data nahi diya
  final int vip; // 0 = VIP nahi
  final DateTime? lastSeen; // heartbeat ka time

  const DiscoverUser({
    required this.uid,
    required this.name,
    this.shortId,
    this.photoUrl,
    this.level,
    this.vip = 0,
    this.lastSeen,
  });

  /// Online sirf tab, jab heartbeat [window] ke andar aaya ho. Koi fake status nahi.
  bool isOnline(DateTime now, {Duration window = const Duration(minutes: 2)}) {
    final seen = lastSeen;
    if (seen == null) return false;
    return now.difference(seen) <= window;
  }
}
