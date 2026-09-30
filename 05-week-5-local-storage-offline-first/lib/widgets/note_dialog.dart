import 'package:flutter/material.dart';
import '../data/local/note.dart';

Future<({String title, String body})?> showNoteDialog(
  BuildContext context, {
  Note? initial,
}) {
  final titleCtrl = TextEditingController(text: initial?.title ?? '');
  final bodyCtrl = TextEditingController(text: initial?.body ?? '');

  return showDialog<({String title, String body})>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(initial == null ? 'Catatan baru' : 'Edit catatan'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: titleCtrl,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Judul'),
          ),
          TextField(
            controller: bodyCtrl,
            maxLines: 4,
            decoration: const InputDecoration(labelText: 'Isi'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: () {
            final title = titleCtrl.text.trim();
            if (title.isEmpty) return;
            Navigator.pop(ctx, (title: title, body: bodyCtrl.text.trim()));
          },
          child: const Text('Simpan'),
        ),
      ],
    ),
  );
}