import '../../shared/feature_action.dart';
import '../services/family_service.dart';

class FamilyHandler {
  FamilyHandler(this._service);

  final FamilyService _service;

  static const minNameLength = 3;
  static const maxNameLength = 20;
  static const maxMembers = 50;

  /// Client validation. Server bhi check karta hai.
  static String? validateName(String raw) {
    final n = raw.trim();
    if (n.length < minNameLength) return 'Family ka naam $minNameLength letters se bada ho';
    if (n.length > maxNameLength) return 'Family ka naam $maxNameLength letters se chhota ho';
    return null;
  }

  Future<String?> create(String rawName) {
    final v = validateName(rawName);
    if (v != null) return Future.value(v);
    return FeatureAction.run(() => _service.create(rawName.trim()));
  }

  Future<String?> join(String familyId) => FeatureAction.run(() => _service.join(familyId));

  Future<String?> leave() => FeatureAction.run(() => _service.leave());
}
