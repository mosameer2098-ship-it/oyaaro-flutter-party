import '../../shared/feature_action.dart';
import '../models/level_milestone.dart';
import '../services/rewards_service.dart';

class RewardsHandler {
  RewardsHandler(this._service);

  final RewardsService _service;

  /// Null = success, warna error message
  Future<String?> claim(LevelMilestone m) {
    if (!m.reached) return Future.value('Level ${m.level} tak pahunchna hoga');
    if (m.claimed) return Future.value('Ye reward aap le chuke hain');
    return FeatureAction.run(() => _service.claim(m.index));
  }
}
