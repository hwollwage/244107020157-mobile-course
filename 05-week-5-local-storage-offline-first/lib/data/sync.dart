import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import 'local/db.dart';
import 'local/note.dart';
import 'models/post.dart';
import 'providers.dart';
import 'repositories/note_repositoriy.dart';

class ForceOfflineNotifier extends Notifier<bool> {
  @override
  bool build() => false;
  void set(bool value) => state = value;
}

final forceOfflineProvider =
    NotifierProvider<ForceOfflineNotifier, bool>(ForceOfflineNotifier.new);

class OfflineException implements Exception {
  const OfflineException();
}

Note resolveConflict({required Note local, required Note remote}) {
  return local.updatedAt.isAfter(remote.updatedAt) ? local : remote;
}

Future<int> syncNotes(NoteRepository repo) async {
  final dirtyCount = await repo.countDirty();
  if (dirtyCount == 0) return 0;
  await Future.delayed(const Duration(seconds: 1));
  await repo.markAllSynced();
  return dirtyCount;
}

class SyncController {
  SyncController(this._ref);
  final Ref _ref;

  Future<int> sync() async {
    if (_ref.read(forceOfflineProvider)) throw const OfflineException();
    final count = await syncNotes(_ref.read(noteRepositoryProvider));
    _ref.invalidate(notesProvider);
    _ref.invalidate(dirtyCountProvider);
    return count;
  }
}

final syncControllerProvider = Provider((ref) => SyncController(ref));

class PostCacheRepository {
  PostCacheRepository({Future<Database> Function()? openDb})
      : _openDb = openDb ?? openNotesDb;

  final Future<Database> Function() _openDb;

  Future<List<Post>> readCachedPosts() async {
    final db = await _openDb();
    final rows = await db.query('cached_posts', orderBy: 'id ASC');
    return rows.map((row) {
      final decoded = jsonDecode(row['payload'] as String? ?? '{}');
      return Post.fromJson(decoded as Map<String, dynamic>);
    }).toList();
  }

  Future<void> savePosts(List<Post> posts) async {
    final db = await _openDb();
    final now = DateTime.now().toIso8601String();
    await db.transaction((txn) async {
      await txn.delete('cached_posts');
      final batch = txn.batch();
      for (final post in posts) {
        batch.insert(
          'cached_posts',
          {
            'id': post.id,
            'payload': jsonEncode(post.toJson()),
            'cached_at': now,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    });
  }
}

final postCacheRepositoryProvider =
    Provider<PostCacheRepository>((ref) => PostCacheRepository());

class CachedPostsNotifier extends AsyncNotifier<List<Post>> {
  @override
  Future<List<Post>> build() async {
    final cached = await ref.read(postCacheRepositoryProvider).readCachedPosts();
    if (cached.isNotEmpty) {
      Future.microtask(_refreshInBackground);
      return cached;
    }
    return _fetchAndPersist();
  }

  Future<List<Post>> _fetchAndPersist() async {
    if (ref.read(forceOfflineProvider)) {
      throw DioException(
        requestOptions: RequestOptions(path: '/posts'),
        type: DioExceptionType.connectionError,
      );
    }
    final posts = await ref.read(postRepositoryProvider).fetchPosts();
    await ref.read(postCacheRepositoryProvider).savePosts(posts);
    return posts;
  }

  Future<void> _refreshInBackground() async {
    try {
      final fresh = await _fetchAndPersist();
      if (!ref.mounted) return;
      state = AsyncData(fresh);
    } catch (_) {
    }
  }

  Future<bool> refresh() async {
    try {
      final fresh = await _fetchAndPersist();
      if (!ref.mounted) return false;
      state = AsyncData(fresh);
      return true;
    } catch (e, st) {
      if (!ref.mounted) return false;
      if (state.value == null || state.value!.isEmpty) {
        state = AsyncError(e, st);
      }
      return false;
    }
  }
}

final cachedPostsProvider =
    AsyncNotifierProvider<CachedPostsNotifier, List<Post>>(
  CachedPostsNotifier.new,
  retry: (retryCount, error) => null,
);