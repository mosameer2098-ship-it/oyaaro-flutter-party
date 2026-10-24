import '../../../shared/callable_helper.dart';

class ModerationService {
  ModerationService({CallableHelper? callable}) : _call = callable ?? CallableHelper();

  final CallableHelper _call;

  Future<void> report({
    required String targetUid,
    required String reason,
    String? roomId,
  }) async {
    await _call.call('reportUser', {
      'targetUid': targetUid,
      'reason': reason,
      if (roomId != null) 'roomId': roomId,
    });
  }

  /// Admin only. action: dismiss | mute | ban
  Future<void> resolve(String reportId, String action, {int? minutes}) async {
    await _call.call('resolveReport', {
      'reportId': reportId,
      'action': action,
      if (minutes != null) 'minutes': minutes,
    });
  }
}
