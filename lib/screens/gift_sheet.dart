import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:oyaroo/core/gift_catalog.dart';
import 'package:oyaroo/core/ui.dart';
import 'package:oyaroo/helpers/gift_helper.dart';
import 'package:oyaroo/screens/gift_card.dart';
import 'package:oyaroo/services/user_service.dart';

// Gift ki sheet: category tabs, lock wale gift par lock icon
class GiftSheet extends StatelessWidget {
  final List<GiftCategory> categories;
  final void Function(GiftSpec gift) onPick;
  const GiftSheet({super.key, required this.categories, required this.onPick});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: UserService.profileStream(uid),
      builder: (context, snap) {
        final vip = (snap.data?.data()?['vip'] ?? 0) as int;
        return DefaultTabController(
          length: categories.length,
          child: Column(
            children: [
              TabBar(
                isScrollable: true,
                tabs: [for (final c in categories) Tab(text: GiftHelper.categoryName(c))],
              ),
              Expanded(
                child: TabBarView(
                  children: [for (final c in categories) _grid(context, c, vip)],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _grid(BuildContext context, GiftCategory c, int vip) {
    final items = GiftHelper.inCategory(c);
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.8,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) {
        final g = items[i];
        final lock = GiftHelper.lockReason(g, vip);
        return Stack(
          children: [
            GiftCard(
              spec: g,
              onTap: () {
                if (lock != null) {
                  showMessage(context, lock);
                } else {
                  onPick(g);
                }
              },
            ),
            if (lock != null)
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.lock, color: Colors.white),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
