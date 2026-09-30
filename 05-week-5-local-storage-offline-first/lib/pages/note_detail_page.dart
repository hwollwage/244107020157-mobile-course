import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/repositories/note_repositoriy.dart';
import '../widgets/note_dialog.dart';

class NoteDetailPage extends ConsumerWidget {
  const NoteDetailPage({super.key, required this.noteId});
  final int noteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final noteAsync = ref.watch(noteByIdProvider(noteId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Catatan'),
        actions: [
          if (noteAsync.value != null) ...[
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () async {
                final note = noteAsync.value!;
                final result = await showNoteDialog(context, initial: note);
                if (result == null) return;
                await ref
                    .read(notesProvider.notifier)
                    .edit(note, title: result.title, body: result.body);
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () async {
                await ref.read(notesProvider.notifier).remove(noteId);
                if (context.mounted) context.pop();
              },
            ),
          ],
        ],
      ),
      body: noteAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Gagal memuat: $err')),
        data: (note) {
          if (note == null) {
            return const Center(child: Text('Catatan tidak ditemukan.'));
          }
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(note.title,
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text(
                  'Diubah: ${note.updatedAt.toLocal().toString().substring(0, 16)}'
                  ' • ${note.dirty ? "Belum tersinkron" : "Tersinkron"}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const Divider(height: 24),
                Text(note.body.isEmpty ? '(tanpa isi)' : note.body),
              ],
            ),
          );
        },
      ),
    );
  }
}