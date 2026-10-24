import 'package:flutter_test/flutter_test.dart';

import '../../lib/features/themes/catalog/theme_catalog.dart';
import '../../lib/features/themes/models/theme_spec.dart';
import '../../lib/features/wheel/handlers/wheel_handler.dart';
import '../../lib/features/wheel/models/wheel_round.dart';
import '../../lib/features/pk/handlers/pk_handler.dart';
import '../../lib/features/family/handlers/family_handler.dart';
import '../../lib/features/music/models/music_track.dart';
import '../../lib/features/couple/models/couple_bond.dart';

void main() {
  test('theme catalog: 12 room + 12 couple, unique ids', () {
    expect(ThemeCatalog.room.length, 12);
    expect(ThemeCatalog.couple.length, 12);
    expect(ThemeCatalog.all.map((t) => t.id).toSet().length, 24);
    expect(ThemeCatalog.byId('couple_01')?.kind, ThemeKind.couple);
  });

  test('wheel bet: betting band ke bahar nahi lagega', () {
    final round = WheelRound(
      id: 'r1',
      bettingEndsAt: DateTime(2026, 1, 1, 10, 0, 45),
      settled: false,
      resultSegmentId: null,
    );
    final late = WheelHandler.validateBet(
      round: round,
      segmentId: 'apple',
      amount: 10,
      now: DateTime(2026, 1, 1, 10, 1),
    );
    expect(late, isNotNull);
    final ok = WheelHandler.validateBet(
      round: round,
      segmentId: 'apple',
      amount: 10,
      now: DateTime(2026, 1, 1, 10, 0, 10),
    );
    expect(ok, isNull);
  });

  test('PK: apne hi room se PK nahi, time sirf allowed', () {
    expect(PkHandler.validate(roomId: 'a', opponentRoomId: 'a', minutes: 5), isNotNull);
    expect(PkHandler.validate(roomId: 'a', opponentRoomId: 'b', minutes: 7), isNotNull);
    expect(PkHandler.validate(roomId: 'a', opponentRoomId: 'b', minutes: 5), isNull);
  });

  test('family naam validation', () {
    expect(FamilyHandler.validateName('ab'), isNotNull);
    expect(FamilyHandler.validateName('abc'), isNull);
    expect(FamilyHandler.validateName('a' * 21), isNotNull);
  });

  test('music: sirf https track valid', () {
    expect(MusicTrack.fromMap('1', {'url': 'http://x.mp3'}), isNull);
    expect(MusicTrack.fromMap('1', {'url': 'https://x.mp3', 'title': 'T'}), isNotNull);
  });

  test('couple bond: level aur title', () {
    final b = CoupleBond(convId: 'c', status: 'active', requestedBy: 'a', exp: 0, coupleThemeId: null);
    expect(b.level, 1);
    expect(b.title, CoupleBond.titles.first);
  });
}
