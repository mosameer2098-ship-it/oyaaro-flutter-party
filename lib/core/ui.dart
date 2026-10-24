import 'package:flutter/material.dart';
import 'result.dart';

void showMessage(BuildContext context, String msg) {
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
}

// Result agar Err hai to message dikhata hai
void showFailure<T>(BuildContext context, Result<T> r) {
  if (r is Err<T>) showMessage(context, r.message);
}

// Action chalata hai aur result ke hisaab se message dikhata hai
Future<void> reportResult(BuildContext context, Future<Result<void>> action,
    {String? successMsg}) async {
  final r = await action;
  if (!context.mounted) return;
  if (r is Ok<void> && successMsg != null) {
    showMessage(context, successMsg);
  } else {
    showFailure(context, r);
  }
}
