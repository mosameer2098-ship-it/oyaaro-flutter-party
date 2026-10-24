import 'package:oyaroo/core/frames.dart';

class FrameHelper {
  static String nameOf(int milestone) => Frames.byMilestone(milestone).name;

  static bool isValid(int milestone) =>
      milestone >= 1 && milestone <= Frames.all.length;

  static bool owns(List<int> owned, int milestone) => owned.contains(milestone);
}
