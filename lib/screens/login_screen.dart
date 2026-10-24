import 'package:flutter/material.dart';
import 'package:oyaroo/core/result.dart';
import 'package:oyaroo/core/ui.dart';
import 'package:oyaroo/handlers/auth_handler.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = AuthHandler();
  final _phone = TextEditingController();
  final _otp = TextEditingController();
  String? _verificationId;
  bool _busy = false;

  Future<void> _run(Future<Result<void>> Function() action) async {
    setState(() => _busy = true);
    final r = await action();
    if (!mounted) return;
    setState(() => _busy = false);
    showFailure(context, r);
  }

  Future<void> _sendOtp() => _run(() => _auth.sendOtp(
        _phone.text.trim(),
        onCodeSent: (id) => setState(() => _verificationId = id),
        onError: (msg) {
          if (mounted) showMessage(context, msg);
        },
      ));

  Future<void> _verify() {
    final id = _verificationId;
    if (id == null) return Future.value();
    return _run(() => _auth.verifyOtp(id, _otp.text));
  }

  @override
  void dispose() {
    _phone.dispose();
    _otp.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Oyaroo',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _busy ? null : () => _run(_auth.google),
              icon: const Icon(Icons.login),
              label: const Text('Google se login'),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Phone (+91...)'),
            ),
            const SizedBox(height: 8),
            if (_verificationId == null)
              ElevatedButton(
                  onPressed: _busy ? null : _sendOtp,
                  child: const Text('OTP bhejo'))
            else ...[
              TextField(
                controller: _otp,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'OTP'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                  onPressed: _busy ? null : _verify,
                  child: const Text('Verify karo')),
            ],
          ],
        ),
      ),
    );
  }
}
