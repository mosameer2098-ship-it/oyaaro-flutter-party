import 'package:flutter/material.dart';

import '../features/home/home_screen.dart';
import '../shared/placeholder_page.dart';
import 'theme.dart';

/// Exactly three destinations: Home, Message, Profile.
/// Rooms are entered from the Home dashboard, not from a tab.
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: const [
          HomeScreen(),
          PlaceholderPage(
            icon: Icons.chat_bubble_outline_rounded,
            title: 'Messages',
            message: 'Conversations arrive in a later stage.',
          ),
          PlaceholderPage(
            icon: Icons.person_outline_rounded,
            title: 'My Profile',
            message: 'Profile editing arrives in a later stage.',
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        height: 72,
        backgroundColor: OyaaroColors.navBackground,
        indicatorColor: OyaaroColors.navIndicator,
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline_rounded),
            selectedIcon: Icon(Icons.chat_bubble_rounded),
            label: 'Message',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
