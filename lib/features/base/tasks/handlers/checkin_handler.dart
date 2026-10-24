import '../../../shared/feature_action.dart';
import '../models/checkin_result.dart';
import '../services/checkin_service.dart';

class CheckInHandler {
  CheckInHandler(this._service);

  final CheckInService _service;

  /// Null = success. Result UI ke liye alag se milta hai.
  Future<String?> run(void Function(CheckInResult) onOk) {
    return FeatureAction.run(() async {
      final r = await _service.checkIn();
      onOk(r);
    });
  }
}
