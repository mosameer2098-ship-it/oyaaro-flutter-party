import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../shared/auto_advance_mixin.dart';
import '../models/home_models.dart';

/// Horizontal feature cards. Three cards are visible at once on a phone.
/// Auto-advances one card at a time and loops back to the start.
class FeatureCarousel extends StatefulWidget {
  const FeatureCarousel({
    super.key,
    required this.items,
    this.interval = const Duration(seconds: 3),
  });

  final List<FeatureItem> items;
  final Duration interval;

  @override
  State<FeatureCarousel> createState() => _FeatureCarouselState();
}

class _FeatureCarouselState extends State<FeatureCarousel>
    with WidgetsBindingObserver, AutoAdvanceMixin<FeatureCarousel> {
  static const double _edgePadding = 18;
  static const double _gap = 9;
  static const int _visibleCount = 3;
  static const _slideDuration = Duration(milliseconds: 600);

  final ScrollController _scroll = ScrollController();

  /// Card width for a viewport of [viewportWidth], so exactly three fit.
  static double _cardWidth(double viewportWidth) {
    return (viewportWidth - 2 * _edgePadding - _visibleCount * _gap) /
        _visibleCount;
  }

  @override
  Duration get autoAdvanceInterval => widget.interval;

  @override
  bool get canAutoAdvance => widget.items.length > _visibleCount;

  @override
  void advanceOnce() {
    if (!_scroll.hasClients) {
      return;
    }
    final position = _scroll.position;
    if (position.maxScrollExtent <= 0) {
      return;
    }
    if (position.pixels >= position.maxScrollExtent - 1) {
      _scroll.animateTo(
        0,
        duration: _slideDuration,
        curve: Curves.easeInOut,
      );
      return;
    }
    final stride = _cardWidth(position.viewportDimension) + _gap;
    _scroll.animateTo(
      math.min(position.pixels + stride, position.maxScrollExtent),
      duration: _slideDuration,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _scroll.dispose();
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

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 118,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cardWidth = _cardWidth(constraints.maxWidth);
          return NotificationListener<ScrollNotification>(
            onNotification: _onScroll,
            child: ListView.builder(
              controller: _scroll,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: _edgePadding,
                vertical: 9,
              ),
              itemCount: widget.items.length,
              itemBuilder: (context, index) => _FeatureCard(
                item: widget.items[index],
                width: cardWidth,
                gap: _gap,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.item,
    required this.width,
    required this.gap,
  });

  final FeatureItem item;
  final double width;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      margin: EdgeInsets.only(right: gap),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: item.color,
        borderRadius: BorderRadius.circular(27),
        boxShadow: [
          BoxShadow(
            color: item.color.withValues(alpha: 0.18),
            blurRadius: 9,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: 0,
            top: 1,
            child: Icon(
              item.icon,
              color: Colors.white.withValues(alpha: 0.53),
              size: 32,
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
