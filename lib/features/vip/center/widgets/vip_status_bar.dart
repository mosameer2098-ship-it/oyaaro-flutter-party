import 'package:flutter/material.dart';

import '../logic/vip_rules.dart';

/// Neeche ka status bar: aapka VIP, points progress, aur recharge button
class VipStatusBar extends StatelessWidget {
  const VipStatusBar({
    super.key,
    required this.currentLevel,
    required this.points,
    required this.onRecharge,
  });

  final int currentLevel;
  final int points;
  final VoidCallback onRecharge;

  @override
  Widget build(BuildContext context) {
    final next = VipRules.nextLevel(currentLevel);
    final progress = VipRules.progress(current: currentLevel, points: points);
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF2A1640),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              currentLevel == 0 ? 'Aapke paas VIP nahi hai' : 'Aapka VIP: $currentLevel',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(value: progress, minHeight: 8),
                ),
                const SizedBox(width: 10),
                Text(next == null ? 'Max' : 'Next: VIP ${next.level}',
                    style: const TextStyle(color: Colors.white70)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: Text('Points: $points', style: const TextStyle(color: Colors.white70))),
                ElevatedButton(onPressed: onRecharge, child: const Text('Recharge')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
