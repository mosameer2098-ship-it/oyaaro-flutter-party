import 'package:flutter/material.dart';
import 'package:oyaroo/handlers/profile_handler.dart';
import 'package:oyaroo/screens/dashboard_screen.dart';
import 'package:oyaroo/screens/me_screen.dart';
import 'package:oyaroo/screens/message_screen.dart';
import 'package:oyaroo/screens/room_screen.dart';
import 'package:oyaroo/features/discover/data/firestore_discover_repository.dart';
import 'package:oyaroo/features/discover/services/presence_heartbeat.dart';
import 'package:oyaroo/features/discover/ui/discover_page.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;
  late final PresenceHeartbeat _presence;

  @override
  void initState() {
    super.initState();
    _presence = PresenceHeartbeat();
    ProfileHandler().ensureUser().then((_) {
      if (mounted) _presence.start();
    }).catchError((Object error) {
      debugPrint('Oyaroo profile initialization failed: $error');
    });
  }

  void _openRoom(String id) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => RoomScreen(roomId: id)),
    );
  }

  @override
  void dispose() {
    _presence.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          const DashboardScreen(),
          const MessageScreen(),
          DiscoverPage(
            repository: FirestoreDiscoverRepository(),
            onJoinRoom: _openRoom,
          ),
          const MeScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble),
            label: 'Message',
          ),
          NavigationDestination(
            icon: Icon(Icons.travel_explore_outlined),
            selectedIcon: Icon(Icons.travel_explore),
            label: 'Discover',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Me',
          ),
        ],
      ),
    );
  }
}
