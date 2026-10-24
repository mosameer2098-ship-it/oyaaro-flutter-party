import '../../shared/callable_helper.dart';
import '../models/theme_spec.dart';

/// Theme khareedna aur equip karna server par. Owned list users doc mein hoti hai.
class ThemeService {
  ThemeService({CallableHelper? callable}) : _call = callable ?? CallableHelper();

  final CallableHelper _call;

  Future<void> buy(String themeId) async {
    await _call.call('buyTheme', {'themeId': themeId});
  }

  Future<void> equip(String themeId, ThemeKind kind) async {
    await _call.call('equipTheme', {
      'themeId': themeId,
      'kind': kind.name, // 'room' | 'couple'
    });
  }
}
