import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:oyaroo/screens/login_screen.dart';
import 'package:oyaroo/screens/main_shell.dart';
import 'package:oyaroo/screens/profile_completion_screen.dart';
import 'package:oyaroo/services/user_service.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnap) {
        if (authSnap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = authSnap.data;
        if (user == null) return const LoginScreen();

        return _AuthenticatedGate(key: ValueKey(user.uid), user: user);
      },
    );
  }
}

class _AuthenticatedGate extends StatefulWidget {
  const _AuthenticatedGate({super.key, required this.user});

  final User user;

  @override
  State<_AuthenticatedGate> createState() => _AuthenticatedGateState();
}

class _AuthenticatedGateState extends State<_AuthenticatedGate> {
  late Future<void> _initialization;

  @override
  void initState() {
    super.initState();
    _initialization = UserService.ensureUser();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initialization,
      builder: (context, initSnap) {
        if (initSnap.connectionState != ConnectionState.done) {
          return const _GateLoading();
        }
        if (initSnap.hasError) {
          return _GateError(
            message:
                'Account load nahi hua. Internet check karke retry karein.',
            onRetry: () => setState(() {
              _initialization = UserService.ensureUser();
            }),
          );
        }

        return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: UserService.profileStream(widget.user.uid),
          builder: (context, profileSnap) {
            if (profileSnap.connectionState == ConnectionState.waiting) {
              return const _GateLoading();
            }
            if (profileSnap.hasError) {
              return _GateError(
                message: 'Profile load nahi hui. Dobara try karein.',
                onRetry: () => setState(() {
                  _initialization = UserService.ensureUser();
                }),
              );
            }

            final data = profileSnap.data?.data() ?? <String, dynamic>{};
            final isNewIncomplete = data['profileCompleted'] == false;

            if (!isNewIncomplete) return const MainShell();

            return ProfileCompletionScreen(
              key: ValueKey('profile-${widget.user.uid}'),
              onSave:
                  ({
                    required name,
                    required gender,
                    required country,
                    required photo,
                  }) async {
                    await UserService.completeProfile(
                      name: name,
                      gender: gender,
                      country: country,
                      photo: photo,
                    );
                  },
            );
          },
        );
      },
    );
  }
}

class _GateLoading extends StatelessWidget {
  const _GateLoading();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

class _GateError extends StatelessWidget {
  const _GateError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(onPressed: onRetry, child: const Text('Retry')),
            ],
          ),
        ),
      ),
    );
  }
}
