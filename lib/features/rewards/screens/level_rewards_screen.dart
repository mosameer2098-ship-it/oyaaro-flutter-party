import 'package:flutter/material.dart';

import '../../shared/level_math.dart';
import '../../shared/user_stream.dart';
import '../handlers/rewards_handler.dart';
import '../models/level_milestone.dart';
import '../services/rewards_service.dart';

class LevelRewardsScreen extends StatefulWidget {
  const LevelRewardsScreen({super.key, required this.uid});
  final String uid;

  @override
  State<LevelRewardsScreen> createState() => _LevelRewardsScreenState();
}

class _LevelRewardsScreenState extends State<LevelRewardsScreen> {
  final _handler = RewardsHandler(RewardsService());
  final _users = UserStream();

  Future<void> _claim(LevelMilestone m) async {
    final err = await _handler.claim(m);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(err ?? 'Reward mil gaya!'),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Level Rewards')),
      body: StreamBuilder<Map<String, dynamic>>(
        stream: _users.watch(widget.uid),
        builder: (context, snap) {
          if (snap.hasError) {
            return const Center(child: Text('Data load nahi hua. Dobara try karein'));
          }
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final d = snap.data!;
          final exp = (d['exp'] as num?)?.toInt() ?? 0;
          final claimed = ((d['claimedLevels'] as List?) ?? const [])
              .whereType<num>()
              .map((e) => e.toInt())
              .toList();
          final list = LevelMilestone.build(exp: exp, claimedIndexes: claimed);
          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              Text('Level ${LevelMath.levelFor(exp)} / ${LevelMath.maxLevel}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              LinearProgressIndicator(value: LevelMath.progressFor(exp)),
              const SizedBox(height: 12),
              for (final m in list)
                Card(
                  child: ListTile(
                    title: Text('Level ${m.level}'),
                    subtitle: Text('${m.coins} coins + frame'),
                    trailing: m.claimed
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : m.canClaim
                            ? ElevatedButton(onPressed: () => _claim(m), child: const Text('Claim'))
                            : const Text('Locked'),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
