import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'screens/auth_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const OyarooApp());
}

class OyarooApp extends StatelessWidget {
  const OyarooApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Oyaroo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFFC629),
          brightness: Brightness.light,
        ),
      ),
      home: const AuthGate(),
    );
  }
}
