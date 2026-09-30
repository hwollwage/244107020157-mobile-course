import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_storage/data/local/note.dart';
import 'package:local_storage/data/repositories/note_repositoriy.dart';
import 'package:local_storage/data/sync.dart';

class FakeNoteRepository extends NoteRepository {
  FakeNoteRepository({this.items = const [], this.throwError = false})
      : super(openDb: () => throw UnimplementedError());

  final List<Note> items;
  final bool throwError;

  @override
  Future<List<Note>> fetchNotes() async {
    if (throwError) throw Exception('db locked (simulated)');
    return items;
  }

  @override
  Future<int> countDirty() =>
      Future.value(items.where((n) => n.dirty).length);
}

void main() {
  test('fromMap is safe against missing fields', () {
    final note = Note.fromMap({'title': 'Groceries'});
    expect(note.title, 'Groceries');
    expect(note.body, '');
    expect(note.dirty, isFalse);
  });

  test('dirty flag survives serialization', () {
    final note = Note(
      title: 'a',
      updatedAt: DateTime(2026, 9, 18),
      dirty: true,
    );
    final restored = Note.fromMap(note.toMap());
    expect(restored.dirty, isTrue);
  });

  test('provider succeeds with a fake repository', () async {
    final container = ProviderContainer(
      overrides: [
        noteRepositoryProvider.overrideWithValue(
          FakeNoteRepository(items: [
            Note(title: 'Test', updatedAt: DateTime.now()),
          ]),
        ),
      ],
    );
    addTearDown(container.dispose);
    final notes = await container.read(notesProvider.future);
    expect(notes.length, 1);
    expect(notes.first.title, 'Test');
  });

  test('provider fails with a fake repository', () async {
    final container = ProviderContainer(
      overrides: [
        noteRepositoryProvider.overrideWithValue(
          FakeNoteRepository(throwError: true),
        ),
      ],
    );
    addTearDown(container.dispose);
    await expectLater(
      container.read(notesProvider.future),
      throwsA(isA<Exception>()),
    );
  });

  test('conflict rule: newer local write wins', () {
    final remote = Note(id: 1, title: 'remote', updatedAt: DateTime(2026, 9, 1));
    final local = Note(
      id: 1,
      title: 'local',
      updatedAt: DateTime(2026, 9, 2),
      dirty: true,
    );
    expect(resolveConflict(local: local, remote: remote).title, 'local');
  });

  test('conflict rule: newer remote wins, tie goes to remote', () {
    final local = Note(id: 1, title: 'local', updatedAt: DateTime(2026, 9, 1));
    final remote = Note(id: 1, title: 'remote', updatedAt: DateTime(2026, 9, 1));
    expect(resolveConflict(local: local, remote: remote).title, 'remote');
    final newerRemote =
        Note(id: 1, title: 'remote2', updatedAt: DateTime(2026, 9, 3));
    expect(resolveConflict(local: local, remote: newerRemote).title, 'remote2');
  });
}