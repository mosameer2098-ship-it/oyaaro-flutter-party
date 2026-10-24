import 'package:flutter/material.dart';

import '../discover_theme.dart';

/// Level null ho to kuch nahi dikhta. Fake level kabhi nahi.
class LevelBadge extends StatelessWidget {
  const LevelBadge({super.key, required this.level});
  final int? level;
  @override
  Widget build(BuildContext context) {
    final l = level;
    if (l == null) return const SizedBox.shrink();
    return _pill('Lv $l', DiscoverColors.neonCyan);
  }
}

/// vip 0 ho to kuch nahi dikhta
class VipBadge extends StatelessWidget {
  const VipBadge({super.key, required this.vip});
  final int vip;
  @override
  Widget build(BuildContext context) {
    if (vip <= 0) return const SizedBox.shrink();
    return _pill('VIP $vip', DiscoverColors.neonPink);
  }
}

Widget _pill(String text, Color color) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.7)),
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
    );
