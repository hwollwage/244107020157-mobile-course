import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ---------------------------------------------------------------------------
/// DOMAIN MODEL
/// ---------------------------------------------------------------------------
/// A tiny, immutable model representing one statistic row.
/// Kept simple on purpose — swap this out for your real API model.
class Stat {
  final String label;
  final int value;

  const Stat({required this.label, required this.value});
}

/// ---------------------------------------------------------------------------
/// ASYNC NOTIFIER
/// ---------------------------------------------------------------------------
/// `AsyncNotifier<T>` is Riverpod's recommended way to model "load some async
/// data, then let the UI (or other code) trigger a refresh/mutation".
///
/// - `build()` is called automatically the first time the provider is read,
///   and again whenever the provider is refreshed/invalidated. Whatever it
///   returns (or throws) becomes the notifier's `state`.
/// - Riverpod wraps that state in an `AsyncValue<T>`, which is a sealed-ish
///   union of `AsyncLoading`, `AsyncData`, and `AsyncError`. This is exactly
///   what lets the UI pattern-match on loading/error/success further down.
class StatsNotifier extends AsyncNotifier<List<Stat>> {
  /// Injectable random source so tests can force success/failure instead of
  /// depending on real randomness. Defaults to a normal Random() at runtime.
  final Random _random;

  StatsNotifier({Random? random}) : _random = random ?? Random();

  @override
  Future<List<Stat>> build() async {
    // `build()` IS the "fetch" — Riverpod automatically shows AsyncLoading
    // while this Future is pending, so we don't manage a loading flag
    // ourselves.
    return _fetchStats();
  }

  Future<List<Stat>> _fetchStats() async {
    // Simulate network latency.
    await Future.delayed(const Duration(seconds: 2));

    // Simulate a ~30% failure rate (e.g. flaky network / server error).
    // Throwing here is intentional: AsyncNotifier automatically converts an
    // uncaught exception during build() into an `AsyncError` state, which
    // the UI can react to without any try/catch on our part.
    if (_random.nextDouble() < 0.3) {
      throw Exception('Failed to load statistics. Please try again.');
    }

    // "Successful" fake payload — 3 items, as required by the UI spec.
    return const [
      Stat(label: 'Active Users', value: 1287),
      Stat(label: 'Sessions Today', value: 342),
      Stat(label: 'Errors Logged', value: 5),
    ];
  }

  /// Public method the UI calls for the "Retry" button.
  ///
  /// We set `state` to a loading value first (with `..isRefreshing` info
  /// preserved via `AsyncLoading()`), then re-run the fetch and guard it
  /// with `AsyncValue.guard`, which does the try/catch dance for us and
  /// produces either AsyncData or AsyncError.
  Future<void> retry() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_fetchStats);
  }
}

/// ---------------------------------------------------------------------------
/// PROVIDER
/// ---------------------------------------------------------------------------
/// `AsyncNotifierProvider` wires `StatsNotifier` into the Riverpod graph.
/// Widgets watch this provider to get an `AsyncValue<List<Stat>>`.
///
/// `retry: (retryCount, error) => null` disables Riverpod 3.x's built-in
/// automatic retry (which by default silently re-runs `build()` with
/// exponential backoff, forever, whenever it throws). We disable it here
/// because the assignment explicitly requires a visible error state with a
/// manual "Retry" button — the automatic background retry would otherwise
/// mask most failures from ever reaching the UI, and would fight with our
/// own `retry()` method.
final statsProvider = AsyncNotifierProvider<StatsNotifier, List<Stat>>(
  StatsNotifier.new,
  retry: (retryCount, error) => null,
);

/// ---------------------------------------------------------------------------
/// UI
/// ---------------------------------------------------------------------------
/// `ConsumerWidget` gives us a `WidgetRef ref` in `build()`, which is how
/// Riverpod widgets read/watch providers without needing StatefulWidget.
class StatsPage extends ConsumerWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // `ref.watch` subscribes this widget to the provider: whenever the
    // notifier's state changes (loading -> data / loading -> error, or a
    // retry cycle), this widget rebuilds automatically.
    final statsAsync = ref.watch(statsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Stats')),
      body: statsAsync.when(
        // ----- LOADING -----
        // Shown while build() (or retry()) has an in-flight Future.
        loading: () => const Center(child: CircularProgressIndicator()),

        // ----- ERROR -----
        // `error` is whatever was thrown (our Exception), `stackTrace` is
        // available too if you want to log it.
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 12),
                Text(
                  error.toString().replaceFirst('Exception: ', ''),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  // `ref.read` (not watch) inside a callback: we want to
                  // invoke the notifier's method once, not subscribe.
                  onPressed: () => ref.read(statsProvider.notifier).retry(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),

        // ----- SUCCESS -----
        // `data` is the List<Stat> returned by build()/retry().
        data: (stats) => ListView.builder(
          itemCount: stats.length,
          itemBuilder: (context, index) {
            final stat = stats[index];
            return ListTile(
              leading: const Icon(Icons.bar_chart),
              title: Text(stat.label),
              trailing: Text(
                '${stat.value}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            );
          },
        ),
      ),
    );
  }
}