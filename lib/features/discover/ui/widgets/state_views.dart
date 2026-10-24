import 'package:flutter/material.dart';

import '../discover_theme.dart';

class LoadingView extends StatelessWidget {
  const LoadingView({super.key});
  @override
  Widget build(BuildContext context) => const Center(
        child: CircularProgressIndicator(color: DiscoverColors.neonCyan),
      );
}

class EmptyView extends StatelessWidget {
  const EmptyView({super.key, required this.message, this.icon = Icons.inbox_outlined});
  final String message;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 56, color: DiscoverColors.neonPurple),
              const SizedBox(height: 12),
              Text(message, textAlign: TextAlign.center,
                  style: const TextStyle(color: DiscoverColors.textDim)),
            ],
          ),
        ),
      );
}

class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 56, color: DiscoverColors.danger),
              const SizedBox(height: 12),
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                key: const Key('retry_button'),
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Dobara try karein'),
              ),
            ],
          ),
        ),
      );
}

/// Demo repository use ho raha ho to ye banner dikhta hai
class DemoBanner extends StatelessWidget {
  const DemoBanner({super.key});
  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 6),
        color: DiscoverColors.danger.withValues(alpha: 0.85),
        child: const Text(
          'DEMO MODE: ye data real nahi hai',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      );
}
