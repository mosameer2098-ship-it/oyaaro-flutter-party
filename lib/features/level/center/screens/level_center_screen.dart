import 'package:flutter/material.dart';

import '../../../shared/user_stream.dart';
import '../catalog/level_reward_catalog.dart';
import '../handlers/level_reward_handler.dart';
import '../logic/level_rules.dart';
import '../models/level_reward.dart';
import '../widgets/level_header_card.dart';
import '../widgets/reward_section.dart';

class LevelCenterScreen extends StatefulWidget {
  const LevelCenterScreen({super.key, required this.uid});

  final String uid;

  @override
  State<LevelCenterScreen> createState() => _LevelCenterScreenState();
}

class _LevelCenterScreenState extends State<LevelCenterScreen> {
  final _users = UserStream();
  final _handler = LevelRewardHandler();

  static const _sections = <_SectionSpec>[
    _SectionSpec('Level', RewardKind.badge, 3),
    _SectionSpec('Coins Reward', RewardKind.coins, 3),
    _SectionSpec('Medal', RewardKind.medal, 2),
    _SectionSpec('Frame', RewardKind.frame, 2),
    _SectionSpec('Theme', RewardKind.theme, 2),
    _SectionSpec('Vehicle', RewardKind.vehicle, 2),
    _SectionSpec('Custom ID', RewardKind.customId, 3),
    _SectionSpec('Customize profile background', RewardKind.background, 2),
    _SectionSpec('Super Mic', RewardKind.superMic, 2),
    _SectionSpec('Opening page', RewardKind.openingPage, 2),
    _SectionSpec('Entrance', RewardKind.entrance, 2),
  ];

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, dynamic>>(
      stream: _users.watch(widget.uid),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final d = snap.data!;
        final exp = (d['exp'] as num?)?.toInt() ?? 0;
        final name = (d['name'] as String?) ?? 'User';
        final current = LevelRules.levelFromExp(exp);
        final claimed = Set<String>.from(((d['claimedRewards'] as List?) ?? const []).cast<String>());

        return Scaffold(
          backgroundColor: const Color(0xFF041421),
          appBar: AppBar(
            backgroundColor: const Color(0xFF041421),
            title: const Text('Level'),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              LevelHeaderCard(name: name, exp: exp),
              for (final s in _sections)
                RewardSection(
                  title: s.title,
                  rewards: LevelRewardCatalog.sections[s.kind] ?? const [],
                  current: current,
                  claimed: claimed,
                  columns: s.columns,
                  onClaim: (r) async {
                    final err = await _handler.claim(r, current: current, claimed: claimed);
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(err ?? 'Reward claim ho gaya!')),
                    );
                  },
                ),
              const SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }
}

class _SectionSpec {
  const _SectionSpec(this.title, this.kind, this.columns);

  final String title;
  final RewardKind kind;
  final int columns;
}
