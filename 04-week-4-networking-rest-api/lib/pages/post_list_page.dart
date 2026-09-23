import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rest_api/data/providers.dart';

class PostListPage extends ConsumerWidget {
  const PostListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postAsync = ref.watch(postListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('posts api'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => ref.read(postListProvider.notifier).refresh(),
          ),
        ],
      ),

      body: postAsync.when(
        data: (posts) {
          if(posts.isEmpty) {
            return const Center(
              child: Text('no data from server'),
            );
          }
          return RefreshIndicator(
            onRefresh: () => ref.read(postListProvider.notifier).refresh(),
            child: ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                return ListTile(
                  leading: CircleAvatar(child: Text(post.id.toString()),),
                  title: Text(post.title, maxLines: 1, overflow: TextOverflow.ellipsis,),
                  subtitle: Text(post.body, maxLines: 2, overflow: TextOverflow.ellipsis,),
                );
              },
            ),
          );
        },
        
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: .min,
              children: [
                Text(friendlyErrorMessage(err), textAlign: TextAlign.center,),

                const SizedBox(height: 12,),

                FilledButton(
                  onPressed: () => ref.invalidate(postListProvider),
                  child: Text('try again'),
                ),
              ],
            )
          ),
        ),

        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
