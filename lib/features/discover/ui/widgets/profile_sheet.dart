import 'package:flutter/material.dart';

import '../../models/discover_user.dart';
import '../../models/friend_request.dart';
import '../../services/discover_repository.dart';
import '../../state/discover_controller.dart';
import '../discover_theme.dart';
import 'badges.dart';
import 'user_avatar.dart';

/// User profile preview. Friend status aur follow state real repository se aata hai.
Future<void> showUserProfileSheet(
  BuildContext context, {
  required DiscoverUser user,
  required DiscoverRepository repository,
  required DiscoverController controller,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: DiscoverColors.bgTop,
    isScrollControlled: true,
    builder: (_) => _ProfileSheet(user: user, repository: repository, controller: controller),
  );
}

class _ProfileSheet extends StatefulWidget {
  const _ProfileSheet({required this.user, required this.repository, required this.controller});
  final DiscoverUser user;
  final DiscoverRepository repository;
  final DiscoverController controller;
  @override
  State<_ProfileSheet> createState() => _ProfileSheetState();
}

class _ProfileSheetState extends State<_ProfileSheet> {
  FriendshipStatus? _status;
  bool? _following;
  String? _error;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final s = await widget.repository.friendshipStatus(widget.user.uid);
      final f = await widget.repository.isFollowing(widget.user.uid);
      if (!mounted) return;
      setState(() {
        _status = s;
        _following = f;
        _error = null;
      });
    } on DiscoverException catch (e) {
      if (mounted) setState(() => _error = e.message);
    }
  }

  Future<void> _run(Future<String?> Function() action) async {
    setState(() => _busy = true);
    final err = await action();
    if (!mounted) return;
    setState(() => _busy = false);
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
    }
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final u = widget.user;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DiscoverAvatar(name: u.name, photoUrl: u.photoUrl, radius: 44,
                online: u.isOnline(DateTime.now())),
            const SizedBox(height: 12),
            Text(u.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('ID: ${u.shortId ?? '—'}', style: const TextStyle(color: DiscoverColors.textDim)),
            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              LevelBadge(level: u.level),
              const SizedBox(width: 6),
              VipBadge(vip: u.vip),
            ]),
            const SizedBox(height: 16),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: DiscoverColors.danger))
            else if (_status == null || _following == null)
              const CircularProgressIndicator(color: DiscoverColors.neonCyan)
            else
              _actions(),
          ],
        ),
      ),
    );
  }

  Widget _actions() {
    final uid = widget.user.uid;
    final buttons = <Widget>[];
    switch (_status!) {
      case FriendshipStatus.none:
        buttons.add(FilledButton.icon(
          onPressed: _busy ? null : () => _run(() => widget.controller.sendRequest(uid)),
          icon: const Icon(Icons.person_add_alt_1),
          label: const Text('Friend request bhejo'),
        ));
      case FriendshipStatus.outgoingPending:
        buttons.add(const Text('Request bheji ja chuki hai',
            style: TextStyle(color: DiscoverColors.textDim)));
      case FriendshipStatus.incomingPending:
        buttons.add(Row(children: [
          Expanded(child: FilledButton(
            onPressed: _busy ? null : () => _run(() => widget.controller.acceptRequest(uid)),
            child: const Text('Accept'),
          )),
          const SizedBox(width: 8),
          Expanded(child: OutlinedButton(
            onPressed: _busy ? null : () => _run(() => widget.controller.rejectRequest(uid)),
            child: const Text('Reject'),
          )),
        ]));
      case FriendshipStatus.friends:
        buttons.add(const Text('Aap dost hain', style: TextStyle(color: DiscoverColors.neonCyan)));
    }
    buttons.add(const SizedBox(height: 8));
    buttons.add(OutlinedButton.icon(
      onPressed: _busy
          ? null
          : () => _run(() => _following! ? widget.controller.unfollow(uid) : widget.controller.follow(uid)),
      icon: Icon(_following! ? Icons.person_remove_outlined : Icons.favorite_border),
      label: Text(_following! ? 'Unfollow' : 'Follow'),
    ));
    return Column(mainAxisSize: MainAxisSize.min, children: buttons);
  }
}
