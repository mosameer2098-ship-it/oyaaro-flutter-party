import 'package:flutter/material.dart';

import '../logic/vip_rules.dart';
import '../models/vip_level.dart';

/// Tab ke level tak ki privileges. userLevel se kam wali locked dikhti hain.
class PrivilegeGrid extends StatelessWidget {
  const PrivilegeGrid({super.key, required this.tabLevel, required this.userLevel, required this.accent});

  final int tabLevel;
  final int userLevel;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final list = VipRules.privilegesUpTo(tabLevel);
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 0.85,
      children: [
        for (final p in list)
          Opacity(
            opacity: p.minLevel <= userLevel ? 1 : 0.45,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1030),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: accent.withValues(alpha: 0.25)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(p.icon, color: accent, size: 30),
                  const SizedBox(height: 6),
                  Text(p.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 11, color: Colors.white)),
                  if (p.minLevel > userLevel)
                    Text('VIP ${p.minLevel}',
                        style: TextStyle(fontSize: 10, color: accent)),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
