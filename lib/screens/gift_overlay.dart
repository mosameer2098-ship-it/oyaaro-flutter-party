import 'dart:math';
import 'package:flutter/material.dart';
import 'package:oyaroo/core/gift_catalog.dart';
import 'package:oyaroo/helpers/gift_helper.dart';
import 'package:oyaroo/helpers/particle_painter.dart';

// Room mein gift ka premium animation: glow, bounce, particles. Big gift par zyada effect.
class GiftOverlay extends StatefulWidget {
  final GiftSpec spec;
  final String senderName;
  final VoidCallback onDone;
  const GiftOverlay({
    super.key,
    required this.spec,
    required this.senderName,
    required this.onDone,
  });

  @override
  State<GiftOverlay> createState() => _GiftOverlayState();
}

class _GiftOverlayState extends State<GiftOverlay> with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: GiftHelper.durationMs(widget.spec.tier)),
    );
    _c.forward().whenComplete(() {
      if (mounted) widget.onDone();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final spec = widget.spec;
    final big = spec.tier == GiftTier.big || spec.tier == GiftTier.legendary;
    final iconBox = big ? 150.0 : 96.0;

    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          final v = _c.value.clamp(0.0, 1.0).toDouble();
          final fade = (v < 0.8 ? 1.0 : (1 - v) / 0.2).clamp(0.0, 1.0).toDouble();
          final pop = Curves.elasticOut.transform(v);
          final spin = spec.tier == GiftTier.legendary ? v * 2 * pi : 0.0;

          return Opacity(
            opacity: fade,
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: ParticlePainter(
                      t: v,
                      colors: [spec.c1, spec.c2, Colors.white],
                      count: GiftHelper.particleCount(spec.tier),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Center(
                    child: Transform.rotate(
                      angle: spin,
                      child: Transform.scale(
                        scale: 0.2 + 0.8 * pop,
                        child: Container(
                          width: iconBox,
                          height: iconBox,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(colors: [spec.c1, spec.c2]),
                            boxShadow: [
                              BoxShadow(
                                color: spec.c1.withOpacity(0.6),
                                blurRadius: 30,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                          child: Icon(spec.icon, color: Colors.white, size: iconBox * 0.55),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 24,
                  left: 16,
                  right: 16,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${widget.senderName} ne ${spec.name} bheja!  (${GiftHelper.priceLabel(spec)})',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
