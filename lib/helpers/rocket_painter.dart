import 'package:flutter/material.dart';
import 'package:oyaroo/core/rockets.dart';

// Rocket ko canvas par draw karta hai: nose, body, porthole, fins, boosters, engine nozzle, exhaust.
class RocketPainter extends CustomPainter {
  final RocketSpec spec;
  const RocketPainter(this.spec);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final bodyW = w * 0.34;
    final bodyTop = h * 0.22;
    final bodyBottom = h * 0.8;
    final bodyLeft = cx - bodyW / 2;
    final bodyRight = cx + bodyW / 2;
    final shade = Color.lerp(spec.body, Colors.black, 0.35)!;
    final light = Color.lerp(spec.body, Colors.white, 0.5)!;

    // Exhaust flame
    canvas.drawPath(
      Path()
        ..moveTo(cx - bodyW * 0.22, bodyBottom + h * 0.09)
        ..quadraticBezierTo(cx, h * 1.02, cx + bodyW * 0.22, bodyBottom + h * 0.09)
        ..close(),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFF59D), Color(0xFFFF7043), Color(0x00FF7043)],
        ).createShader(Rect.fromLTWH(0, bodyBottom, w, h - bodyBottom)),
    );

    // Side boosters
    if (spec.boosters) {
      for (final side in [-1.0, 1.0]) {
        final x = cx + side * (bodyW / 2 + w * 0.07);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
                center: Offset(x, bodyTop + h * 0.38), width: w * 0.12, height: h * 0.46),
            Radius.circular(w * 0.06),
          ),
          Paint()..color = Color.lerp(spec.body, Colors.grey, 0.25)!,
        );
        canvas.drawPath(
          Path()
            ..moveTo(x - w * 0.06, bodyTop + h * 0.15)
            ..lineTo(x, bodyTop + h * 0.02)
            ..lineTo(x + w * 0.06, bodyTop + h * 0.15)
            ..close(),
          Paint()..color = spec.accent,
        );
      }
    }

    // Fins
    final finPaint = Paint()..color = spec.fin;
    void sideFin(double yTop, double yTip, double reach) {
      canvas.drawPath(
        Path()
          ..moveTo(bodyLeft, yTop)
          ..lineTo(bodyLeft - w * reach, yTip)
          ..lineTo(bodyLeft, bodyBottom),
        finPaint,
      );
      canvas.drawPath(
        Path()
          ..moveTo(bodyRight, yTop)
          ..lineTo(bodyRight + w * reach, yTip)
          ..lineTo(bodyRight, bodyBottom),
        finPaint,
      );
    }

    sideFin(bodyBottom - h * 0.16, bodyBottom + h * 0.02, 0.14);
    if (spec.finCount >= 4) {
      sideFin(bodyTop + h * 0.3, bodyTop + h * 0.16, 0.08);
    }

    // Engine bell (nozzle)
    final bell = Path()
      ..moveTo(cx - bodyW * 0.3, bodyBottom)
      ..lineTo(cx + bodyW * 0.3, bodyBottom)
      ..lineTo(cx + bodyW * 0.44, bodyBottom + h * 0.09)
      ..lineTo(cx - bodyW * 0.44, bodyBottom + h * 0.09)
      ..close();
    canvas.drawPath(
      bell,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF3E2723), Color(0xFFBDBDBD), Color(0xFF3E2723)],
        ).createShader(bell.getBounds()),
    );

    // Body
    final bodyRect = Rect.fromLTRB(bodyLeft, bodyTop, bodyRight, bodyBottom);
    canvas.drawRRect(
      RRect.fromRectAndRadius(bodyRect, Radius.circular(w * 0.04)),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [shade, spec.body, light, shade],
        ).createShader(bodyRect),
    );

    // Stripes
    for (var i = 0; i < spec.stripes; i++) {
      final y = bodyTop + h * 0.22 + i * h * 0.05;
      canvas.drawRect(
        Rect.fromLTRB(bodyLeft, y, bodyRight, y + h * 0.018),
        Paint()..color = spec.accent,
      );
    }

    // Seam line
    canvas.drawRect(
      Rect.fromLTRB(bodyLeft, bodyBottom - h * 0.08, bodyRight, bodyBottom - h * 0.075),
      Paint()..color = shade,
    );

    // Nose cone
    final noseTop = h * 0.03;
    final nose = spec.pointedNose
        ? (Path()
          ..moveTo(bodyLeft, bodyTop)
          ..quadraticBezierTo(cx, noseTop - h * 0.02, bodyRight, bodyTop)
          ..close())
        : (Path()
          ..moveTo(bodyLeft, bodyTop)
          ..quadraticBezierTo(bodyLeft, noseTop, cx, noseTop)
          ..quadraticBezierTo(bodyRight, noseTop, bodyRight, bodyTop)
          ..close());
    canvas.drawPath(nose, Paint()..color = spec.accent);

    // Porthole
    final window = Offset(cx, bodyTop + h * 0.3);
    canvas.drawCircle(window, w * 0.075, Paint()..color = const Color(0xFF37474F));
    canvas.drawCircle(
      window,
      w * 0.058,
      Paint()
        ..shader = const RadialGradient(
          colors: [Color(0xFFE1F5FE), Color(0xFF0288D1)],
        ).createShader(Rect.fromCircle(center: window, radius: w * 0.058)),
    );
  }

  @override
  bool shouldRepaint(covariant RocketPainter oldDelegate) =>
      oldDelegate.spec.id != spec.id;
}

// Rocket ka preview widget (bounded box ke andar)
class RocketPreview extends StatelessWidget {
  final RocketSpec spec;
  const RocketPreview({super.key, required this.spec});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: RocketPainter(spec), size: Size.infinite);
  }
}
