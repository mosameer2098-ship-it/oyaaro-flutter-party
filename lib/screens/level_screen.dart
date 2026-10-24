import 'package:oyaroo/core/brand.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:oyaroo/core/frames.dart';
import 'package:oyaroo/core/level_rules.dart';
import 'package:oyaroo/core/ui.dart';
import 'package:oyaroo/handlers/level_handler.dart';
import 'package:oyaroo/helpers/formatters.dart';
import 'package:oyaroo/helpers/frame_ring.dart';
import 'package:oyaroo/services/user_service.dart';

class LevelScreen extends StatelessWidget {
  const LevelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final handler = LevelHandler();
    return Scaffold(
      appBar: AppBar(title: const Text('Level')),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: UserService.profileStream(uid),
        builder: (context, snap) {
          final d = snap.data?.data() ?? {};
          final exp = (d['exp'] ?? 0) as int;
          final claimed = List<int>.from(d['claimedLevels'] ?? []);
          final equipped = d['equippedFrame'] as int?;
          final level = LevelRules.levelFor(exp);
          final cur = LevelRules.requiredExp(level);
          final next = level >= LevelRules.maxLevel ? cur : LevelRules.requiredExp(level + 1);
          final progress = level >= LevelRules.maxLevel ? 1.0 : (exp - cur) / (next - cur);

          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      FrameAvatar(milestone: equipped, radius: 36, child: Text('$level')),
                      const SizedBox(height: 8),
                      Text('Level $level / ${LevelRules.maxLevel}',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(value: progress.clamp(0.0, 1.0).toDouble()),
                      const SizedBox(height: 4),
                      Text('${formatCoins(exp)} exp  (next: ${formatCoins(next)})'),
                    ],
                  ),
                ),
              ),
              for (var m = 1; m <= LevelRules.milestoneCount; m++)
                _milestoneRow(context, handler, m, level, claimed, equipped),
            ],
          );
        },
      ),
    );
  }

  Widget _milestoneRow(BuildContext context, LevelHandler handler, int m, int level,
      List<int> claimed, int? equipped) {
    final frame = Frames.byMilestone(m);
    final reached = level >= m * LevelRules.milestoneEvery;
    final owned = claimed.contains(m);

    final Widget trailing;
    if (owned) {
      trailing = equipped == m
          ? const Text('Equipped')
          : TextButton(
              onPressed: () => reportResult(context, handler.equip(m), successMsg: 'Frame laga diya'),
              child: const Text('Equip'),
            );
    } else if (reached) {
      trailing = ElevatedButton(
        onPressed: () => reportResult(context, handler.claim(m), successMsg: 'Reward mil gaya!'),
        child: const Text('Claim'),
      );
    } else {
      trailing = const Text('Locked');
    }

    return Card(
      child: ListTile(
        leading: FrameAvatar(milestone: m, radius: 20, child: Text('${m * 10}')),
        title: Text('Level ${m * 10}  -  ${frame.name} frame'),
        subtitle: Text('${formatCoins(LevelRules.rewardCoins(m))} ${Brand.coinName}'),
        trailing: trailing,
      ),
    );
  }
}
