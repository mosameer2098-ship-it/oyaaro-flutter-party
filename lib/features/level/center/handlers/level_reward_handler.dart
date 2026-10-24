import 'package:cloud_functions/cloud_functions.dart';

import '../../../shared/feature_action.dart';
import '../logic/level_rules.dart';
import '../models/level_reward.dart';

/// Client pehle saaf wajah deta hai. Server (claimLevelMilestone) hi asli check karta hai.
class LevelRewardHandler {
  LevelRewardHandler({FirebaseFunctions? functions}) : _fn = functions ?? FirebaseFunctions.instance;

  final FirebaseFunctions _fn;

  Future<String?> claim(LevelReward reward, {required int current, required Set<String> claimed}) {
    final state = LevelRules.stateOf(reward: reward, current: current, claimed: claimed);
    if (state == RewardState.claimed) return Future.value('Ye reward pehle le chuke hain');
    if (state == RewardState.locked) return Future.value('Lv.${reward.level} par unlock hoga');
    return FeatureAction.run(() async {
      await _fn.httpsCallable('claimLevelMilestone').call(<String, dynamic>{
        'level': reward.level,
        'kind': reward.kind.name,
      });
    });
  }
}
