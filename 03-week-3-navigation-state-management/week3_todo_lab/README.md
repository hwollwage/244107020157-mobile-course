# AI Challenge — StatsPage (flutter_riverpod)

## 1. Prompt used

```
Create a Flutter page named StatsPage using flutter_riverpod.
Requirements:
- A ConsumerWidget with one AsyncNotifierProvider that simulates
  fetching statistics (2-second delay, ~30% chance of failure).
- The UI must handle loading (spinner), error (message + retry button),
  and success (ListView with 3 items).
- Provide a unit test for the notifier.
Explain each part of the code with comments.
```

AI assistant used: Claude (chat).

## 2. Initial AI output

See `initial/stats_page.dart` and `initial/stats_page_test.dart` — the
first version generated directly from the prompt above, before manual
review.

## 3. Verification checklist results

| # | Item | Result | Evidence |
|---|------|--------|----------|
| 1 | State mutated immutably | ✅ Pass | `retry()` fully replaces `state` (`state = AsyncValue.loading()`, then `state = await AsyncValue.guard(...)`); no `state.add()` / in-place list mutation. |
| 2 | `ref.watch` only in `build`, `ref.read` in callbacks | ✅ Pass | `ref.watch(statsProvider)` used once in `StatsPage.build`. `ref.read(statsProvider.notifier).retry()` used only inside the `onPressed` callback. |
| 3 | All 3 `AsyncValue` states handled | ✅ Pass | `.when(loading:, error:, data:)` — Dart requires all three named params, so a missing branch would be a compile error, not just a review nit. |
| 4 | Provider explicit type, not duplicated | ✅ Pass | `final statsProvider = AsyncNotifierProvider<StatsNotifier, List<Stat>>(StatsNotifier.new);` — single provider, explicit generics. |
| 5 | No old Riverpod APIs (`StateProvider`, deprecated `StateNotifierProvider`, nested `Consumer`) | ✅ Pass | Uses `AsyncNotifier` + `ConsumerWidget` directly; no `StateNotifierProvider`/`StateProvider`/nested `Consumer` found. |
| 6 | `flutter analyze` / `flutter test` clean | ⚠️ **Not run automatically** — no Flutter SDK available in the dev sandbox used for this exercise. Verified manually instead (see below). Re-run both commands locally before submitting and paste the terminal output here. |

## 4. Bugs found during manual review (item 6)

The AI's *first* test file (`initial/stats_page_test.dart`) had two real
issues that would not have been caught just by reading it casually:

1. **Unsafe `catchError`.**
   ```dart
   await container.read(statsProvider.notifier).future.catchError((_) {});
   ```
   `Future<List<Stat>>` is non-nullable, but the handler returns `null` —
   this throws at runtime ("onError callback must return a value of the
   future's type"). Silently "looked fine" in a code read-through; only
   surfaced when reasoning about Dart's `catchError` typing rules.

2. **Weak/dishonest recovery assertion.**
   ```dart
   expect(state, anyOf(isA<AsyncData<...>>(), isA<AsyncError<...>>()));
   ```
   Because the original test reused a single `_FixedRandom(0.1)` for both
   the initial `build()` and the `retry()` call, `retry()` was
   *guaranteed* to fail again — yet the assertion accepted either
   outcome, so the test could never fail even if `retry()` were broken.
   This is a "false green" test.

## 5. Fixes applied

- Replaced `catchError((_) {})` with an explicit `try { ... } catch (_) { }`
  block around the awaited future.
- Added `_ScriptedRandom`, a fake `Random` that returns a *sequence* of
  values (`[0.1, 0.9]`) so the initial build is scripted to fail and the
  subsequent `retry()` is scripted to succeed. The test now asserts the
  *specific* expected end state (`AsyncData` with 3 items), not "either
  state is acceptable."
- Kept `_FixedRandom` for the two simple isolated success/failure tests,
  since those don't need a sequence.

Fixed files: `stats_page.dart` (unchanged from initial — no bugs found
in the widget/notifier itself), `stats_page_test.dart` (revised).

## 5b. Additional issue found: Riverpod 3.x automatic retry

Discovered while actually running `flutter test` against the real project
(`flutter_riverpod: 3.4.3` — much newer than assumed): Riverpod 3.0+
automatically retries a failing provider's `build()` with exponential
backoff, **repeatedly, until it succeeds or the provider is disposed** —
not a fixed number of attempts. Two consequences:

1. **Test hangs.** Reading `container.read(statsProvider.notifier).future`
   (an internal/protected member not meant for external use) on a
   provider scripted to always fail meant it retried indefinitely,
   causing a 30s test timeout and a `StateError` when `dispose()` ran
   mid-retry.
2. **Conflicts with the assignment's own requirement.** The task requires
   a visible error + manual Retry button. Riverpod's silent background
   auto-retry would otherwise often resolve failures before the user ever
   sees the error UI, defeating the point of the exercise.

**Fix:** disabled Riverpod's built-in retry specifically on this provider
via `retry: (retryCount, error) => null` in `statsProvider`'s
declaration, and switched tests to the public `statsProvider.future`
API instead of `statsProvider.notifier.future`.

We initially tried asserting `throwsA(isA<ProviderException>())` on the
wrapped error (per Riverpod's own migration docs), but hit a compile
error: `ProviderException` is not actually importable from
`package:flutter_riverpod` as of `3.4.3` — this is a known, still-open
upstream bug (https://github.com/rrousselGit/riverpod/issues/4320), not
a mistake in our code. Worked around it by not depending on that type at
all: catch the `.future` failure generically, then assert on the
*specific* original exception via `AsyncValue.error`, which Riverpod
3.x's own docs confirm is **not** wrapped (only `.future`/`.read`
throwing is wrapped). This is arguably the more meaningful assertion
anyway, since it's exactly what the UI's `.when(error: ...)` branch
receives.

Source: https://riverpod.dev/docs/whats_new and
https://riverpod.dev/docs/3.0_migration

## 6. Test results

Automated `flutter test` output could not be captured in this
environment (no Flutter SDK installed on this machine). To complete this
section before submission:

```bash
flutter analyze
flutter test test/stats_page_test.dart
```

and paste the console output here, e.g.:

```
Analyzing stats_feature...
No issues found!

00:02 +3: All tests passed!
```

## 7. What I can personally explain during the demo

- Why `AsyncNotifier.build()` replaces manual loading-flag bookkeeping.
- Why `AsyncValue.guard` is used in `retry()` instead of manual try/catch.
- Why `ref.watch` vs `ref.read` matters (rebuild subscription vs one-off
  read) and where each is used in this file.
- Why the original test's `catchError` and `anyOf` assertion were bugs,
  and how the scripted-random fix makes the recovery test meaningful.