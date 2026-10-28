import 'package:flutter/material.dart';

import '../app/theme.dart';

/// Honest empty page for features that are not built yet.
class PlaceholderPage extends StatelessWidget {
  const PlaceholderPage({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 66, color: const Color(0xFF9B7B48)),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: OyaaroColors.ink,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: OyaaroColors.muted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
