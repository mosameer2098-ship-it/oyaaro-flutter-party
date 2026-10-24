import 'package:flutter/material.dart';

import '../catalog/theme_catalog.dart';

/// Room ka background. Equipped theme ho to uska gradient, nahi to default.
class RoomBackground extends StatelessWidget {
  const RoomBackground({super.key, this.themeId, required this.child});

  final String? themeId;
  final Widget child;

  static const _defaultColors = [Color(0xFF1A0736), Color(0xFF0B0214)];

  @override
  Widget build(BuildContext context) {
    final spec = themeId == null ? null : ThemeCatalog.byId(themeId!);
    final colors = spec == null ? _defaultColors : spec.colors.take(2).toList();
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: colors,
        ),
      ),
      child: child,
    );
  }
}
