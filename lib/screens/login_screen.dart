import 'package:flutter/material.dart';
import 'package:oyaroo/core/result.dart';
import 'package:oyaroo/core/ui.dart';
import 'package:oyaroo/handlers/auth_handler.dart';

import '../core/country_data.dart';

const _cream = Color(0xFFFFF8EF);
const _gold = Color(0xFFD9A52E);
const _darkGold = Color(0xFF795515);
const _ink = Color(0xFF302014);

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
  bool _agreedToTerms = false;
  String _countryCode = '+91';
  String _countryFlag = '🇮🇳';

  Future<void> _run(Future<Result<void>> Function() action) async {
    setState(() => _busy = true);
    try {
      final r = await action();
      if (!mounted) return;
      showFailure(context, r);
    } catch (e) {
      if (mounted) showMessage(context, 'Please try again.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _sendOtp() {
    if (!_agreedToTerms) {
      showMessage(
        context,
        'Please agree to the Terms of Service and Privacy Policy.',
      );
      return Future.value();
    }
    return _run(
      () => _auth.sendOtp(
        '$_countryCode${_phone.text.trim().replaceAll(RegExp(r'[^0-9]'), '')}',
        onCodeSent: (id) {
          if (mounted) setState(() => _verificationId = id);
        },
        onError: (msg) {
          if (mounted) showMessage(context, msg);
        },
      ),
    );
  }

  Future<void> _showCountryPicker() async {
    final searchController = TextEditingController();
    final selected = await showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: _cream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) {
          final query = searchController.text.trim().toLowerCase();
          final filtered = oyarooCountries.where((country) {
            return country['name']!.toLowerCase().contains(query) ||
                country['code']!.toLowerCase().contains(query);
          }).toList();

          return SafeArea(
            child: SizedBox(
              height: MediaQuery.sizeOf(context).height * .78,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Choose country',
                            style: TextStyle(
                              color: _ink,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close, color: _ink),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextField(
                      controller: searchController,
                      onChanged: (_) => setSheetState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Search country or calling code',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: filtered.isEmpty
                        ? const Center(child: Text('No countries found'))
                        : ListView.builder(
                            itemCount: filtered.length,
                            itemBuilder: (context, index) {
                              final country = filtered[index];
                              return ListTile(
                                leading: Text(
                                  country['flag']!,
                                  style: const TextStyle(fontSize: 25),
                                ),
                                title: Text(
                                  country['name']!,
                                  style: const TextStyle(color: _ink),
                                ),
                                trailing: Text(
                                  country['code']!,
                                  style: const TextStyle(
                                    color: _darkGold,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                onTap: () => Navigator.pop(context, country),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
    searchController.dispose();

    if (selected != null && mounted) {
      setState(() {
        _countryCode = selected['code']!;
        _countryFlag = selected['flag']!;
      });
    }
  }

  Future<void> _verify() {
    final id = _verificationId;
    if (id == null) return Future.value();
    return _run(() => _auth.verifyOtp(id, _otp.text.trim()));
  }

  @override
  void dispose() {
    _phone.dispose();
    _otp.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Scaffold(
      backgroundColor: _cream,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Positioned(
            top: -70,
            right: -80,
            child: Container(
              width: size.width * .78,
              height: size.width * .78,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFFFD985).withValues(alpha: .65),
                    _cream.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                20,
                size.height < 700 ? 4 : 12,
                20,
                size.height < 700 ? 8 : 18,
              ),
              child: Column(
                children: [
                  SizedBox(
                    height: size.height < 650
                        ? 225
                        : size.height < 700
                        ? 245
                        : size.height < 750
                        ? 265
                        : size.height < 850
                        ? 290
                        : 315,
                    child: Stack(
                      children: [
                        Positioned(
                          right: -12,
                          top: 5,
                          bottom: 0,
                          width: size.width * .54,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(140),
                            child: Image.asset(
                              'assets/discover/oyaroo_couple.png',
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => Container(
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topRight,
                                    end: Alignment.bottomLeft,
                                    colors: [
                                      Color(0xFFFFE8B7),
                                      Color(0xFFF4D8B6),
                                      Color(0xFFFFF8EF),
                                    ],
                                  ),
                                ),
                                child: const Icon(
                                  Icons.favorite_rounded,
                                  color: _gold,
                                  size: 76,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 0,
                          top: 24,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: .7),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _gold.withValues(alpha: .55),
                                width: 1.5,
                              ),
                            ),
                            child: const Icon(
                              Icons.favorite_rounded,
                              size: 36,
                              color: _darkGold,
                            ),
                          ),
                        ),
                        Positioned(
                          left: 0,
                          top: 92,
                          right: size.width * .52,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Oyaroo',
                                style: TextStyle(
                                  fontSize: 38,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -1.4,
                                  color: _ink,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                'L I V E   •   V O I C E   •   F R I E N D S',
                                style: TextStyle(
                                  fontSize: 9,
                                  color: _ink.withValues(alpha: .6),
                                ),
                              ),
                              const SizedBox(height: 22),
                              const Text(
                                'Real People,\nReal Connections ♡',
                                style: TextStyle(
                                  fontSize: 21,
                                  height: 1.3,
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.w600,
                                  color: _darkGold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Positioned(
                          left: 2,
                          bottom: 8,
                          child: Row(
                            children: [
                              _AvatarDot(icon: Icons.person),
                              SizedBox(width: 5),
                              _AvatarDot(icon: Icons.face_rounded),
                              SizedBox(width: 5),
                              _AvatarDot(icon: Icons.person_rounded),
                              SizedBox(width: 5),
                              _AvatarDot(icon: Icons.favorite_rounded),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.only(left: 4, bottom: 13),
                      child: Text(
                        'Join millions of new friends  ♥',
                        style: TextStyle(
                          fontSize: 14,
                          color: _darkGold,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFCF7).withValues(alpha: .96),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(
                        color: const Color(0xFFEBD5AF),
                        width: 1.3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _darkGold.withValues(alpha: .12),
                          blurRadius: 24,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _socialButton(
                          icon: Icons.g_mobiledata_rounded,
                          title: 'Google se login',
                          subtitle: 'Continue with Google',
                          onTap: () => _run(_auth.google),
                        ),
                        const SizedBox(height: 8),
                        _socialButton(
                          icon: Icons.apple,
                          title: 'Apple se login',
                          subtitle: 'Continue with Apple',
                          dark: true,
                          onTap: () => showMessage(
                            context,
                            'Apple login is not configured yet.',
                          ),
                        ),
                        const SizedBox(height: 13),
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: _darkGold.withValues(alpha: .3),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 7,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFEBCB),
                                borderRadius: BorderRadius.circular(22),
                              ),
                              child: const Text(
                                'OR',
                                style: TextStyle(
                                  color: _darkGold,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: _darkGold.withValues(alpha: .3),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _phone,
                          keyboardType: TextInputType.phone,
                          style: const TextStyle(
                            color: _ink,
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                          decoration: InputDecoration(
                            prefixIcon: InkWell(
                              onTap: _showCountryPicker,
                              borderRadius: BorderRadius.circular(20),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _countryFlag,
                                      style: const TextStyle(fontSize: 22),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _countryCode,
                                      style: const TextStyle(
                                        color: _ink,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    const Icon(
                                      Icons.keyboard_arrow_down,
                                      color: _darkGold,
                                    ),
                                    const SizedBox(width: 6),
                                    const SizedBox(
                                      height: 30,
                                      child: VerticalDivider(),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            hintText: 'Phone number',
                            hintStyle: TextStyle(color: Colors.grey.shade500),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 19,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(22),
                              borderSide: const BorderSide(
                                color: Color(0xFFE7D2B5),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(22),
                              borderSide: const BorderSide(
                                color: _gold,
                                width: 1.8,
                              ),
                            ),
                          ),
                        ),
                        if (_verificationId != null) ...[
                          const SizedBox(height: 14),
                          TextField(
                            controller: _otp,
                            keyboardType: TextInputType.number,
                            maxLength: 6,
                            style: const TextStyle(
                              fontSize: 20,
                              letterSpacing: 8,
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Enter OTP',
                              counterText: '',
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        _goldButton(
                          label: _verificationId == null
                              ? '➤   OTP bhejo'
                              : '✓   Verify karo',
                          busy: _busy,
                          onTap: _busy
                              ? null
                              : _verificationId == null
                              ? _sendOtp
                              : _verify,
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Checkbox(
                              value: _agreedToTerms,
                              onChanged: (value) {
                                setState(() => _agreedToTerms = value ?? false);
                              },
                              activeColor: _darkGold,
                              checkColor: Colors.white,
                              visualDensity: VisualDensity.compact,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(
                                  () => _agreedToTerms = !_agreedToTerms,
                                ),
                                child: Text(
                                  "I agree to Oyaroo's Terms of Service and Privacy Policy",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    color: _ink.withValues(alpha: .75),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: size.height < 700 ? 6 : 12),
                  Container(
                    height: 2,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Color(0xFFFFD46D),
                          Color(0xFFE5AD3C),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  const Row(
                    children: [
                      Expanded(
                        child: _Feature(
                          icon: Icons.groups_rounded,
                          title: 'Live Rooms',
                          subtitle: 'Meet new people',
                          color: Color(0xFFFFE8B7),
                          iconColor: _darkGold,
                        ),
                      ),
                      Expanded(
                        child: _Feature(
                          icon: Icons.mic_rounded,
                          title: 'Voice Chat',
                          subtitle: 'Real conversations',
                          color: Color(0xFFFFDEDE),
                          iconColor: Color(0xFFB84C4C),
                        ),
                      ),
                      Expanded(
                        child: _Feature(
                          icon: Icons.shield_rounded,
                          title: 'Safe & Secure',
                          subtitle: 'Your privacy first',
                          color: Color(0xFFE8DFFF),
                          iconColor: Color(0xFF7752C7),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _socialButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool dark = false,
  }) {
    final foreground = dark ? Colors.white : _ink;
    return Material(
      color: dark ? const Color(0xFF171614) : Colors.white,
      borderRadius: BorderRadius.circular(25),
      elevation: 4,
      shadowColor: _darkGold.withValues(alpha: .14),
      child: InkWell(
        borderRadius: BorderRadius.circular(25),
        onTap: _busy ? null : onTap,
        child: Container(
          height: 66,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: dark ? Colors.white12 : const Color(0xFFF1E8DB),
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 48,
                child: Icon(
                  icon,
                  size: 38,
                  color: dark ? Colors.white : const Color(0xFF4285F4),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: foreground,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 10,
                        color: dark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: foreground, size: 28),
            ],
          ),
        ),
      ),
    );
  }

  Widget _goldButton({
    required String label,
    required bool busy,
    required VoidCallback? onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFE58B), Color(0xFFF4C451), Color(0xFFD99C22)],
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: _gold.withValues(alpha: .3),
              blurRadius: 13,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: const Color(0xFF4A2D05),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
              side: const BorderSide(color: Color(0xFFFFF0B8)),
            ),
          ),
          child: busy
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(
                  label,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
        ),
      ),
    );
  }
}

class _AvatarDot extends StatelessWidget {
  final IconData icon;
  const _AvatarDot({required this.icon});

  @override
  Widget build(BuildContext context) => Container(
    width: 43,
    height: 43,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.white,
      border: Border.all(color: _gold, width: 1.5),
      boxShadow: [
        BoxShadow(color: _darkGold.withValues(alpha: .12), blurRadius: 5),
      ],
    ),
    child: Icon(icon, color: _darkGold, size: 24),
  );
}

class _Feature extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final Color iconColor;

  const _Feature({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: Icon(icon, color: iconColor, size: 23),
      ),
      const SizedBox(height: 4),
      Text(
        title,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: _ink,
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        subtitle,
        textAlign: TextAlign.center,
        style: TextStyle(color: _ink.withValues(alpha: .62), fontSize: 8),
      ),
    ],
  );
}
