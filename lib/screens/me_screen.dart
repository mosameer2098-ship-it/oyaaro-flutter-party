import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oyaroo/core/brand.dart';
import 'package:oyaroo/core/level_rules.dart';
import 'package:oyaroo/core/ui.dart';
import 'package:oyaroo/features/family/screens/family_screen.dart' as feature_family;
import 'package:oyaroo/features/items/screens/my_items_screen.dart';
import 'package:oyaroo/features/level/center/screens/level_center_screen.dart';
import 'package:oyaroo/features/themes/screens/theme_store_screen.dart';
import 'package:oyaroo/features/vip/center/screens/vip_center_screen.dart';
import 'package:oyaroo/handlers/auth_handler.dart';
import 'package:oyaroo/helpers/formatters.dart';
import 'package:oyaroo/helpers/frame_ring.dart';
import 'package:oyaroo/helpers/menu_page.dart';
import 'package:oyaroo/screens/admin_screen.dart';
import 'package:oyaroo/screens/agent_desk_screen.dart';
import 'package:oyaroo/screens/cp_screen.dart';
import 'package:oyaroo/screens/medal_screen.dart';
import 'package:oyaroo/screens/profile_screen.dart';
import 'package:oyaroo/screens/recharge_screen.dart';
import 'package:oyaroo/screens/wallet_screen.dart';
import 'package:oyaroo/services/user_service.dart';

