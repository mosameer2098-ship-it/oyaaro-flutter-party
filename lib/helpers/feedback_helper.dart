import 'package:flutter/material.dart';
import 'package:oyaroo/core/result.dart';
import 'package:oyaroo/core/ui.dart';
import 'package:oyaroo/helpers/error_helper.dart';

// Snackbar messages ka ek hi raasta
class FeedbackHelper {
  static void success(BuildContext context, String msg) => showMessage(context, msg);

  static void error(BuildContext context, Object e) =>
      showMessage(context, ErrorHelper.message(e));

  static void result<T>(BuildContext context, Result<T> r, {String? successMsg}) {
    if (r is Ok<T> && successMsg != null) {
      showMessage(context, successMsg);
    } else {
      showFailure(context, r);
    }
  }
}
