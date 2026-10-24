import 'feature_exception.dart';

/// Handlers ka common pattern: action chalao. Error ho to message, warna null (success).
class FeatureAction {
  const FeatureAction._();

  static Future<String?> run(Future<void> Function() action) async {
    try {
      await action();
      return null;
    } on FeatureException catch (e) {
      return e.message;
    } catch (_) {
      return 'Kuch galat ho gaya. Dobara koshish karein';
    }
  }
}
