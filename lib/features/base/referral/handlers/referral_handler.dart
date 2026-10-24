import '../../../shared/feature_action.dart';
import '../services/referral_service.dart';

class ReferralHandler {
  ReferralHandler(this._service);

  final ReferralService _service;

  static final _pattern = RegExp(r'^[A-Z2-9]{8}$');

  static String? validateCode(String raw) {
    final c = raw.trim().toUpperCase();
    if (!_pattern.hasMatch(c)) return 'Code 8 characters ka hona chahiye';
    return null;
  }

  Future<String?> redeem(String raw) {
    final v = validateCode(raw);
    if (v != null) return Future.value(v);
    return FeatureAction.run(() async {
      await _service.redeem(raw.trim().toUpperCase());
    });
  }
}
