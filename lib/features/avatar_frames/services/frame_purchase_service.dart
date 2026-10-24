import 'package:cloud_functions/cloud_functions.dart';

import 'frame_repository.dart';

/// Standard frame khareedna. Coins ka kaatna server (buyFrame callable) par hota hai.
/// Client sirf call karta hai, koi coin client se nahi badalta.
class FramePurchaseService {
  FramePurchaseService({FirebaseFunctions? functions})
      : _fn = functions ?? FirebaseFunctions.instance;

  final FirebaseFunctions _fn;

  Future<void> buy(String frameId) async {
    try {
      await _fn.httpsCallable('buyFrame').call({'frameId': frameId});
    } on FirebaseFunctionsException catch (e) {
      throw FrameException(e.message ?? 'Frame khareed nahi ja saka');
    }
  }
}
