import 'package:flutter_test/flutter_test.dart';
import '../../../lib/features/avatar_frames/avatar_frames.dart';

void main() {
  test('standard frames exactly 1000 aur unique', () {
    expect(FrameCatalog.standardFrames.length, 1000);
    final ids = FrameCatalog.standardFrames.map((f) => f.id).toSet();
    expect(ids.length, 1000);
  });

  test('total frames: 5 role + 9 vip + 1000 standard', () {
    expect(FrameCatalog.roleFrames.length, 5);
    expect(FrameCatalog.vipFrames.length, 9);
    expect(FrameCatalog.all.length, 1014);
    expect(FrameCatalog.all.map((f) => f.id).toSet().length, FrameCatalog.all.length);
  });

  test('har standard frame ki parameter combination alag hai', () {
    final combos = FrameCatalog.standardFrames
        .map((f) => '${f.palette.name}-${f.wingStyle}-${f.crownStyle}-${f.gemStyle}')
        .toSet();
    expect(combos.length, 1000);
  });

  test('vipFrame level clamp karta hai', () {
    expect(FrameCatalog.vipFrame(0).id, 'vip_1');
    expect(FrameCatalog.vipFrame(99).id, 'vip_9');
  });
}
