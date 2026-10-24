import 'package:oyaroo/features/items/screens/my_items_screen.dart';
import 'package:oyaroo/features/themes/screens/theme_store_screen.dart';
import 'package:oyaroo/features/family/screens/family_screen.dart' as feature_family;
import 'package:oyaroo/features/level/center/screens/level_center_screen.dart';
import 'package:oyaroo/features/vip/center/screens/vip_center_screen.dart';
import 'package:oyaroo/core/brand.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oyaroo/core/cp_levels.dart';
import 'package:oyaroo/core/level_rules.dart';
import 'package:oyaroo/core/ui.dart';
import 'package:oyaroo/core/vip.dart';
import 'package:oyaroo/handlers/auth_handler.dart';
import 'package:oyaroo/helpers/formatters.dart';
import 'package:oyaroo/helpers/frame_ring.dart';
import 'package:oyaroo/helpers/menu_page.dart';
import 'package:oyaroo/screens/admin_screen.dart';
import 'package:oyaroo/screens/agent_desk_screen.dart';
import 'package:oyaroo/screens/recharge_screen.dart';
import 'package:oyaroo/screens/cp_screen.dart';
import 'package:oyaroo/screens/family_screen.dart';
import 'package:oyaroo/screens/level_screen.dart';
import 'package:oyaroo/screens/medal_screen.dart';
import 'package:oyaroo/screens/profile_screen.dart';
import 'package:oyaroo/screens/wallet_screen.dart';
import 'package:oyaroo/screens/vip_screen.dart';
import 'package:oyaroo/services/user_service.dart';

class MeScreen extends StatelessWidget {
  const MeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: UserService.profileStream(user.uid),
      builder: (context, snap) {
        final data = snap.data?.data() ?? {};
        final coins = (data['coins'] ?? 0) as num;
        final exp = (data['exp'] ?? 0) as int;
        final vip = (data['vip'] ?? 0) as int;
        final equipped = data['equippedFrame'] as int?;
        final level = LevelRules.levelFor(exp);
        final hasFamily = data['familyId'] != null;

        return ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Row(
                children: [
                  FrameAvatar(
                    milestone: equipped,
                    radius: 36,
                    child: const Icon(Icons.person, size: 36),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${data['name'] ?? 'User'}',
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        Row(
                          children: [
                            Expanded(
                              child: Text('ID: ${user.uid}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(color: Colors.grey)),
                            ),
                            IconButton(
                              icon: const Icon(Icons.copy, size: 18),
                              onPressed: () {
                                Clipboard.setData(ClipboardData(text: user.uid));
                                showMessage(context, 'ID copy ho gayi');
                              },
                            ),
                          ],
                        ),
                        Text('${data['bio'] ?? ''}',
                            style: const TextStyle(color: Colors.black54)),
                        TextButton(
                          onPressed: () => Navigator.push(context,
                              MaterialPageRoute(builder: (_) => const ProfileScreen())),
                          child: const Text('Profile edit karein'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            MenuSection(children: [
              MenuRow(
                label: 'Wallet',
                trailingText: formatCoins(coins),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WalletScreen())),
              ),
              MenuRow(
                label: 'Invite Friends',
                trailingText: 'Earn Coins',
                onTap: () => openMenuPage(context,
                    title: 'Invite Friends',
                    description: 'Dost ko invite karke coins kamayein. Jald aayega.'),
              ),
              MenuRow(
                label: 'Earn Cash',
                onTap: () => openMenuPage(context, title: 'Earn Cash'),
              ),
              MenuRow(
                label: 'Medal',
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const MedalScreen())),
              ),
              MenuRow(
                label: 'VIP',
                trailingText: vip == 0 ? 'Join now' : 'VIP $vip',
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(
                      builder: (_) => VipCenterScreen(
                        uid: user.uid,
                        onRecharge: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RechargeScreen(),
                          ),
                        ),
                      ),
                    )),
              ),
              MenuRow(
                label: 'Level',
                trailingText: 'Lv $level',
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => LevelCenterScreen(uid: user.uid))),
              ),
              MenuRow(
                label: 'CP / Friend',
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const CpScreen())),
              ),
              MenuRow(
                label: 'Family',
                trailingText: hasFamily ? 'Mein hoon' : 'Join now',
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => feature_family.FamilyScreen(uid: user.uid))),
              ),
              MenuRow(
                label: 'Recharge',
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const RechargeScreen())),
              ),
              if (data['role'] == 'agent')
                MenuRow(
                  label: 'Agent Desk',
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const AgentDeskScreen())),
                ),
              if (data['role'] == 'admin')
                MenuRow(
                  label: 'Admin Panel',
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const AdminScreen())),
                ),
              MenuRow(
                label: 'Store',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ThemeStoreScreen(uid: user.uid),
                  ),
                ),
              ),
              MenuRow(
                label: 'My Items',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MyItemsScreen(uid: user.uid),
                  ),
                ),
              ),
            ]),
            MenuSection(children: [
              MenuRow(
                label: 'Language',
                trailingText: 'English',
                onTap: () => openMenuPage(context,
                    title: 'Language', description: 'Abhi sirf English available hai.'),
              ),
              MenuRow(
                label: 'Feedback',
                onTap: () => openMenuPage(context, title: 'Feedback'),
              ),
              MenuRow(
                label: 'Settings',
                onTap: () => openMenuPage(context, title: 'Settings'),
              ),
            ]),
            TextButton(
              onPressed: () => AuthHandler().signOut(),
              child: const Text('Logout', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}

// Wallet page: coins live dikhate hain
class WalletInfo extends StatelessWidget {
  const WalletInfo({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: UserService.profileStream(uid),
      builder: (context, snap) {
        final coins = (snap.data?.data()?['coins'] ?? 0) as num;
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.monetization_on, size: 56, color: Colors.amber),
              const SizedBox(height: 12),
              Text('${formatCoins(coins)} ${Brand.coinName}',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Recharge jald aayega.'),
            ],
          ),
        );
      },
    );
  }
}
