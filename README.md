# Oyaaro Party

Flutter/Dart social voice-party application.

## Current stage: Stage A (dashboard UI)

Implemented in the app, with widget and unit tests in `test/`:

- Bottom navigation with exactly three destinations: Home, Message, Profile. Rooms are opened from Home.
- Home dashboard in this order: Mine/Popular tabs, a 10-slide banner carousel that auto-slides and supports swiping, a 5-item feature carousel showing 3 cards at a time that auto-slides, category filters (Popular, Game, Video/Music) that filter the room grid, and a live-room card grid.
- Room card tap opens a room page. The room page does not join audio yet.
- Mine tab shows an empty state. It has no data source until the backend exists.
- Cream and yellow theme.

### Sample data

Banners, features, and rooms come from `lib/features/home/data/home_content.dart`. They are development samples: host names and listener counts are not real users or live rooms. Replace them with backend responses in a later stage.

### Not implemented yet

- Real backend data, authentication, profiles
- LiveKit voice rooms, seats, and joining audio
- Messages (placeholder page only), profile editing (placeholder page only)
- Search and notifications (buttons show "not available yet")
- Banner and feature taps do nothing. Banners and features are not links yet.
- Reference-screenshot pixel match: the reference image was not part of the uploaded repository, so the visual match is not verified.

## Running the checks

```bash
flutter pub get
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
```

CI runs these checks, then builds the ARM64 release APK. Download it from the workflow run's artifacts (`oyaaro-arm64-release-apk`). APK builds are not run locally.

## Planned stages

- Authentication and profile API
- LiveKit voice rooms and speaker seats
- Chat, gifts, coins and wallet
- VIP, rankings, families and moderation
- PHP/MySQL backend and admin panel

Features are not marked complete until implemented and tested.
