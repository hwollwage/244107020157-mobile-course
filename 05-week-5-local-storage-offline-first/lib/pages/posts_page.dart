import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/providers.dart';
import '../data/sync.dart';

class PostsPage extends ConsumerWidget {
  const PostsPage({super.key});

  Future<void> _refresh(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final ok = await ref.read(cachedPostsProvider.notifier).refresh();
    if (!ok) {
      messenger.showSnackBar(const SnackBar(
        content: Text('Tidak bisa refresh, menampilkan data cache'),
      ));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(cachedPostsProvider);
    final offline = ref.watch(forceOfflineProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Posts (cache-first)'),
        actions: [
          if (offline) const Icon(Icons.cloud_off),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _refresh(context, ref),
          ),
        ],
      ),
      body: postsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(friendlyErrorMessage(err), textAlign: TextAlign.center),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () => ref.invalidate(cachedPostsProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (posts) {
          if (posts.isEmpty) {
            return const Center(child: Text('No data yet.'));
          }
          return RefreshIndicator(
            onRefresh: () => _refresh(context, ref),
            child: ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                return ListTile(
                  leading: CircleAvatar(child: Text(post.id.toString())),
                  title: Text(post.title,
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Text(post.body,
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                );
              },
            ),
          );
        },
      ),
    );
  }
}