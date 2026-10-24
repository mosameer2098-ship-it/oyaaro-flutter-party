import 'package:flutter/material.dart';

import '../models/frame_spec.dart';
import '../painting/frame_painter.dart';

/// Avatar par animated frame. Frame bada hota hai, avatar beech mein.
/// Har avatar ka apna controller hai. Long lists mein [reduceMotion] true rakhein.
class AnimatedAvatarFrame extends StatefulWidget {
  const AnimatedAvatarFrame({
    super.key,
    required this.frame,
    required this.child,
    this.radius = 36,
    this.reduceMotion = false,
    this.period = const Duration(seconds: 4),
  });

  final FrameSpec frame;
  final Widget child;
  final double radius;
  final bool reduceMotion;
  final Duration period;

  @override
  State<AnimatedAvatarFrame> createState() => _AnimatedAvatarFrameState();
}

class _AnimatedAvatarFrameState extends State<AnimatedAvatarFrame>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.period);
    if (!widget.reduceMotion) _controller.repeat();
  }

  @override
  void didUpdateWidget(covariant AnimatedAvatarFrame oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.reduceMotion) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.radius * 2 * 1.7;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          RepaintBoundary(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) => CustomPaint(
                size: Size(size, size),
                painter: FrameArtPainter(
                  spec: widget.frame,
                  t: _controller.value,
                  reduceMotion: widget.reduceMotion,
                ),
              ),
            ),
          ),
          SizedBox(
            width: widget.radius * 2,
            height: widget.radius * 2,
            child: ClipOval(child: widget.child),
          ),
        ],
      ),
    );
  }
}
