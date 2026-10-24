import 'package:flutter/material.dart';

import '../handlers/moderation_handler.dart';
import '../models/report.dart';
import '../services/moderation_service.dart';

Future<void> showReportSheet(
  BuildContext context, {
  required String targetUid,
  required String myUid,
  String? roomId,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (sheetCtx) => _ReportSheet(
      targetUid: targetUid,
      myUid: myUid,
      roomId: roomId,
      onDone: () => Navigator.pop(sheetCtx),
    ),
  );
}

class _ReportSheet extends StatefulWidget {
  const _ReportSheet({
    required this.targetUid,
    required this.myUid,
    required this.onDone,
    this.roomId,
  });

  final String targetUid;
  final String myUid;
  final String? roomId;
  final VoidCallback onDone;

  @override
  State<_ReportSheet> createState() => _ReportSheetState();
}

class _ReportSheetState extends State<_ReportSheet> {
  final _handler = ModerationHandler(ModerationService());
  final _details = TextEditingController();
  ReportReason _reason = ReportReason.spam;
  bool _busy = false;

  @override
  void dispose() {
    _details.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _busy = true);
    final err = await _handler.report(
      targetUid: widget.targetUid,
      myUid: widget.myUid,
      reason: _reason,
      details: _details.text,
      roomId: widget.roomId,
    );
    if (!mounted) return;
    setState(() => _busy = false);
    if (err == null) {
      widget.onDone();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Report bhej di gayi')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(context).viewInsets.bottom + 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Report karein', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          for (final r in ReportReason.values)
            RadioListTile<ReportReason>(
              title: Text(r.label),
              value: r,
              groupValue: _reason,
              onChanged: (v) => setState(() => _reason = v!),
            ),
          if (_reason == ReportReason.other)
            TextField(
              controller: _details,
              decoration: const InputDecoration(labelText: 'Details likhein'),
            ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _busy ? null : _submit,
            child: const Text('Report bhejo'),
          ),
        ],
      ),
    );
  }
}
