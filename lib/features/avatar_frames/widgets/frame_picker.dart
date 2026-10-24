import 'package:flutter/material.dart';

import '../catalog/frame_catalog.dart';
import '../models/frame_profile.dart';
import '../models/frame_spec.dart';
import '../services/frame_resolver.dart';
import 'avatar_with_frame.dart';

/// Frame picker grid. Static preview (reduceMotion) taaki scroll smooth rahe.
/// Locked frames grey dikhte hain. Tap par [onSelect] (frame id) jata hai.
class FramePicker extends StatelessWidget {
  const FramePicker({
    super.key,
    required this.profile,
    required this.avatar,
    required this.onSelect,
    this.frames,
  });

  final FrameProfile profile;
  final Widget avatar;
  final ValueChanged<String> onSelect;

  /// null = poori catalog. Host chahe to subset (jaise sirf owned) de sakta hai.
  final List<FrameSpec>? frames;

  @override
  Widget build(BuildContext context) {
    final list = frames ?? FrameCatalog.all;
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 110,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.75,
      ),
      itemCount: list.length,
      itemBuilder: (context, i) {
        final f = list[i];
        final allowed = FrameResolver.canEquip(profile, f.id);
        final selected = profile.equippedId == f.id;
        return InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: allowed ? () => onSelect(f.id) : null,
          child: Opacity(
            opacity: allowed ? 1 : 0.45,
            child: Column(
              children: [
                Expanded(
                  child: AvatarWithFrame(
                    frame: f,
                    radius: 22,
                    reduceMotion: true,
                    child: avatar,
                  ),
                ),
                Text(
                  selected ? '${f.name} ✓' : f.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
