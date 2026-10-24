import 'package:flutter/material.dart';
import 'package:oyaroo/core/game_catalog.dart';
import 'package:oyaroo/core/game_rules.dart';
import 'package:oyaroo/core/ui.dart';
import 'package:oyaroo/helpers/menu_page.dart';

// Room ka game hub: Lucky Games, Party Game, Tools
class GamesSheet extends StatelessWidget {
  final void Function(GameSpec game) onPick;
  const GamesSheet({super.key, required this.onPick});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        _title('Lucky Games'),
        _grid([
          for (final g in GameCatalog.lucky)
            _tile(g.name, g.icon, g.c1, g.c2, () => onPick(g)),
        ]),
        _title('Party Game'),
        _grid([
          for (final g in GameCatalog.party)
            _tile(g.name, g.icon, g.c1, g.c2, () => onPick(g)),
          _tile('Video/Music', Icons.ondemand_video, const Color(0xFF7E57C2),
              const Color(0xFF4527A0), () => _soon(context, 'Video/Music')),
          _tile('PK', Icons.sports_mma, const Color(0xFFEF5350),
              const Color(0xFF283593), () => _soon(context, 'PK')),
        ]),
        _title('Tools'),
        _grid([
          _tile('Music', Icons.library_music, const Color(0xFF4FC3F7),
              const Color(0xFF0277BD), () => _soon(context, 'Music')),
          _tile('Store', Icons.storefront, const Color(0xFFFFB74D),
              const Color(0xFFE65100), () => openMenuPage(context, title: 'Store')),
          _tile('Effect', Icons.auto_fix_high, const Color(0xFFBA68C8),
              const Color(0xFF6A1B9A), () => _soon(context, 'Effect')),
          _tile('My Items', Icons.checkroom, const Color(0xFF9575CD),
              const Color(0xFF4527A0), () => openMenuPage(context, title: 'My Items')),
          _tile('Clean', Icons.cleaning_services, const Color(0xFF81C784),
              const Color(0xFF2E7D32), () => showMessage(context, 'Cache saaf ho gaya')),
        ]),
      ],
    );
  }

  void _soon(BuildContext context, String name) =>
      openMenuPage(context, title: name, description: 'Ye feature jald aayega');

  Widget _title(String text) => Padding(
        padding: const EdgeInsets.only(top: 12, bottom: 8),
        child: Text(text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      );

  Widget _grid(List<Widget> items) => GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 4,
        mainAxisSpacing: 12,
        crossAxisSpacing: 8,
        childAspectRatio: 0.78,
        children: items,
      );

  Widget _tile(String name, IconData icon, Color c1, Color c2, VoidCallback onTap) =>
      InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(colors: [c1, c2]),
              ),
              child: Icon(icon, color: Colors.white, size: 30),
            ),
            const SizedBox(height: 6),
            Text(name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11)),
          ],
        ),
      );
}
