import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/vip_level.dart';
import '../painting/creature_emblem_painter.dart';

/// Hero badge: 3D tilt (perspective Matrix4) + glow + emblem. Animation ka period 4 sec.
class VipHero extends StatefulWidget {
  const VipHero({super.key, required this.level, this.size = 180, this.reduceMotion = false});

  final VipLevel level;
  final double size;
  final bool reduceMotion;

  @override
  State<VipHero> createState() => _VipHeroState();
}

class _VipHeroState extends State<VipHero> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(seconds: 4));

  @override
  void initState() {
    super.initState();
    if (!widget.reduceMotion) _c.repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final t = widget.reduceMotion ? 0.0 : _c.value;
        final angleY = math.sin(t * math.pi * 2) * 0.22;
        final angleX = math.cos(t * math.pi * 2) * 0.10;
        final transform = Matrix4.identity()
          ..setEntry(3, 2, 0.0015) // perspective
          ..rotateY(angleY)
          ..rotateX(angleX);
        return Transform(
          alignment: Alignment.center,
          transform: transform,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: widget.level.accent.withValues(alpha: 0.45),
                  blurRadius: 40,
                  spreadRadius: 6,
                ),
              ],
            ),
            child: CustomPaint(
              painter: CreatureEmblemPainter(level: widget.level, t: t),
            ),
          ),
        );
      },
    );
  }
}
