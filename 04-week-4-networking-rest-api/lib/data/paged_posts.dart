import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers.dart';
import 'models/post.dart';

class PagedPostsState {
  final List<Post> items;
  final int page;
  final bool isLoadingMore;
  final bool hasMore;
  final Object? error;
  
  const PagedPostsState({
    this.items = const [],
    this.page = 0,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.error,
  });
}

class PagedPostsNotifier extends Notifier<PagedPostsState> {
  @override
  PagedPostsState build() {
    return const PagedPostsState();
  }

  Future<void> loadFirstPage() async {
    state = const PagedPostsState(isLoadingMore: true);
    final repository = ref.read(postRepositoryProvider);

    try {
      final items = await repository.fetchPostsPage(page: 1, limit: 10);
      state = PagedPostsState(items: items, page: 1, hasMore: items.length == 10);
    } catch (e) {
      state = PagedPostsState(error: e);
    }
  }

  Future<void> loadNextPage() async {
    if(state.isLoadingMore || !state.hasMore) return;
    final repo = ref.read(postRepositoryProvider);
    final currentItems = state.items;
    final currentPage = state.page;

    state = PagedPostsState(
      items: currentItems,
      page: currentPage,
      isLoadingMore: true,
      hasMore: state.hasMore,
    );

    try {
      final next = currentPage + 1;
      final items = await repo.fetchPostsPage(page: next, limit: 10);
      state = PagedPostsState(
        items: [...currentItems, ...items],
        page: next,
        hasMore: items.length == 10,
      );
    } catch(e) {
      state = PagedPostsState(
        items: currentItems,
        page: currentPage,
        error: e
      );
    }
  }
}

final pagedPostsProvider = NotifierProvider<PagedPostsNotifier, PagedPostsState>(PagedPostsNotifier.new);