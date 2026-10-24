import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;

  Future<void> signInWithGoogle() async {
    final google = GoogleSignIn.instance;
    await google.initialize();
    final account = await google.authenticate();
    final auth = account.authentication;
    final idToken = auth.idToken;
    if (idToken == null || idToken.isEmpty) {
      throw FirebaseAuthException(
        code: 'google-id-token-missing',
        message: 'Google sign-in se ID token nahi mila.',
      );
    }
    await _auth.signInWithCredential(
      GoogleAuthProvider.credential(idToken: idToken),
    );
  }

  Future<void> sendOtp({
    required String phone,
    required void Function(String verificationId) onCodeSent,
    required void Function(FirebaseAuthException e) onError,
  }) {
    return _auth.verifyPhoneNumber(
      phoneNumber: phone,
      verificationCompleted: (cred) async => _auth.signInWithCredential(cred),
      verificationFailed: onError,
      codeSent: (verificationId, _) => onCodeSent(verificationId),
      codeAutoRetrievalTimeout: (_) {},
    );
  }

  Future<void> verifyOtp(String verificationId, String code) {
    return _auth.signInWithCredential(PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: code,
    ));
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await GoogleSignIn.instance.signOut();
  }
}
