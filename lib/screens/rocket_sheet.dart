import 'package:oyaroo/core/brand.dart';
import 'package:flutter/material.dart';
import 'package:oyaroo/core/rockets.dart';
import 'package:oyaroo/helpers/formatters.dart';
import 'package:oyaroo/helpers/rocket_painter.dart';

class RocketSheet extends StatelessWidget {
  final void Function(RocketSpec spec) onLaunch;
  const RocketSheet({super.key, required this.onLaunch});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text('Rocket Launcher', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        Expanded(
          child: GridView.count(
            crossAxisCount: 2,
            padding: const EdgeInsets.all(12),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.62,
            children: [
              for (final r in Rockets.all)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      children: [
                        Expanded(child: RocketPreview(spec: r)),
                        Text(r.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text('${formatCoins(r.price)} ${Brand.coinName}'),
                        const SizedBox(height: 4),
                        ElevatedButton(
                          onPressed: () => onLaunch(r),
                          child: const Text('Launch'),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
