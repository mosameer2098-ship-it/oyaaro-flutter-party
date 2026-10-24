import 'package:flutter/material.dart';

import '../discover_theme.dart';

/// Avatar: photo URL ho to wo, warna default asset. Online dot optional.
class DiscoverAvatar extends StatelessWidget {
  const DiscoverAvatar({
    super.key,
    required this.name,
    this.photoUrl,
    this.radius = 24,
    this.online = false,
  });

  final String name;
  final String? photoUrl;
  final double radius;
  final bool online;

  @override
  Widget build(BuildContext context) {
    final url = photoUrl;
    final image = (url != null && url.isNotEmpty)
        ? NetworkImage(url)
        : const AssetImage('assets/discover/default_avatar.png')
            as ImageProvider;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.all(2),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(colors: [DiscoverColors.neonPink, DiscoverColors.neonPurple]),
          ),
          child: CircleAvatar(
            radius: radius,
            backgroundColor: DiscoverColors.surfaceHigh,
            backgroundImage: image,
            onBackgroundImageError: (_, __) {},
          ),
        ),
        if (online)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: radius * 0.5,
              height: radius * 0.5,
              decoration: BoxDecoration(
                color: DiscoverColors.online,
                shape: BoxShape.circle,
                border: Border.all(color: DiscoverColors.bgBottom, width: 2),
              ),
            ),
          ),
      ],
    );
  }
}
