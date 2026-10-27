import 'package:flutter/material.dart';

void main() {
  runApp(const OyaaroApp());
}

const Color pageColor = Color(0xFF100D1D);
const Color cardColor = Color(0xFF211A35);
const Color accentColor = Color(0xFFB66DFF);
const Color pinkColor = Color(0xFFFF65B8);

class OyaaroApp extends StatelessWidget {
  const OyaaroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Oyaaro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: pageColor,
        colorScheme: ColorScheme.fromSeed(
          seedColor: accentColor,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const MainNavigation(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int selectedIndex = 0;

  final List<Widget> screens = const [
    HomeScreen(),
    MessagesScreen(),
    RoomsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: selectedIndex, children: screens),
      bottomNavigationBar: NavigationBar(
        backgroundColor: const Color(0xFF191326),
        indicatorColor: accentColor.withValues(alpha: 0.22),
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() => selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline_rounded),
            selectedIcon: Icon(Icons.chat_bubble_rounded),
            label: 'Messages',
          ),
          NavigationDestination(
            icon: Icon(Icons.graphic_eq_rounded),
            selectedIcon: Icon(Icons.multitrack_audio_rounded),
            label: 'Rooms',
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

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: const LinearGradient(
                        colors: [accentColor, pinkColor],
                      ),
                    ),
                    child: const Icon(
                      Icons.graphic_eq_rounded,
                      color: Colors.white,
                      size: 29,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Oyaaro',
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.4,
                          ),
                        ),
                        Text(
                          'Your people. Your vibe.',
                          style: TextStyle(
                            color: Colors.white60,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => _showNotice(context, 'Notifications'),
                    icon: const Icon(Icons.notifications_none_rounded),
                  ),
                  IconButton(
                    onPressed: () => _showNotice(context, 'Search'),
                    icon: const Icon(Icons.search_rounded),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Container(
                height: 158,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF6739A8),
                      Color(0xFF35205E),
                      Color(0xFF251833),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    const Positioned(
                      right: 4,
                      top: 8,
                      child: Icon(
                        Icons.spatial_audio_off_rounded,
                        size: 90,
                        color: Colors.white12,
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'MEET • TALK • VIBE',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Your next favourite\nconversation starts here.',
                          style: TextStyle(
                            fontSize: 19,
                            height: 1.25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        FilledButton(
                          onPressed: () => _showNotice(
                            context,
                            'Voice rooms will be enabled in Phase 3.',
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF43206E),
                            minimumSize: const Size(110, 34),
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                          ),
                          child: const Text('Explore rooms'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 25, 20, 13),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Discover',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    'Made for your vibe',
                    style: TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            sliver: SliverGrid(
              delegate: SliverChildListDelegate([
                _CategoryCard(
                  title: 'Music Lounge',
                  subtitle: 'Songs & chill',
                  icon: Icons.music_note_rounded,
                  color: const Color(0xFF6B4CE6),
                ),
                _CategoryCard(
                  title: 'New Friends',
                  subtitle: 'Meet people',
                  icon: Icons.people_alt_rounded,
                  color: const Color(0xFFDB579E),
                ),
                _CategoryCard(
                  title: 'Fun & Games',
                  subtitle: 'Play together',
                  icon: Icons.sports_esports_rounded,
                  color: const Color(0xFFDF8742),
                ),
                _CategoryCard(
                  title: 'Late Night',
                  subtitle: 'Talk freely',
                  icon: Icons.nightlight_round,
                  color: const Color(0xFF418FCB),
                ),
              ]),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.48,
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 25, 20, 12),
              child: Text(
                'Popular rooms',
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              const _RoomPreview(
                name: 'Midnight Vibes ✨',
                host: 'Hosted by Aanya',
                people: '12 listening',
                icon: Icons.nightlife_rounded,
                color: Color(0xFF50378B),
              ),
              const _RoomPreview(
                name: 'Friends & Fun 🎉',
                host: 'Hosted by Arjun',
                people: '8 listening',
                icon: Icons.celebration_rounded,
                color: Color(0xFF863D72),
              ),
              const _RoomPreview(
                name: 'Music Addicts 🎵',
                host: 'Hosted by Riya',
                people: '6 listening',
                icon: Icons.headphones_rounded,
                color: Color(0xFF305B83),
              ),
              const SizedBox(height: 18),
            ]),
          ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 39,
            height: 39,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: color, size: 23),
          ),
          const Spacer(),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.white54, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _RoomPreview extends StatelessWidget {
  const _RoomPreview({
    required this.name,
    required this.host,
    required this.people,
    required this.icon,
    required this.color,
  });

  final String name;
  final String host;
  final String people;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(18, 0, 18, 11),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(19),
      ),
      child: Row(
        children: [
          Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, size: 28, color: Colors.white),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                Text(
                  host,
                  style: const TextStyle(color: Colors.white60, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.headphones, size: 13, color: accentColor),
                    const SizedBox(width: 4),
                    Text(
                      people,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: Colors.white54),
        ],
      ),
    );
  }
}

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _SimpleScreen(
      icon: Icons.chat_bubble_outline_rounded,
      title: 'Messages',
      subtitle: 'Your conversations will appear here.',
      note: 'Private messaging will be implemented in a later phase.',
    );
  }
}

class RoomsScreen extends StatelessWidget {
  const RoomsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _SimpleScreen(
      icon: Icons.graphic_eq_rounded,
      title: 'Voice Rooms',
      subtitle: 'Find your people and join the conversation.',
      note: 'Live voice, speaker seats and room controls are planned for Phase 3.',
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _SimpleScreen(
      icon: Icons.account_circle_outlined,
      title: 'Your Profile',
      subtitle: 'Your Oyaaro journey starts here.',
      note: 'Login, profile editing and account settings are planned for Phase 2.',
    );
  }
}

class _SimpleScreen extends StatelessWidget {
  const _SimpleScreen({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.note,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String note;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 43, color: accentColor),
              ),
              const SizedBox(height: 22),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 9),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 16),
              Text(
                note,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white38, height: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void _showNotice(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
      backgroundColor: const Color(0xFF493166),
    ),
  );
}
