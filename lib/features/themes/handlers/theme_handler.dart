import '../../shared/feature_action.dart';
import '../catalog/theme_catalog.dart';
import '../models/theme_spec.dart';
import '../services/theme_service.dart';

class ThemeHandler {
  ThemeHandler(this._service);

  final ThemeService _service;

  /// Owned list mein hai to equip, nahi to buy. Null = success.
  Future<String?> buy(String themeId) {
    if (ThemeCatalog.byId(themeId) == null) return Future.value('Theme nahi mila');
    return FeatureAction.run(() => _service.buy(themeId));
  }

  Future<String?> equip(String themeId) {
    final t = ThemeCatalog.byId(themeId);
    if (t == null) return Future.value('Theme nahi mila');
    return FeatureAction.run(() => _service.equip(themeId, t.kind));
  }

  /// Owned check, pure function (test karna aasaan)
  static bool isOwned(List<String> owned, String themeId) => owned.contains(themeId);
}
