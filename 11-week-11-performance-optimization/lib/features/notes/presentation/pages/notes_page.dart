import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/format.dart';
import '../../domain/entities/note.dart';
import '../providers/notes_providers.dart';

class NotesPage extends ConsumerStatefulWidget {
  const NotesPage({super.key});

  @override
  ConsumerState<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends ConsumerState<NotesPage> {
  final _title = TextEditingController();
  final _body = TextEditingController();
  final _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(notesProvider.notifier).load());
  }

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    _search.dispose();
    super.dispose();
  }

  Future<void> _addNote() async {
    final title = _title.text.trim();
    if (title.isEmpty) return;
    await ref
        .read(notesProvider.notifier)
        .add(title: title, body: _body.text.trim());
    final state = ref.read(notesProvider);
    if (state.failure == null) {
      _title.clear();
      _body.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    // OPTIMIZATION: Riverpod .select() — editor only rebuilds on isSaving/failure,
    // not on every note list update.
    final isSaving = ref.watch(notesProvider.select((s) => s.isSaving));
    final failure = ref.watch(notesProvider.select((s) => s.failure));

    return Scaffold(
      appBar: AppBar(title: const Text('Notes')),
      // OPTIMIZATION: CustomScrollView + SliverList.builder for lazy rendering.
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            sliver: SliverToBoxAdapter(
              child: _NoteEditor(
                titleController: _title,
                bodyController: _body,
                isSaving: isSaving,
                failure: failure,
                onAdd: _addNote,
                onRetry: () => ref.read(notesProvider.notifier).load(),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            sliver: SliverToBoxAdapter(
              child: _SearchField(
                controller: _search,
                onChanged: (q) => ref.read(notesProvider.notifier).search(q),
              ),
            ),
          ),
          const SliverPadding(
            padding: EdgeInsets.only(top: 12),
            sliver: _NotesList(),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// OPTIMIZATION: Extracted widget — only rebuilds when isSaving/failure changes.
// ---------------------------------------------------------------------------
class _NoteEditor extends StatelessWidget {
  const _NoteEditor({
    required this.titleController,
    required this.bodyController,
    required this.isSaving,
    required this.failure,
    required this.onAdd,
    required this.onRetry,
  });

  final TextEditingController titleController;
  final TextEditingController bodyController;
  final bool isSaving;
  final dynamic failure;
  final VoidCallback onAdd;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: titleController,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            labelText: 'Title',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: bodyController,
          minLines: 2,
          maxLines: 4,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            labelText: 'Body',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: isSaving ? null : onAdd,
          icon: isSaving
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.add),
          label: const Text('Add note'),
        ),
        if (failure != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  failure!.message as String,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
                TextButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Coba lagi'),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// OPTIMIZATION: Extracted search field — purely stateless, const-constructible.
// ---------------------------------------------------------------------------
class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: const InputDecoration(
        labelText: 'Search note titles',
        prefixIcon: Icon(Icons.search),
        border: OutlineInputBorder(),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// OPTIMIZATION: Separate Consumer — rebuilds independently of editor.
// SliverList.builder builds only visible tiles (lazy), not all at once.
// ---------------------------------------------------------------------------
class _NotesList extends ConsumerWidget {
  const _NotesList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(notesProvider.select((s) => s.isLoading));
    final notes = ref.watch(notesProvider.select((s) => s.visibleNotes));
    final hasNotes = ref.watch(notesProvider.select((s) => s.notes.isNotEmpty));
    final failure = ref.watch(notesProvider.select((s) => s.failure));

    if (isLoading) {
      return const SliverToBoxAdapter(
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (!hasNotes && failure == null) {
      return const SliverToBoxAdapter(
        child: Center(child: Text('Belum ada catatan.')),
      );
    }
    if (notes.isEmpty && failure == null) {
      return const SliverToBoxAdapter(
        child: Center(child: Text('Tidak ada judul catatan yang cocok.')),
      );
    }

    // OPTIMIZATION: SliverList.builder — builds only visible items.
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
      sliver: SliverList.builder(
        itemCount: notes.length,
        itemBuilder: (context, index) => _NoteTile(note: notes[index]),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// OPTIMIZATION: Extracted const-constructible tile — element diffing can
// reuse unchanged tiles without rebuilding them.
// ---------------------------------------------------------------------------
class _NoteTile extends StatelessWidget {
  const _NoteTile({required this.note});

  final Note note;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(note.title),
        subtitle: Text(
          note.body.isEmpty ? ' ' : note.body,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(formatDateTime(note.updatedAt)),
            if (note.dirty) const Text('Local'),
          ],
        ),
      ),
    );
  }
}
