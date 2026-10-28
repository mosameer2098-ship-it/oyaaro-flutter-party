import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../../shared/auto_advance_mixin.dart';
import '../models/home_models.dart';

/// Auto-sliding banner carousel with swipe support and page indicators.
class BannerCarousel extends StatefulWidget {
  const BannerCarousel({
    super.key,
    required this.banners,
    this.interval = const Duration(seconds: 4),
    this.onPageChanged,
  });

  final List<HomeBanner> banners;
  final Duration interval;
  final ValueChanged<int>? onPageChanged;

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel>
    with WidgetsBindingObserver, AutoAdvanceMixin<BannerCarousel> {
  static const _viewportFraction = 0.93;
  static const _slideDuration = Duration(milliseconds: 500);

  late final PageController _controller = PageController(
    viewportFraction: _viewportFraction,
  );
  int _page = 0;

  @override
  Duration get autoAdvanceInterval => widget.interval;

  @override
  bool get canAutoAdvance => widget.banners.length > 1;

  @override
  void advanceOnce() {
    if (!_controller.hasClients) {
      return;
    }
    final next = (_page + 1) % widget.banners.length;
    if (next == 0) {
      _controller.jumpToPage(0);
    } else {
      _controller.animateToPage(
        next,
        duration: _slideDuration,
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _onScroll(ScrollNotification notification) {
    if (notification is ScrollStartNotification &&
        notification.dragDetails != null) {
      onUserDragStart();
    } else if (notification is ScrollEndNotification) {
      onUserDragEnd();
    }
    return false;
  }

  void _onPageChanged(int index) {
    setState(() => _page = index);
    widget.onPageChanged?.call(index);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 172,
          child: NotificationListener<ScrollNotification>(
            onNotification: _onScroll,
            child: PageView.builder(
              controller: _controller,
              itemCount: widget.banners.length,
              onPageChanged: _onPageChanged,
              itemBuilder: (context, index) => _BannerTile(
                banner: widget.banners[index],
              ),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.banners.length, (index) {
            final active = index == _page;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: active ? 16 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: active ? OyaaroColors.ink : OyaaroColors.dotInactive,
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
        const SizedBox(height: 4),
      ],
    );
  }
}

class _BannerTile extends StatelessWidget {
  const _BannerTile({required this.banner});

  final HomeBanner banner;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(5, 8, 5, 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(23),
        gradient: LinearGradient(
          colors: [banner.color, banner.color.withValues(alpha: 0.76)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: 4,
            bottom: 0,
            child: Icon(
              banner.icon,
              color: Colors.white.withValues(alpha: 0.19),
              size: 92,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'MEET  •  TALK  •  VIBE',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 10,
                  letterSpacing: 1.8,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                banner.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 23,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                banner.subtitle,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
