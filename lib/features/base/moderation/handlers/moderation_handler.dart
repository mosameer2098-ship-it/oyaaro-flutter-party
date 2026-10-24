import '../../../shared/feature_action.dart';
import '../models/report.dart';
import '../services/moderation_service.dart';

class ModerationHandler {
  ModerationHandler(this._service);

  final ModerationService _service;

  static const minDetailLength = 3;

  static String? validate({
    required String targetUid,
    required String myUid,
    required ReportReason reason,
    String details = '',
  }) {
    if (targetUid.trim().isEmpty) return 'Target user zaroori hai';
    if (targetUid.trim() == myUid.trim()) {
      return 'Khud ko report nahi kar sakte';
    }
    if (reason == ReportReason.other &&
        details.trim().length < minDetailLength) {
      return 'Thoda detail likhein';
    }
    return null;
  }

  Future<String?> report({
    required String targetUid,
    required String myUid,
    required ReportReason reason,
    String details = '',
    String? roomId,
  }) {
    if (targetUid == myUid) return Future.value('Khud ko report nahi kar sakte');
    final text = reason == ReportReason.other ? details.trim() : reason.label;
    if (text.length < minDetailLength) return Future.value('Thoda detail likhein');
    return FeatureAction.run(() => _service.report(
          targetUid: targetUid,
          reason: text,
          roomId: roomId,
        ));
  }
}
