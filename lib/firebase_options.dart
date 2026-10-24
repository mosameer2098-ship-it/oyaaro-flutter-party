import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform => android;

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBsdcu82LLh--MaY7V4odEo8MHMou3zJSU',
    appId: '1:425159662668:android:ca8cef59920fe6c52868e9',
    messagingSenderId: '425159662668',
    projectId: 'oyaroo-live-2026',
    storageBucket: 'oyaroo-live-2026.firebasestorage.app',
  );
}