class MeScreen extends StatelessWidget {
  const MeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0B1E),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF191338),
              Color(0xFF0F0C22),
              Color(0xFF0A0716),
            ],
          ),
        ),
        child: SafeArea(
          child: StreamBuilder(
            stream: UserService.profileStream(user.uid),
            builder: (context, AsyncSnapshot snap) {
              final data = (snap.data?.data() as Map<String, dynamic>?) ?? {};
              final coins = (data['coins'] ?? 0) as num;
              final exp = (data['exp'] ?? 0) as int;
              final vip = (data['vip'] ?? 0) as int;
              final equipped = data['equippedFrame'] as int?;
              final level = LevelRules.levelFor(exp);
              final hasFamily = data['familyId'] != null;

              return ListView(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                children: [
                  // --- PROFILE HEADER CARD ---
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B1736).withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: const Color(0xFF433878).withValues(alpha: 0.6)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.4),
                          blurRadius: 15,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFFFDF88), Color(0xFFB37E1C)],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFEDB843).withValues(alpha: 0.35),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                              child: FrameAvatar(
                                milestone: equipped,
                                radius: 32,
                                child: const Icon(Icons.person_rounded, size: 34, color: Color(0xFF322306)),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          '${data['name'] ?? 'User'}',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 20,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      _buildBadge(
                                        text: vip > 0 ? 'VIP $vip' : 'VIP',
                                        gradient: const [Color(0xFFFFDF00), Color(0xFFE5A800)],
                                        textColor: const Color(0xFF472700),
                                      ),
                                      const SizedBox(width: 4),
                                      _buildBadge(
                                        text: 'Lv $level',
                                        gradient: const [Color(0xFF8A2BE2), Color(0xFF4A00E0)],
                                        textColor: Colors.white,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Text(
                                        'ID: ${data['shortId'] ?? 'Generating...'}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.white.withValues(alpha: 0.65),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      InkWell(
                                        onTap: () {
                                          final numericId = data['shortId']?.toString();
                                          if (numericId != null && numericId.isNotEmpty) {
                                            Clipboard.setData(ClipboardData(text: numericId));
                                            showMessage(context, 'Numeric ID copy ho gayi');
                                          } else {
                                            showMessage(context, 'ID abhi generate ho rahi hai');
                                          }
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(2.0),
                                          child: Icon(Icons.copy_rounded,
                                              size: 14, color: Colors.white.withValues(alpha: 0.65)),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if ((data['bio'] ?? '').toString().trim().isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      '${data['bio']}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.5),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            InkWell(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const ProfileScreen()),
                              ),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFFEDB843), Color(0xFFB58019)],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  'Edit Profile',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2C1E03),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildCounter('12', 'Following'),
                              Container(width: 1, height: 16, color: Colors.white12),
                              _buildCounter('240', 'Followers'),
                              Container(width: 1, height: 16, color: Colors.white12),
                              _buildCounter('1.2K', 'Visitors'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // --- WALLET & RECHARGE BANNER ---
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF8F6724), Color(0xFFE4BC66), Color(0xFF815B17)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF8F6724).withValues(alpha: 0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const WalletScreen()),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: const [
                                  Icon(Icons.diamond_rounded, color: Colors.white, size: 20),
                                  SizedBox(width: 6),
                                  Text(
                                    'Wallet',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                    formatCoins(coins),
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    Brand.coinName,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const RechargeScreen()),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFE082),
                            foregroundColor: const Color(0xFF4E3406),
                            elevation: 3,
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: const Text('Buy / Recharge', style: TextStyle(fontWeight: FontWeight.w800)),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // --- 4x2 RICH FEATURE GRID ---
                  GridView.count(
                    crossAxisCount: 4,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 0.85,
                    children: [
                      _buildGridCard(
                        icon: Icons.workspace_premium_rounded,
                        color: const Color(0xFFFFB300),
                        label: 'VIP',
                        sub: vip == 0 ? 'Join now' : 'VIP $vip',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => VipCenterScreen(
                              uid: user.uid,
                              onRecharge: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const RechargeScreen()),
                              ),
                            ),
                          ),
                        ),
                      ),
                      _buildGridCard(
                        icon: Icons.star_rounded,
                        color: const Color(0xFFBA68C8),
                        label: 'Level',
                        sub: 'Lv $level',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => LevelCenterScreen(uid: user.uid)),
                        ),
                      ),
                      _buildGridCard(
                        icon: Icons.military_tech_rounded,
                        color: const Color(0xFFFFD54F),
                        label: 'Medal',
                        sub: 'Honor',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const MedalScreen()),
                        ),
                      ),
                      _buildGridCard(
                        icon: Icons.shield_rounded,
                        color: const Color(0xFF4FC3F7),
                        label: 'Family',
                        sub: hasFamily ? 'Joined' : 'Join now',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => feature_family.FamilyScreen(uid: user.uid)),
                        ),
                      ),
                      _buildGridCard(
                        icon: Icons.favorite_rounded,
                        color: const Color(0xFFFF4081),
                        label: 'CP / Friend',
                        sub: 'Bond',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const CpScreen()),
                        ),
                      ),
                      _buildGridCard(
                        icon: Icons.shopping_cart_rounded,
                        color: const Color(0xFFFF8A65),
                        label: 'Store',
                        sub: 'Themes',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ThemeStoreScreen(uid: user.uid),
                          ),
                        ),
                      ),
                      _buildGridCard(
                        icon: Icons.card_giftcard_rounded,
                        color: const Color(0xFFAB47BC),
                        label: 'My Items',
                        sub: 'Bag',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => MyItemsScreen(uid: user.uid)),
                        ),
                      ),
                      _buildGridCard(
                        icon: Icons.monetization_on_rounded,
                        color: const Color(0xFF66BB6A),
                        label: 'Earn Cash',
                        sub: 'Rewards',
                        onTap: () => openMenuPage(context, title: 'Earn Cash'),
                      ),
                    ],
                  ),

                  // Admin / Agent Optional Tiles
                  if (data['role'] == 'agent' || data['role'] == 'admin') ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        if (data['role'] == 'agent')
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF231F46),
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const AgentDeskScreen()),
                              ),
                              icon: const Icon(Icons.support_agent_rounded, size: 18),
                              label: const Text('Agent Desk'),
                            ),
                          ),
                        if (data['role'] == 'agent' && data['role'] == 'admin') const SizedBox(width: 8),
                        if (data['role'] == 'admin')
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF231F46),
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const AdminScreen()),
                              ),
                              icon: const Icon(Icons.admin_panel_settings_rounded, size: 18),
                              label: const Text('Admin Panel'),
                            ),
                          ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 14),

                  // --- SETTINGS / UTILITIES CARD ---
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B1736).withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                    ),
                    child: Column(
                      children: [
                        _buildMenuTile(
                          icon: Icons.language_rounded,
                          title: 'Language',
                          trailing: 'English',
                          onTap: () => openMenuPage(
                            context,
                            title: 'Language',
                            description: 'Abhi sirf English available hai.',
                          ),
                        ),
                        Divider(height: 1, color: Colors.white.withValues(alpha: 0.06)),
                        _buildMenuTile(
                          icon: Icons.feedback_outlined,
                          title: 'Feedback',
                          onTap: () => openMenuPage(context, title: 'Feedback'),
                        ),
                        Divider(height: 1, color: Colors.white.withValues(alpha: 0.06)),
                        _buildMenuTile(
                          icon: Icons.settings_outlined,
                          title: 'Settings',
                          onTap: () => openMenuPage(
                            context,
                            title: 'Settings',
                            child: ListView(
                              shrinkWrap: true,
                              children: const [
                                ListTile(
                                  leading: Icon(Icons.person_outline_rounded, color: Colors.white),
                                  title: Text('Account settings', style: TextStyle(color: Colors.white)),
                                  subtitle: Text('Your Oyaroo account', style: TextStyle(color: Colors.white60)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // --- LOGOUT BUTTON ---
                  Center(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFFB71C1C).withValues(alpha: 0.25),
                        foregroundColor: const Color(0xFFFF5252),
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                          side: BorderSide(color: const Color(0xFFFF5252).withValues(alpha: 0.4)),
                        ),
                      ),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (dialogContext) => AlertDialog(
                            backgroundColor: const Color(0xFF1A1635),
                            title: const Text('Logout?', style: TextStyle(color: Colors.white)),
                            content: const Text(
                              'Kya aap Oyaroo se logout karna chahte hain?',
                              style: TextStyle(color: Colors.white70),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(dialogContext, false),
                                child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(dialogContext, true),
                                child: const Text('Logout', style: TextStyle(color: Color(0xFFFF5252))),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true && context.mounted) {
                          await AuthHandler().signOut();
                        }
                      },
                      child: const Text('Logout', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  static Widget _buildCounter(String count, String label) {
    return Column(
      children: [
        Text(count, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 11)),
      ],
    );
  }

  static Widget _buildBadge({required String text, required List<Color> gradient, required Color textColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradient),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(color: textColor, fontWeight: FontWeight.w800, fontSize: 10),
      ),
    );
  }

  static Widget _buildGridCard({
    required IconData icon,
    required Color color,
    required String label,
    required String sub,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF1B1736).withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              sub,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.45),
                fontSize: 9,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildMenuTile({
    required IconData icon,
    required String title,
    String? trailing,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      dense: true,
      leading: Icon(icon, color: Colors.white70, size: 20),
      title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailing != null)
            Text(trailing, style: TextStyle(color: Colors.white.withValues(alpha: 0.45), fontSize: 12)),
          const SizedBox(width: 4),
          Icon(Icons.arrow_forward_ios_rounded, color: Colors.white.withValues(alpha: 0.3), size: 12),
        ],
      ),
    );
  }
}

class WalletInfo extends StatelessWidget {
  const WalletInfo({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return StreamBuilder(
      stream: UserService.profileStream(uid),
      builder: (context, AsyncSnapshot snap) {
        final coins = (snap.data?.data()?['coins'] ?? 0) as num;
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.monetization_on, size: 56, color: Colors.amber),
              const SizedBox(height: 12),
              Text(
                '${formatCoins(coins)} ${Brand.coinName}',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('Recharge jald aayega.'),
            ],
          ),
        );
      },
    );
  }
}
