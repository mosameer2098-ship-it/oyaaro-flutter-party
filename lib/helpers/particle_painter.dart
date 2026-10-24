import 'dart:math';
import 'package:flutter/material.dart';

// Gift ke aas-paas chamakte particles. t = 0..1 (animation progress)
class ParticlePainter extends CustomPainter {
  final double t;
  final List<Color> colors;
  final int count;
  const ParticlePainter({required this.t, required this.colors, required this.count});

  @override
  void paint(Canvas canvas, Size size) {
    final rng = Random(7);
    final center = size.center(Offset.zero);
    final maxR = size.shortestSide * 0.5;
    final eased = Curves.easeOut.transform(t);
    final alpha = pow(1 - t, 1.2).toDouble();
    for (var i = 0; i < count; i++) {
      final angle = i * 2 * pi / count + rng.nextDouble() * 0.4;
      final dist = maxR * (0.35 + 0.65 * rng.nextDouble()) * eased;
      final pos = center + Offset(cos(angle), sin(angle)) * dist;
      final r = 3 + rng.nextDouble() * 4;
      final color = colors[i % colors.length].withOpacity(alpha.clamp(0.0, 1.0));
      canvas.drawCircle(pos, r, Paint()..color = color);
    }
  }

  @override
  bool shouldRepaint(covariant ParticlePainter old) => old.t != t;
}
