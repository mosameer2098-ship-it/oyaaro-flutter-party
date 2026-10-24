import 'package:flutter/material.dart';

import '../../models/discover_user.dart';
import '../../models/friend_request.dart';
import '../../models/load_state.dart';
import '../../services/discover_repository.dart';
import '../../state/discover_controller.dart';
import '../discover_theme.dart';
import '../widgets/profile_sheet.dart';
import '../widgets/state_views.dart';
import '../widgets/user_avatar.dart';
import '../widgets/user_tile.dart';

/// Search tab: username ya User ID se dhoondhna
class SearchUsersTab extends StatefulWidget {
  const SearchUsersTab({super.key, required this.controller, required this.repository});
  final DiscoverController controller;
  final DiscoverRepository repository;
  @override
  State<SearchUsersTab> createState() => _SearchUsersTabState();
}

class _SearchUsersTabState extends State<SearchUsersTab> {
  final _query = TextEditingController();

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            controller: _query,
            textInputAction: TextInputAction.search,
            onSubmitted: c.searchPeople,
            decoration: InputDecoration(
              hintText: 'Username ya User ID se dhoondhein',
              prefixIcon: const Icon(Icons.search, color: DiscoverColors.neonPurple),
              filled: true,
              fillColor: DiscoverColors.surface,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
        Expanded(
          child: ListenableBuilder(
            listenable: c,
            builder: (context, _) => switch (c.people) {
              LoadIdle() => const EmptyView(
                  message: 'Naam ya User ID type karke search karein',
                  icon: Icons.person_search_outlined),
              LoadLoading() => const LoadingView(),
              LoadError(:final message) => ErrorView(
                  message: message, onRetry: () => c.searchPeople(_query.text)),
              LoadData(:final value) when value.isEmpty => const EmptyView(
                  message: 'Koi user nahi mila', icon: Icons.person_off_outlined),
              LoadData(:final value) => ListView(
                  children: [
                    for (final u in value)
                      UserTile(
                        user: u,
                        onTap: () => showUserProfileSheet(context,
                            user: u, repository: widget.repository, controller: c),
                      ),
                  ],
                ),
            },
          ),
        ),
      ],
    );
  }
}

/// Online tab: sirf heartbeat wale users
class OnlineUsersTab extends StatelessWidget {
  const OnlineUsersTab({super.key, required this.controller, required this.repository});
  final DiscoverController controller;
  final DiscoverRepository repository;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: controller,
        builder: (context, _) => switch (controller.online) {
          LoadIdle() => _kick(),
          LoadLoading() => const LoadingView(),
          LoadError(:final message) => ErrorView(message: message, onRetry: controller.loadOnline),
          LoadData(:final value) when value.isEmpty => const EmptyView(
              message: 'Abhi koi online user nahi hai', icon: Icons.wifi_off),
          LoadData(:final value) => RefreshIndicator(
              onRefresh: controller.loadOnline,
              child: ListView(
                children: [
                  for (final u in value)
                    UserTile(
                      user: u,
                      onTap: () => showUserProfileSheet(context,
                          user: u, repository: repository, controller: controller),
                    ),
                ],
              ),
            ),
        },
      );

  Widget _kick() {
    WidgetsBinding.instance.addPostFrameCallback((_) => controller.loadOnline());
    return const LoadingView();
  }
}

/// Friends tab: friend list + follow/unfollow profile se
class FriendsTab extends StatelessWidget {
  const FriendsTab({super.key, required this.controller, required this.repository});
  final DiscoverController controller;
  final DiscoverRepository repository;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: controller,
        builder: (context, _) => switch (controller.friends) {
          LoadIdle() || LoadLoading() => const LoadingView(),
          LoadError(:final message) => ErrorView(message: message, onRetry: controller.refreshLive),
          LoadData(:final value) when value.isEmpty => const EmptyView(
              message: 'Abhi koi dost nahi. Search se friend request bhejein',
              icon: Icons.group_outlined),
          LoadData(:final value) => ListView(
              children: [
                for (final u in value)
                  UserTile(
                    user: u,
                    onTap: () => showUserProfileSheet(context,
                        user: u, repository: repository, controller: controller),
                  ),
              ],
            ),
        },
      );
}

/// Requests tab: incoming requests, accept / reject
class RequestsTab extends StatelessWidget {
  const RequestsTab({super.key, required this.controller});
  final DiscoverController controller;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: controller,
        builder: (context, _) => switch (controller.requests) {
          LoadIdle() || LoadLoading() => const LoadingView(),
          LoadError(:final message) => ErrorView(message: message, onRetry: controller.refreshLive),
          LoadData(:final value) when value.isEmpty => const EmptyView(
              message: 'Koi pending request nahi hai', icon: Icons.mark_email_read_outlined),
          LoadData(:final value) => ListView(
              children: [for (final r in value) _RequestTile(request: r, controller: controller)],
            ),
        },
      );
}

class _RequestTile extends StatelessWidget {
  const _RequestTile({required this.request, required this.controller});
  final FriendRequest request;
  final DiscoverController controller;

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: DiscoverTheme.card(),
        child: ListTile(
          leading: DiscoverAvatar(name: request.fromName, radius: 20),
          title: Text(request.fromName),
          subtitle: const Text('Dost banana chahte hain', style: TextStyle(color: DiscoverColors.textDim)),
          trailing: Wrap(spacing: 6, children: [
            FilledButton(
              onPressed: () async {
                final err = await controller.acceptRequest(request.fromUid);
                if (context.mounted && err != null) _show(context, err);
              },
              child: const Text('Accept'),
            ),
            OutlinedButton(
              onPressed: () async {
                final err = await controller.rejectRequest(request.fromUid);
                if (context.mounted && err != null) _show(context, err);
              },
              child: const Text('Reject'),
            ),
          ]),
        ),
      );

  void _show(BuildContext context, String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
}
