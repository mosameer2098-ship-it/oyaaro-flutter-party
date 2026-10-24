import 'package:flutter/material.dart';
import 'package:oyaroo/core/frames.dart';

// Avatar ke charo taraf frame (milestone null ho to bina frame ke)
class FrameAvatar extends StatelessWidget {
  final int? milestone;
  final double radius;
  final Widget child;
  const FrameAvatar({super.key, this.milestone, this.radius = 36, required this.child});

  @override
  Widget build(BuildContext context) {
    if (milestone == null) {
      return CircleAvatar(radius: radius, child: child);
    }
    final f = Frames.byMilestone(milestone!);
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(colors: f.colors),
      ),
      child: CircleAvatar(radius: radius, child: child),
    );
  }
}
