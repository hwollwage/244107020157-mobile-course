import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:week3_todo_lab/pages/stats_page.dart';

/// A fake `Random` that always returns a fixed value. Used to force the
/// ~30% failure branch deterministically for the isolated success/failure
/// tests below.
class _FixedRandom implements Random {
  final double fixedValue;
  const _FixedRandom(this.fixedValue);

  @override
  double nextDouble() => fixedValue;

  @override
  bool nextBool() => false;
  @override
  int nextInt(int max) => 0;
}

/// A fake `Random` that returns a *scripted sequence* of values, one per
/// call to `nextDouble()`. This is what actually lets us prove `retry()`
/// can transition AsyncError -> AsyncData, instead of just asserting
/// "either state is fine" (which the original test did, incorrectly).
class _ScriptedRandom implements Random {
  final List<double> _script;
  int _index = 0;
  _ScriptedRandom(this._script);

  @override
  double nextDouble() {
    // Clamp to the last scripted value if called more times than scripted,
    // rather than throwing RangeError — keeps tests robust to extra calls.
    final value = _script[_index < _script.length ? _index : _script.length - 1];
    _index++;
    return value;
  }

  @override
  bool nextBool() => false;
  @override
  int nextInt(int max) => 0;
}

void main() {
  group('StatsNotifier', () {
    test('build() returns 3 stats on "success" (random >= 0.3)', () async {
      final container = ProviderContainer(
        overrides: [
          statsProvider.overrideWith(
            () => StatsNotifier(random: const _FixedRandom(0.5)),
          ),
        ],
      );
      addTearDown(container.dispose);

      // `statsProvider.future` (the PROVIDER's future) — NOT
      // `statsProvider.notifier.future`, which is an internal/protected
      // member not meant for outside use and can behave unreliably
      // (this was the cause of a 30s timeout we hit during verification).
      final stats = await container.read(statsProvider.future);

      expect(stats, hasLength(3));
      expect(stats.first.label, 'Active Users');
      expect(container.read(statsProvider), isA<AsyncData<List<Stat>>>());
    });

    test('build() throws on "failure" (random < 0.3), producing AsyncError',
        () async {
      final container = ProviderContainer(
        overrides: [
          statsProvider.overrideWith(
            () => StatsNotifier(random: const _FixedRandom(0.1)),
          ),
        ],
      );
      addTearDown(container.dispose);

      // NOTE: We intentionally do NOT assert on `ProviderException` here.
      // Riverpod 3.x's docs describe errors read via `.future` as wrapped
      // in a ProviderException, but that type is not actually importable
      // as of riverpod 3.4.x — it's an open upstream bug:
      // https://github.com/rrousselGit/riverpod/issues/4320
      // So we just confirm *something* was thrown here...
      try {
        await container.read(statsProvider.future);
        fail('Expected the fetch to throw');
      } catch (_) {
        // expected — whatever wrapper type Riverpod uses internally
      }

      // ...and then assert on the SPECIFIC original exception via
      // AsyncValue.error, which Riverpod 3.x explicitly does NOT wrap
      // (only .future/.read throwing is wrapped). This is also exactly
      // what the UI's `.when(error: ...)` branch receives, so it's the
      // more meaningful assertion anyway.
      final state = container.read(statsProvider);
      expect(state, isA<AsyncError<List<Stat>>>());
      final error = (state as AsyncError<List<Stat>>).error;
      expect(error, isA<Exception>());
      expect(error.toString(), contains('Failed to load statistics'));
    });

    test('retry() actually recovers from AsyncError to AsyncData', () async {
      // Script: first call (initial build) fails, second call (retry)
      // succeeds. This is what proves recovery really works, rather than
      // asserting "any outcome is acceptable".
      final container = ProviderContainer(
        overrides: [
          statsProvider.overrideWith(
            () => StatsNotifier(random: _ScriptedRandom([0.1, 0.9])),
          ),
        ],
      );
      addTearDown(container.dispose);

      // try/catch instead of catchError((_) {}) — the latter previously
      // risked a runtime type error because the handler returned null for
      // a non-nullable Future<List<Stat>>. We don't check the exception
      // type here (already covered by the dedicated test above), just
      // that *something* was thrown for the scripted-fail attempt.
      try {
        await container.read(statsProvider.future);
        fail('Expected the initial build to throw');
      } catch (_) {
        // expected — initial build was scripted to fail
      }
      expect(container.read(statsProvider), isA<AsyncError<List<Stat>>>());

      // retry() flips to loading immediately, synchronously, before the
      // awaited Future resolves. Unlike build(), retry() assigns `state`
      // directly via AsyncValue.guard rather than going through the
      // provider's own build/computation cycle, so it is NOT affected by
      // the `retry:` (auto-retry-disable) option on the provider — that
      // option only governs automatic retries of build() failures.
      final retryFuture = container.read(statsProvider.notifier).retry();
      expect(container.read(statsProvider), isA<AsyncLoading<List<Stat>>>());

      await retryFuture;

      // Now we can assert the SPECIFIC expected outcome, not "either one".
      final state = container.read(statsProvider);
      expect(state, isA<AsyncData<List<Stat>>>());
      expect((state as AsyncData<List<Stat>>).value, hasLength(3));
    });
  });
}