import 'package:flutter/material.dart';

import '../catalog/level_reward_catalog.dart';
import '../logic/level_rules.dart';
import '../models/level_reward.dart';
import '../painting/reward_art.dart';

/// Upar wala card: avatar, naam, EXP progress, aur current level ka badge
class LevelHeaderCard extends StatelessWidget {
  const LevelHeaderCard({super.key, required this.name, required this.exp});

  final String name;
  final int exp;

  @override
  Widget build(BuildContext context) {
    final lv = LevelRules.levelFromExp(exp);
    final tierStart = lv >= 100 ? 100 : (lv ~/ 10) * 10 == 0 ? 1 : (lv ~/ 10) * 10;
    final badge = LevelRewardCatalog.sections[RewardKind.badge]!.firstWhere(
      (r) => r.level == tierStart,
      orElse: () => LevelRewardCatalog.sections[RewardKind.badge]!.first,
    );
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF1E88E5), Color(0xFF0D47A1)]),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('$exp EXP', style: const TextStyle(color: Color(0xFFFFEB3B))),
                const SizedBox(height: 6),
                LinearProgressIndicator(value: LevelRules.progress(exp), minHeight: 8),
                const SizedBox(height: 6),
                Text(
                  lv >= LevelRules.maxLevel
                      ? 'Max level'
                      : 'Need ${LevelRules.expToNext(exp)} EXP for Lv.${lv + 1}',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            children: [
              RewardArt(reward: badge, size: 96),
              Text('Lv.$lv', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}
