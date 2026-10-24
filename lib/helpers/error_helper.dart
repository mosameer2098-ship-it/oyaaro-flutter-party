import 'package:oyaroo/core/app_error.dart';

// Kisi bhi error ko user-friendly text banata hai
class ErrorHelper {
  static String message(Object e) => friendlyMessage(e);
}
