import 'package:flutter/material.dart';

import '../models/vip_level.dart';
import '../painting/creature_emblem_painter.dart';

/// Identity items: title, medal, frame, room card, chat bubble, mic wave, vehicle
class VipIdentityGrid extends StatelessWidget {
  const VipIdentityGrid({super.key, required this.level});

  final VipLevel level;

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[
      _card('Title', _titleChip()),
      _card('Medal', SizedBox(width: 70, height: 70, child: CustomPaint(painter: CreatureEmblemPainter(level: level, t: 0)))),
      _card('Frame', _frame()),
      _card('Room card', _roomCard()),
      _card('Chat bubble', _bubble()),
      _card('Mic wave', _micWave()),
      _card('Vehicle', SizedBox(width: 70, height: 70, child: CustomPaint(painter: CreatureEmblemPainter(level: level, t: 0.5)))),
    ];
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 0.9,
      children: items,
    );
  }

  Widget _card(String label, Widget child) => Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1030),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: level.accent.withValues(alpha: 0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: Center(child: child)),
            Text(label, style: TextStyle(color: level.accent, fontSize: 12)),
          ],
        ),
      );

  Widget _titleChip() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [level.c1, level.c2]),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text('VIP ${level.level}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      );

  Widget _frame() => Container(
        width: 66,
        height: 66,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: level.accent, width: 4),
          gradient: SweepGradient(colors: [level.c1, level.c2, level.c1]),
        ),
      );

  Widget _roomCard() => Container(
        width: 80,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [level.c2, level.c1]),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(level.name, style: const TextStyle(color: Colors.white, fontSize: 11)),
      );

  Widget _bubble() => Container(
        width: 80,
        height: 40,
        decoration: BoxDecoration(
          border: Border.all(color: level.accent, width: 2),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: level.accent.withValues(alpha: 0.4), blurRadius: 10)],
        ),
      );

  Widget _micWave() => Container(
        width: 62,
        height: 62,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: level.accent.withValues(alpha: 0.7), width: 3),
          boxShadow: [BoxShadow(color: level.accent.withValues(alpha: 0.5), blurRadius: 14, spreadRadius: 2)],
        ),
      );
}
