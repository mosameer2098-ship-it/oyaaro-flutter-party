import 'package:flutter/material.dart';

import '../../themes/catalog/theme_catalog.dart';
import '../../themes/models/theme_spec.dart';
import '../handlers/couple_handler.dart';
import '../models/couple_bond.dart';
import '../services/couple_service.dart';
import '../widgets/couple_frame.dart';

class CoupleScreen extends StatefulWidget {
  const CoupleScreen({
    super.key,
    required this.convId,
    required this.myUid,
    required this.myAvatar,
    required this.otherAvatar,
    required this.ownedCoupleThemes,
  });

  final String convId;
  final String myUid;
  final Widget myAvatar;
  final Widget otherAvatar;
  final List<String> ownedCoupleThemes;

  @override
  State<CoupleScreen> createState() => _CoupleScreenState();
}

class _CoupleScreenState extends State<CoupleScreen> {
  final _service = CoupleService();
  late final CoupleHandler _handler = CoupleHandler(_service);

  void _show(String? msg) {
    if (!mounted || msg == null) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CP')),
      body: StreamBuilder<CoupleBond>(
        stream: _service.watch(widget.convId),
        builder: (context, snap) {
          final bond = snap.data;
          if (bond == null) return const Center(child: CircularProgressIndicator());
          final themeId = bond.coupleThemeId;
          final theme = themeId == null ? null : ThemeCatalog.byId(themeId);
          final colors = theme?.colors ?? const [Color(0xFFFF4DFF), Color(0xFFB388FF), Colors.white];
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Center(
                child: CoupleAvatarPair(
                  left: widget.myAvatar,
                  right: widget.otherAvatar,
                  colors: colors,
                  radius: 36,
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  bond.isActive ? 'Lv ${bond.level}: ${bond.title}' : 'CP abhi active nahi hai',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(value: _progress(bond)),
              Text('Bond exp: ${bond.exp}'),
              const SizedBox(height: 16),
              if (!bond.isActive && !bond.isPending)
                ElevatedButton(
                  onPressed: () async => _show(await _handler.request(bond)),
                  child: const Text('CP request bhejo'),
                ),
              if (bond.isPending && bond.requestedBy != widget.myUid)
                ElevatedButton(
                  onPressed: () async => _show(await _handler.accept(bond, widget.myUid)),
                  child: const Text('Accept karo'),
                ),
              if (bond.isPending && bond.requestedBy == widget.myUid)
                const Text('Request bheji ja chuki hai'),
              const Divider(height: 32),
              const Text('Couple theme', style: TextStyle(fontWeight: FontWeight.bold)),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final CoupleThemeOption o in _options(widget.ownedCoupleThemes))
                    ChoiceChip(
                      label: Text(o.theme.name),
                      selected: themeId == o.theme.id,
                      onSelected: o.owned
                          ? (_) async => _show(await _handler.setTheme(widget.convId, o.theme.id))
                          : null,
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  double _progress(CoupleBond b) {
    final l = b.level;
    if (l >= CoupleBond.maxLevel) return 1;
    final cur = CoupleBond.requiredExp(l);
    final next = CoupleBond.requiredExp(l + 1);
    return ((b.exp - cur) / (next - cur)).clamp(0.0, 1.0).toDouble();
  }

  List<CoupleThemeOption> _options(List<String> owned) => [
        for (final t in ThemeCatalog.couple) CoupleThemeOption(t, owned.contains(t.id)),
      ];
}

class CoupleThemeOption {
  const CoupleThemeOption(this.theme, this.owned);
  final ThemeSpec theme;
  final bool owned;
}
