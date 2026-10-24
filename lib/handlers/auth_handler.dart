import 'package:oyaroo/core/result.dart';
import 'package:oyaroo/services/auth_service.dart';

class AuthHandler {
  final _auth = AuthService();

  Future<Result<void>> google() => Result.guard(() => _auth.signInWithGoogle());

  Future<Result<void>> sendOtp(
    String phone, {
    required void Function(String verificationId) onCodeSent,
    required void Function(String message) onError,
  }) {
    if (!RegExp(r'^\+\d{10,15}$').hasMatch(phone)) {
      return Future<Result<void>>.value(
          const Err<void>('Phone +91... format mein daalein'));
    }
    return Result.guard(() => _auth.sendOtp(
          phone: phone,
          onCodeSent: onCodeSent,
          onError: (e) => onError(e.message ?? 'OTP error'),
        ));
  }

  Future<Result<void>> verifyOtp(String verificationId, String code) {
    if (code.trim().length != 6) {
      return Future<Result<void>>.value(
          const Err<void>('OTP 6 digit ka hona chahiye'));
    }
    return Result.guard(() => _auth.verifyOtp(verificationId, code.trim()));
  }

  Future<Result<void>> signOut() => Result.guard(() => _auth.signOut());
}
