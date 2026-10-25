import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../core/country_data.dart';

class ProfileCompletionScreen extends StatefulWidget {
  const ProfileCompletionScreen({super.key, required this.onSave});

  final Future<void> Function({
    required String name,
    required String gender,
    required String country,
    required File? photo,
  })
  onSave;

  @override
  State<ProfileCompletionScreen> createState() =>
      _ProfileCompletionScreenState();
}

class _ProfileCompletionScreenState extends State<ProfileCompletionScreen> {
  static const _gold = Color(0xFFFFC629);
  static const _purple = Color(0xFF331862);

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _countrySearchController = TextEditingController();
  final _picker = ImagePicker();

  String? _gender;
  String? _country;
  File? _photo;
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _countrySearchController.dispose();
    super.dispose();
  }

  Future<void> _choosePhoto() async {
    try {
      final result = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 82,
        maxWidth: 1200,
      );
      if (result != null && mounted) {
        setState(() => _photo = File(result.path));
      }
    } catch (_) {
      if (mounted) {
        _message('Gallery open nahi ho paayi. Dobara try karein.');
      }
    }
  }

  Future<void> _chooseCountry() async {
    _countrySearchController.clear();
    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, refreshSheet) {
            final query = _countrySearchController.text.trim().toLowerCase();
            final filtered = oyarooCountries.where((country) {
              return country['name']!.toLowerCase().contains(query) ||
                  country['code']!.toLowerCase().contains(query);
            }).toList();

            return SafeArea(
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.72,
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Choose your country',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        controller: _countrySearchController,
                        onChanged: (_) => refreshSheet(() {}),
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.search),
                          hintText: 'Search country',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: filtered.isEmpty
                          ? const Center(child: Text('No country found'))
                          : ListView.builder(
                              itemCount: filtered.length,
                              itemBuilder: (_, index) {
                                final country = filtered[index];
                                return ListTile(
                                  leading: Text(
                                    country['flag']!,
                                    style: const TextStyle(fontSize: 24),
                                  ),
                                  title: Text(country['name']!),
                                  subtitle: Text(country['code']!),
                                  trailing: country['name'] == _country
                                      ? const Icon(Icons.check, color: _gold)
                                      : null,
                                  onTap: () => Navigator.pop(
                                    sheetContext,
                                    country['name'],
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (selected != null && mounted) {
      setState(() => _country = selected);
    }
  }

  void _message(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_gender == null || _country == null) {
      _message('Gender aur country select karna zaroori hai.');
      return;
    }

    setState(() => _saving = true);
    try {
      await widget.onSave(
        name: _nameController.text.trim(),
        gender: _gender!,
        country: _country!,
        photo: _photo!,
      );
    } catch (error) {
      if (mounted) {
        _message(
          'Profile save nahi hui. Internet aur permissions check karke retry karein.',
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF0),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 22, 24, 28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: _gold,
                        shape: BoxShape.circle,
                      ),
                      child: const Text(
                        'O',
                        style: TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.w900,
                          color: _purple,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Welcome to Oyaroo!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.w800,
                        color: _purple,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Apni profile complete karein aur doston se connect karein.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  Color(0xFFFF4DFF),
                                  Color(0xFFB388FF),
                                  _gold,
                                ],
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 57,
                              backgroundColor: _purple,
                              backgroundImage: _photo != null
                                  ? FileImage(_photo!)
                                  : const AssetImage(
                                      'assets/discover/default_avatar.png',
                                    ) as ImageProvider,
                            ),
                          ),
                          Material(
                            color: _gold,
                            shape: const CircleBorder(),
                            child: IconButton(
                              onPressed: _saving ? null : _choosePhoto,
                              tooltip: 'Choose profile photo',
                              icon: const Icon(
                                Icons.camera_alt,
                                color: _purple,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: _saving ? null : _choosePhoto,
                      icon: const Icon(Icons.photo_library_outlined),
                      label: const Text('Choose profile photo'),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _nameController,
                      maxLength: 30,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Your name *',
                        prefixIcon: Icon(Icons.person_outline),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        final name = value?.trim() ?? '';
                        if (name.isEmpty) return 'Name required hai';
                        if (name.length < 2) return 'Kam se kam 2 characters';
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: _gender,
                      decoration: const InputDecoration(
                        labelText: 'Gender *',
                        prefixIcon: Icon(Icons.people_outline),
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'Female',
                          child: Text('Female'),
                        ),
                        DropdownMenuItem(value: 'Male', child: Text('Male')),
                        DropdownMenuItem(value: 'Other', child: Text('Other')),
                        DropdownMenuItem(
                          value: 'Prefer not to say',
                          child: Text('Prefer not to say'),
                        ),
                      ],
                      onChanged: _saving
                          ? null
                          : (value) => setState(() => _gender = value),
                      validator: (value) =>
                          value == null ? 'Gender select karein' : null,
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: _saving ? null : _chooseCountry,
                      borderRadius: BorderRadius.circular(4),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Country *',
                          prefixIcon: Icon(Icons.public),
                          border: OutlineInputBorder(),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                _country == null
                                    ? 'Choose country flag'
                                    : (oyarooCountries.firstWhere(
                                            (country) =>
                                                country['name'] == _country,
                                            orElse: () => const {'flag': '🌍'},
                                          )['flag'] ??
                                          '🌍'),
                                style: TextStyle(
                                  color: _country == null
                                      ? Colors.grey.shade600
                                      : _purple,
                                ),
                              ),
                            ),
                            const Icon(Icons.arrow_drop_down),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 54,
                      child: FilledButton(
                        onPressed: _saving ? null : _submit,
                        style: FilledButton.styleFrom(
                          backgroundColor: _gold,
                          foregroundColor: _purple,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _saving
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Text(
                                'Save & Continue',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
