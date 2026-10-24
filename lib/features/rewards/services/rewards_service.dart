import '../../shared/callable_helper.dart';

/// Milestone claim server par hota hai (coins aur frame server likhta hai).
class RewardsService {
  RewardsService({CallableHelper? callable}) : _call = callable ?? CallableHelper();

  final CallableHelper _call;

  Future<void> claim(int milestoneIndex) async {
    await _call.call('claimLevelMilestone', {'index': milestoneIndex});
  }
}
