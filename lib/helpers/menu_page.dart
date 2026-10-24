import 'package:flutter/material.dart';

// Generic page: har menu item isi se khulta hai
class MenuPage extends StatelessWidget {
  final String title;
  final String? description;
  final Widget? child;
  const MenuPage({super.key, required this.title, this.description, this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: child ??
            Center(
              child: Text(description ?? 'Ye feature jald aayega',
                  textAlign: TextAlign.center),
            ),
      ),
    );
  }
}

void openMenuPage(BuildContext context,
    {required String title, String? description, Widget? child}) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => MenuPage(title: title, description: description, child: child),
    ),
  );
}

// Text-button jaisi row
class MenuRow extends StatelessWidget {
  final String label;
  final String? trailingText;
  final VoidCallback onTap;
  const MenuRow({super.key, required this.label, required this.onTap, this.trailingText});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Expanded(child: Text(label, style: const TextStyle(fontSize: 16))),
            if (trailingText != null)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Text(trailingText!, style: TextStyle(color: Colors.grey.shade600)),
              ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

// Rows ko safed card mein dikhata hai
class MenuSection extends StatelessWidget {
  final List<Widget> children;
  const MenuSection({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: children),
    );
  }
}
