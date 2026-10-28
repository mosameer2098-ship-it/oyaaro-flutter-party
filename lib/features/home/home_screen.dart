import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../rooms/room_detail_placeholder.dart';
import 'data/home_content.dart';
import 'models/home_models.dart';
import 'widgets/banner_carousel.dart';
import 'widgets/category_filter_bar.dart';
import 'widgets/feature_carousel.dart';
import 'widgets/room_card.dart';

/// Home dashboard, in this order: Mine/Popular tabs, banner carousel,
/// feature carousel, category filters, live-room grid.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  HomeTab _tab = HomeTab.popular;
  RoomCategory _category = RoomCategory.popular;

  /// Mine needs followed/joined rooms from the backend, which does not exist
  /// yet, so it is empty rather than showing Popular rooms.
  List<Room> get _visibleRooms {
    if (_tab == HomeTab.mine) {
      return const [];
    }
    return filterRooms(sampleRooms, _category);
  }

  void _openRoom(Room room) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => RoomDetailPlaceholder(room: room),
      ),
    );
  }

  void _showNotReady(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rooms = _visibleRooms;

    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _HomeHeader(
              tab: _tab,
              onTabSelected: (tab) => setState(() => _tab = tab),
              onSearch: () => _showNotReady('Search is not available yet.'),
              onNotifications: () =>
                  _showNotReady('Notifications are not available yet.'),
            ),
          ),
          const SliverToBoxAdapter(
            child: BannerCarousel(banners: sampleBanners),
          ),
          const SliverToBoxAdapter(
            child: FeatureCarousel(items: sampleFeatures),
          ),
          SliverToBoxAdapter(
            child: CategoryFilterBar(
              selected: _category,
              onSelected: (category) => setState(() => _category = category),
            ),
          ),
          if (_tab == HomeTab.mine)
            const SliverToBoxAdapter(
              child: _EmptyState(
                message: 'Rooms you follow or join will appear here.',
              ),
            )
          else if (rooms.isEmpty)
            const SliverToBoxAdapter(
              child: _EmptyState(
                message: 'No rooms in this category right now.',
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(18, 4, 18, 20),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final room = rooms[index];
                    return RoomCard(
                      key: ValueKey(room.id),
                      room: room,
                      onTap: () => _openRoom(room),
                    );
                  },
                  childCount: rooms.length,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 13,
                  childAspectRatio: 0.84,
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
        ],
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({
    required this.tab,
    required this.onTabSelected,
    required this.onSearch,
    required this.onNotifications,
  });

  final HomeTab tab;
  final ValueChanged<HomeTab> onTabSelected;
  final VoidCallback onSearch;
  final VoidCallback onNotifications;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 13, 22, 10),
      child: Row(
        children: [
          _TopTab(
            key: const ValueKey('home-tab-mine'),
            label: 'Mine',
            selected: tab == HomeTab.mine,
            onTap: () => onTabSelected(HomeTab.mine),
          ),
          const SizedBox(width: 34),
          _TopTab(
            key: const ValueKey('home-tab-popular'),
            label: 'Popular',
            selected: tab == HomeTab.popular,
            onTap: () => onTabSelected(HomeTab.popular),
          ),
          const Spacer(),
          IconButton(
            tooltip: 'Search',
            onPressed: onSearch,
            icon: const Icon(Icons.search_rounded, size: 27),
          ),
          IconButton(
            tooltip: 'Notifications',
            onPressed: onNotifications,
            icon: const Icon(Icons.notifications_none_rounded, size: 26),
          ),
        ],
      ),
    );
  }
}

class _TopTab extends StatelessWidget {
  const _TopTab({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: selected ? OyaaroColors.ink : OyaaroColors.tabInactive,
                  fontSize: 23,
                  fontWeight: selected ? FontWeight.w900 : FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: selected ? 39 : 0,
                height: 3,
                color: OyaaroColors.ink,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 36, 28, 36),
      child: Column(
        children: [
          const Icon(
            Icons.forum_outlined,
            size: 48,
            color: OyaaroColors.tabInactive,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: OyaaroColors.muted),
          ),
        ],
      ),
    );
  }
}
