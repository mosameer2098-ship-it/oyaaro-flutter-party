import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:oyaroo/core/result.dart';
import 'package:oyaroo/core/ui.dart';
import 'package:oyaroo/handlers/profile_handler.dart';
import 'package:oyaroo/services/user_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _uid = FirebaseAuth.instance.currentUser!.uid;
  final _profile = ProfileHandler();
  final _name = TextEditingController();
  final _bio = TextEditingController();
  bool _filled = false;

  @override
  void dispose() {
    _name.dispose();
    _bio.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final r = await _profile.updateProfile(_name.text, _bio.text);
    if (!mounted) return;
    if (r is Ok<void>) {
      showMessage(context, 'Profile save ho gaya');
    } else {
      showFailure(context, r);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mera Profile')),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: UserService.profileStream(_uid),
        builder: (context, snap) {
          final data = snap.data?.data();
          if (data == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!_filled) {
            _name.text = '${data['name'] ?? ''}';
            _bio.text = '${data['bio'] ?? ''}';
            _filled = true;
          }
          return Padding(
            padding: const EdgeInsets.all(24),
            child: ListView(
              children: [
                const Center(
                    child: CircleAvatar(radius: 40, child: Icon(Icons.person, size: 40))),
                const SizedBox(height: 12),
                Center(
                  child: Text('Coins: ${data['coins'] ?? 0}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _name,
                  decoration: const InputDecoration(labelText: 'Naam'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _bio,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Bio'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(onPressed: _save, child: const Text('Save')),
              ],
            ),
          );
        },
      ),
    );
  }
}
