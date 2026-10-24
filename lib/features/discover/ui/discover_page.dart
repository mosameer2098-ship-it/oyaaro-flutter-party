import 'package:flutter/material.dart';

import '../demo/demo_discover_repository.dart';
import '../services/discover_repository.dart';
import '../state/discover_controller.dart';
import 'discover_theme.dart';
import 'tabs/people_tabs.dart';
import 'tabs/rooms_tab.dart';
import 'widgets/state_views.dart';

/// Discover & Friends ka main page.
/// [repository]: real Firestore impl ya host ka apna impl. Default demo nahi hai, zaroori hai.
/// [onJoinRoom]: host app ka room join flow (Zego wala) yahan call hota hai.
class DiscoverPage extends StatefulWidget {
  const DiscoverPage({
    super.key,
    required this.repository,
    required this.onJoinRoom,
    this.isDemo = false,
  });

  final DiscoverRepository repository;
  final void Function(String roomId) onJoinRoom;

  /// true = demo repository use ho raha hai, banner dikhega
  final bool isDemo;

  /// Preview ke liye demo page. Production mein use na karein.
  static Widget demo({required void Function(String roomId) onJoinRoom}) => DiscoverPage(
        repository: DemoDiscoverRepository(),
        onJoinRoom: onJoinRoom,
        isDemo: true,
      );

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  late final DiscoverController _controller;

  @override
  void initState() {
    super.initState();
    _controller = DiscoverController(widget.repository);
    _controller.loadOnline();
    _controller.watchFriends();
    _controller.watchRequests();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repo = widget.repository;
    return Theme(
      data: DiscoverTheme.apply(Theme.of(context)),
      child: DefaultTabController(
        length: 5,
        child: Container(
          decoration: const BoxDecoration(gradient: DiscoverTheme.backgroundGradient),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: const Text('Discover',
                  style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5)),
              bottom: const TabBar(
                isScrollable: true,
                indicatorColor: DiscoverColors.neonPink,
                labelColor: DiscoverColors.neonPink,
                unselectedLabelColor: DiscoverColors.textDim,
                tabs: [
                  Tab(text: 'Search'),
                  Tab(text: 'Online'),
                  Tab(text: 'Friends'),
                  Tab(text: 'Requests'),
                  Tab(text: 'Rooms'),
                ],
              ),
            ),
            body: Column(
              children: [
                if (widget.isDemo) const DemoBanner(),
                Expanded(
                  child: TabBarView(
                    children: [
                      SearchUsersTab(controller: _controller, repository: repo),
                      OnlineUsersTab(controller: _controller, repository: repo),
                      FriendsTab(controller: _controller, repository: repo),
                      RequestsTab(controller: _controller),
                      RoomsTab(controller: _controller, onJoinRoom: widget.onJoinRoom),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
