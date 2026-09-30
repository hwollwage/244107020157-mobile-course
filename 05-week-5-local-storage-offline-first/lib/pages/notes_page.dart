import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/repositories/note_repositoriy.dart';
import '../data/sync.dart';
import '../widgets/note_dialog.dart';
import '../widgets/note_tile.dart';

class NotesPage extends ConsumerWidget {
  const NotesPage({super.key});

  Future<void> _sync(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final count = await ref.read(syncControllerProvider).sync();
      messenger.showSnackBar(SnackBar(
        content: Text(count == 0
            ? 'Semua catatan sudah tersinkron'
            : '$count catatan berhasil disinkronkan'),
      ));
    } on OfflineException {
      messenger.showSnackBar(const SnackBar(
        content: Text('Sedang offline: sinkronisasi ditunda'),
      ));
    }
  }

  Future<void> _add(BuildContext context, WidgetRef ref) async {
    final result = await showNoteDialog(context);
    if (result == null) return;
    await ref.read(notesProvider.notifier).add(result.title, result.body);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(notesProvider);
    final dirtyCount = ref.watch(dirtyCountProvider).value ?? 0;
    final offline = ref.watch(forceOfflineProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline Notes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.article_outlined),
            tooltip: 'Posts (cache-first)',
            onPressed: () => context.push('/posts'),
          ),
          Badge(
            isLabelVisible: dirtyCount > 0,
            label: Text('$dirtyCount'),
            child: IconButton(
              icon: const Icon(Icons.sync),
              tooltip: 'Sync',
              onPressed: () => _sync(context, ref),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: Column(
        children: [
          if (offline)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              color: Colors.orange.shade200,
              child: const Text(
                'Mode offline (simulasi)',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black87),
              ),
            ),
          Expanded(
            child: notesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Gagal membaca database lokal: $err',
                          textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: () => ref.invalidate(notesProvider),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
              data: (notes) {
                if (notes.isEmpty) {
                  return const Center(
                    child: Text('Belum ada catatan. Tap + untuk menambah.'),
                  );
                }
                return ListView.builder(
                  itemCount: notes.length,
                  itemBuilder: (context, index) {
                    final note = notes[index];
                    return NoteTile(
                      note: note,
                      onTap: () => context.push('/note/${note.id}'),
                      onDelete: () =>
                          ref.read(notesProvider.notifier).remove(note.id!),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _add(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }
}