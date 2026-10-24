import 'dart:math' as math;

import 'package:flutter/material.dart';

/// 3D entry effect: rotating rings (perspective se squash) + burst particles.
/// t = 0..1 (entry animation progress)
class EntryEffect3DPainter extends CustomPainter {
  EntryEffect3DPainter({required this.t, required this.color});

  final double t;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final s = size.shortestSide;
    final eased = Curves.easeOutCubic.transform(t);

    for (var k = 0; k < 3; k++) {
      final phase = (t + k / 3) % 1.0;
      final r = s * (0.12 + 0.36 * phase) * eased;
      final tilt = math.cos((t + k * 0.3) * math.pi * 2 * 0.5).abs() * 0.75 + 0.25;
      final alpha = (1 - phase).clamp(0.0, 1.0);
      canvas.drawOval(
        Rect.fromCenter(center: c, width: r * 2, height: r * 2 * tilt),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = s * 0.012
          ..color = color.withValues(alpha: alpha * 0.9),
      );
    }

    final alphaP = (1 - t).clamp(0.0, 1.0);
    for (var i = 0; i < 24; i++) {
      final a = i * math.pi * 2 / 24;
      final d = s * 0.48 * eased;
      final p = c + Offset(math.cos(a), math.sin(a)) * d;
      canvas.drawCircle(p, s * 0.012, Paint()..color = color.withValues(alpha: alphaP));
    }
  }

  @override
  bool shouldRepaint(covariant EntryEffect3DPainter old) => old.t != t || old.color != color;
}
