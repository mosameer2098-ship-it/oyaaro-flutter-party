import 'package:flutter/material.dart';

import '../../models/discover_user.dart';
import '../discover_theme.dart';
import 'badges.dart';
import 'user_avatar.dart';

class UserTile extends StatelessWidget {
  const UserTile({super.key, required this.user, this.trailing, this.onTap});

  final DiscoverUser user;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final online = user.isOnline(DateTime.now());
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: DiscoverTheme.card(),
      child: ListTile(
        onTap: onTap,
        leading: DiscoverAvatar(name: user.name, photoUrl: user.photoUrl, online: online),
        title: Row(
          children: [
            Flexible(child: Text(user.name, overflow: TextOverflow.ellipsis)),
            const SizedBox(width: 6),
            LevelBadge(level: user.level),
            const SizedBox(width: 4),
            VipBadge(vip: user.vip),
          ],
        ),
        subtitle: Text(
          user.shortId == null ? 'ID: —' : 'ID: ${user.shortId}',
          style: const TextStyle(color: DiscoverColors.textDim),
        ),
        trailing: trailing,
      ),
    );
  }
}
