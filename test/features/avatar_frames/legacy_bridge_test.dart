import 'package:oyaroo/features/avatar_frames/services/legacy_frame_bridge.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../lib/features/avatar_frames/avatar_frames.dart';

void main() {
  test('purana frames list [1,2] owned bante hain aur equipped int mapped', () {
    final p = LegacyFrameBridge.profileFrom({
      'frames': [1, 2],
      'equippedFrame': 2,
      'vip': 0,
    });
    expect(p.owned, {LegacyFrameBridge.milestoneToFrameId(1), LegacyFrameBridge.milestoneToFrameId(2)});
    expect(p.equippedId, LegacyFrameBridge.milestoneToFrameId(2));
    expect(FrameResolver.resolve(p)?.id, LegacyFrameBridge.milestoneToFrameId(2));
  });

  test('naya ownedFrames string bhi kaam karta hai', () {
    final p = LegacyFrameBridge.profileFrom({'ownedFrames': ['std_0007'], 'equippedFrame': 'std_0007'});
    expect(FrameResolver.resolve(p)?.id, 'std_0007');
  });

  test('milestone ids 20 alag hain aur catalog mein exist karte hain', () {
    final ids = {for (var m = 1; m <= 20; m++) LegacyFrameBridge.milestoneToFrameId(m)};
    expect(ids.length, 20);
    for (final id in ids) {
      expect(FrameCatalog.byId(id), isNotNull);
    }
  });
}
