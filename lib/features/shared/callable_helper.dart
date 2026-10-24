import 'package:cloud_functions/cloud_functions.dart';

import 'feature_exception.dart';

/// Sab server (Cloud Functions) calls yahin se. Error ko readable message mein badalta hai.
class CallableHelper {
  CallableHelper({FirebaseFunctions? functions})
      : _fn = functions ?? FirebaseFunctions.instance;

  final FirebaseFunctions _fn;

  Future<Map<String, dynamic>> call(String name, [Map<String, dynamic>? data]) async {
    try {
      final result = await _fn.httpsCallable(name).call(data ?? <String, dynamic>{});
      final v = result.data;
      return v is Map ? Map<String, dynamic>.from(v) : <String, dynamic>{};
    } on FirebaseFunctionsException catch (e) {
      throw FeatureException(e.message ?? 'Server par problem aayi');
    } catch (_) {
      throw const FeatureException('Kuch galat ho gaya. Dobara koshish karein');
    }
  }
}
