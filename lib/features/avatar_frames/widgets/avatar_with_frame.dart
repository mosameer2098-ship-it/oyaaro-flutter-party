import 'package:flutter/material.dart';

import '../models/frame_spec.dart';
import 'animated_avatar_frame.dart';

/// Host app ka ek hi widget: frame ho to animated frame, nahi to plain avatar.
class AvatarWithFrame extends StatelessWidget {
  const AvatarWithFrame({
    super.key,
    required this.child,
    this.frame,
    this.radius = 36,
    this.reduceMotion = false,
  });

  final Widget child;
  final FrameSpec? frame;
  final double radius;
  final bool reduceMotion;

  @override
  Widget build(BuildContext context) {
    final f = frame;
    if (f == null) {
      return SizedBox(
        width: radius * 2,
        height: radius * 2,
        child: ClipOval(child: child),
      );
    }
    return AnimatedAvatarFrame(
      frame: f,
      radius: radius,
      reduceMotion: reduceMotion,
      child: child,
    );
  }
}
