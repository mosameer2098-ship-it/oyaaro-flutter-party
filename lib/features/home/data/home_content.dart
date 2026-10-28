import 'package:flutter/material.dart';

import '../models/home_models.dart';

/// Development sample content. It is not real users or live rooms.
/// Replace with backend responses once the API stage is built.
const sampleBanners = <HomeBanner>[
  HomeBanner(
    title: 'VIP Exclusive Benefits',
    subtitle: 'More privileges • More fun',
    color: Color(0xFF592D83),
    icon: Icons.workspace_premium_rounded,
  ),
  HomeBanner(
    title: 'Meet Your People',
    subtitle: 'Make friends around the world',
    color: Color(0xFFB84E85),
  ),
  HomeBanner(
    title: 'Live Music Lounge',
    subtitle: 'Listen, talk and chill together',
    color: Color(0xFFDA8C36),
  ),
  HomeBanner(
    title: 'Find Your Vibe',
    subtitle: 'Your next conversation awaits',
    color: Color(0xFF398D86),
  ),
  HomeBanner(
    title: 'Daily Room Party',
    subtitle: 'Join the fun happening now',
    color: Color(0xFF5365B4),
  ),
  HomeBanner(
    title: 'New Friends Today',
    subtitle: 'Say hello to someone new',
    color: Color(0xFFB96852),
  ),
  HomeBanner(
    title: 'Family Time',
    subtitle: 'Build your own community',
    color: Color(0xFF397C9A),
  ),
  HomeBanner(
    title: 'Game Lounge',
    subtitle: 'Play and laugh together',
    color: Color(0xFF9D5A9C),
  ),
  HomeBanner(
    title: 'Top Hosts',
    subtitle: 'Discover popular voices',
    color: Color(0xFF84652B),
  ),
  HomeBanner(
    title: 'Your Voice Matters',
    subtitle: 'Come join the conversation',
    color: Color(0xFF5E4D9A),
  ),
];

const sampleFeatures = <FeatureItem>[
  FeatureItem(
    label: 'Ranking',
    caption: 'Top rooms',
    icon: Icons.emoji_events_rounded,
    color: Color(0xFFFFBD45),
  ),
  FeatureItem(
    label: 'CP',
    caption: 'Couples',
    icon: Icons.favorite_rounded,
    color: Color(0xFFE991BC),
  ),
  FeatureItem(
    label: 'Family',
    caption: 'Communities',
    icon: Icons.groups_rounded,
    color: Color(0xFF76CDBA),
  ),
  FeatureItem(
    label: 'Party',
    caption: 'Party rooms',
    icon: Icons.celebration_rounded,
    color: Color(0xFF91B5ED),
  ),
  FeatureItem(
    label: 'Stars',
    caption: 'Rising voices',
    icon: Icons.auto_awesome_rounded,
    color: Color(0xFFC5A0EB),
  ),
];

const sampleRooms = <Room>[
  Room(
    id: 'midnight-vibes',
    name: 'Midnight Vibes',
    hostName: 'Aanya',
    listeners: 12,
    category: RoomCategory.popular,
    color: Color(0xFF58318B),
    language: 'Hindi',
    isLive: true,
  ),
  Room(
    id: 'friends-fun',
    name: 'Friends & Fun',
    hostName: 'Arjun',
    listeners: 8,
    category: RoomCategory.popular,
    color: Color(0xFFBD6794),
    language: 'English',
    isLive: true,
  ),
  Room(
    id: 'music-addicts',
    name: 'Music Addicts',
    hostName: 'Riya',
    listeners: 16,
    category: RoomCategory.videoMusic,
    color: Color(0xFF417D99),
    language: 'Hindi',
    isLive: true,
  ),
  Room(
    id: 'game-night',
    name: 'Game Night',
    hostName: 'Sam',
    listeners: 6,
    category: RoomCategory.game,
    color: Color(0xFFD18B45),
    language: 'English',
    isLive: true,
  ),
  Room(
    id: 'chill-corner',
    name: 'Chill Corner',
    hostName: 'Zara',
    listeners: 9,
    category: RoomCategory.popular,
    color: Color(0xFF548C79),
    language: 'English',
    isLive: true,
  ),
  Room(
    id: 'late-night-talk',
    name: 'Late Night Talk',
    hostName: 'Aadi',
    listeners: 4,
    category: RoomCategory.popular,
    color: Color(0xFF7760A6),
    language: 'Hindi',
    isLive: true,
  ),
];
