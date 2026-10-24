import 'package:flutter/material.dart';

import '../../models/discover_room.dart';
import '../../models/discover_user.dart';
import '../../services/discover_repository.dart';
import '../../state/discover_controller.dart';
import '../discover_theme.dart';
import 'state_views.dart';
import 'user_avatar.dart';

/// Room mein dost ko invite karne ki sheet. Sirf real friends list.
Future<void> showInviteSheet(
  BuildContext context, {
  required DiscoverRoom room,
  required DiscoverRepository repository,
  required DiscoverController controller,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: DiscoverColors.bgTop,
    isScrollControlled: true,
    builder: (_) => SizedBox(
      height: MediaQuery.of(context).size.height * 0.6,
      child: _InviteList(room: room, repository: repository, controller: controller),
    ),
  );
}

class _InviteList extends StatefulWidget {
  const _InviteList({required this.room, required this.repository, required this.controller});
  final DiscoverRoom room;
  final DiscoverRepository repository;
  final DiscoverController controller;
  @override
  State<_InviteList> createState() => _InviteListState();
}

class _InviteListState extends State<_InviteList> {
  late Future<List<DiscoverUser>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<DiscoverUser>> _load() => widget.repository.friends().first;

  void _retry() => setState(() => _future = _load());

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Invite to ${widget.room.name}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        Expanded(
          child: FutureBuilder<List<DiscoverUser>>(
            future: _future,
            builder: (context, snap) {
              if (snap.connectionState != ConnectionState.done) return const LoadingView();
              if (snap.hasError) {
                final e = snap.error;
                return ErrorView(
                  message: e is DiscoverException ? e.message : 'Friends load nahi ho sake',
                  onRetry: _retry,
                );
              }
              final list = snap.data ?? const [];
              if (list.isEmpty) {
                return const EmptyView(message: 'Abhi koi dost nahi hai. Pehle friend banayein.',
                    icon: Icons.group_outlined);
              }
              return ListView(
                children: [
                  for (final u in list)
                    ListTile(
                      leading: DiscoverAvatar(name: u.name, photoUrl: u.photoUrl, radius: 20),
                      title: Text(u.name),
                      trailing: FilledButton(
                        onPressed: () async {
                          final err = await widget.controller.invite(u.uid, widget.room);
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(err ?? '${u.name} ko invite bhej diya'),
                          ));
                        },
                        child: const Text('Invite'),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
