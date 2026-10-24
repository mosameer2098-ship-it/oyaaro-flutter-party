import 'package:flutter/material.dart';

import '../logic/level_rules.dart';
import '../models/level_reward.dart';
import '../painting/reward_art.dart';

/// Ek section: title + grid. Badge/coins/medal jaise choti cards 3 column, badi cards 2 column.
class RewardSection extends StatelessWidget {
  const RewardSection({
    super.key,
    required this.title,
    required this.rewards,
    required this.current,
    required this.claimed,
    required this.onClaim,
    this.columns = 3,
  });

  final String title;
  final List<LevelReward> rewards;
  final int current;
  final Set<String> claimed;
  final void Function(LevelReward reward) onClaim;
  final int columns;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        ),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: columns,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: columns == 3 ? 0.72 : 0.9,
          children: [for (final r in rewards) _card(r)],
        ),
      ],
    );
  }

  Widget _card(LevelReward r) {
    final state = LevelRules.stateOf(reward: r, current: current, claimed: claimed);
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFF0F2233),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1F4B66)),
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: const Color(0xFF1B5E74), borderRadius: BorderRadius.circular(8)),
              child: Text('Lv.${r.level}', style: const TextStyle(color: Colors.white, fontSize: 11)),
            ),
          ),
          Expanded(child: Center(child: RewardArt(reward: r, size: columns == 3 ? 64 : 90))),
          Text(_subtitle(r), style: const TextStyle(color: Colors.white70, fontSize: 11), textAlign: TextAlign.center),
          const SizedBox(height: 4),
          _action(state, r),
        ],
      ),
    );
  }

  String _subtitle(LevelReward r) {
    switch (r.kind) {
      case RewardKind.coins:
        return '${r.coins} coins';
      case RewardKind.customId:
        return '${r.digits} digits x${r.days} days';
      case RewardKind.openingPage:
      case RewardKind.entrance:
        return 'x${r.days} days';
      default:
        return r.stars > 0 ? '${r.stars} star' : '';
    }
  }

  Widget _action(RewardState state, LevelReward r) {
    switch (state) {
      case RewardState.claimable:
        return SizedBox(
          height: 30,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(padding: EdgeInsets.zero),
            onPressed: () => onClaim(r),
            child: const Text('Claim', style: TextStyle(fontSize: 12)),
          ),
        );
      case RewardState.claimed:
        return const SizedBox(
          height: 30,
          child: Center(child: Icon(Icons.check_circle, color: Colors.greenAccent, size: 20)),
        );
      case RewardState.locked:
        return const SizedBox(
          height: 30,
          child: Center(child: Icon(Icons.lock, color: Colors.white38, size: 18)),
        );
    }
  }
}
