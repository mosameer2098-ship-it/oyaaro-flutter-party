import 'package:flutter/material.dart';
import 'package:oyaroo/core/gift_catalog.dart';
import 'package:oyaroo/helpers/gift_helper.dart';

// Gift sheet mein ek gift ka premium card
class GiftCard extends StatelessWidget {
  final GiftSpec spec;
  final VoidCallback onTap;
  const GiftCard({super.key, required this.spec, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [spec.c1, spec.c2],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(color: spec.c2.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black38,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(GiftHelper.tierName(spec.tier),
                    style: const TextStyle(color: Colors.white, fontSize: 10)),
              ),
            ),
            Icon(spec.icon, size: 56, color: Colors.white),
            const SizedBox(height: 4),
            Text(spec.name,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            Text(GiftHelper.priceLabel(spec),
                style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
