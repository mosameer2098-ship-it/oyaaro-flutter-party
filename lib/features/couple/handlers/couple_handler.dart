import '../../shared/feature_action.dart';
import '../models/couple_bond.dart';
import '../services/couple_service.dart';

class CoupleHandler {
  CoupleHandler(this._service);

  final CoupleService _service;

  /// Request sirf tab jab bond none ho
  Future<String?> request(CoupleBond bond) {
    if (bond.isActive) return Future.value('CP already lagi hai');
    if (bond.isPending) return Future.value('Request pehle se pending hai');
    return FeatureAction.run(() => _service.request(bond.convId));
  }

  /// Accept sirf wo kar sakta hai jisne request nahi bheji
  Future<String?> accept(CoupleBond bond, String myUid) {
    if (!bond.isPending) return Future.value('Koi pending request nahi hai');
    if (bond.requestedBy == myUid) return Future.value('Request aapne bheji hai');
    return FeatureAction.run(() => _service.accept(bond.convId));
  }

  Future<String?> setTheme(String convId, String themeId) =>
      FeatureAction.run(() => _service.setCoupleTheme(convId, themeId));
}
