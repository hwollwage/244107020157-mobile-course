# Performance Report — Week 11

## Project

**Campus Notify** — Week 11 Performance Optimization  

---

## 1. Baseline Metrics

Measured with `flutter run --profile` on a mid-range Android emulator (Pixel 5 API 34).

| Metric | Baseline value |
|---|---|
| Average UI-thread frame time | ~22 ms (target: <16 ms) |
| Jank frame count (>16 ms) during 30 s scroll | ~18 frames |
| Peak heap during Notes scroll (50 items) | ~95 MB |
| Peak heap during AI streaming (10 messages) | ~88 MB |
| Image memory on AnnouncementPage open | ~6–8 MB per visit (no disk cache) |

> Screenshot: `../screenshots/before-profile.png`

---

## 2. Profiling Findings

See [`performance-findings.md`](./performance-findings.md) for the full detail.  
Summary of identified issues:

| # | Issue | Location | Impact |
|---|---|---|---|
| 1 | Eager list build — `Column` + `map().toList()` builds all tiles | `notes_page.dart` | 18–25 ms build time per add-note submit |
| 2 | No `RepaintBoundary` around chat list | `chat_screen.dart` | Full-page raster on every AI streaming tick |
| 3 | No image disk cache (`Image.network`) | `announcement_page.dart` | Re-download + full-res bitmap in memory every visit |
| 4 | `ref.watch(provider)` on full state object | `chat_screen.dart`, `notes_page.dart` | Unnecessary rebuilds of unrelated widgets |

---

## 3. Applied Optimizations

### 3.1 — SliverList.builder (Lazy Rendering)

**File:** `lib/features/notes/presentation/pages/notes_page.dart`

**Before:**
```dart
// Eager — all tiles built at once regardless of scroll position
Column(
  children: state.visibleNotes.map<Widget>((note) {
    return Card(child: ListTile(...));
  }).toList(),
)
```

**After:**
```dart
// Lazy — only tiles in the viewport are built
SliverList.builder(
  itemCount: notes.length,
  itemBuilder: (context, index) => _NoteTile(note: notes[index]),
)
```

**Rationale:** `SliverList.builder` defers the creation of off-screen items until the user scrolls to them. For a list of 50+ notes this reduces the initial build time from O(n) to O(visible items).

---

### 3.2 — Extracted Const-Constructible Widgets

**Files:** `notes_page.dart`, `home_page.dart`, `chat_screen.dart`

**Before:** Large inline `build()` methods with anonymous widget trees — no reuse possible.

**After:** Separate classes `_NoteTile`, `_NoteEditor`, `_SearchField`, `_NotesList`, `_SubscriptionCard`, `_MessageBubble`.

**Rationale:** Flutter's element reconciliation can skip rebuilding a subtree if the widget type, key, and constructor arguments are identical to the previous frame. Anonymous inline trees always look "new" to the reconciler. Separate classes with `const` constructors give Flutter the information it needs to short-circuit.

Example:
```dart
// Before: new closure on every parent build
itemBuilder: (context, index) {
  return Card(child: ListTile(title: Text(notes[index].title)));
}

// After: stable type identity, reconciler can diff efficiently
itemBuilder: (context, index) => _NoteTile(note: notes[index])
```

---

### 3.3 — Riverpod `.select()` to Narrow Rebuild Scope

**Files:** `notes_page.dart`, `chat_screen.dart`

**Before:**
```dart
// Rebuilds the whole page whenever any field on ChatState changes
final chat = ref.watch(chatProvider);
```

**After:**
```dart
// Each expression rebuilds only the widget that needs it
final messages   = ref.watch(chatProvider.select((s) => s.messages));
final isLoading  = ref.watch(chatProvider.select((s) => s.isLoading));
final error      = ref.watch(chatProvider.select((s) => s.error));

// In NotesPage — editor only rebuilds on isSaving/failure, not list changes
final isSaving = ref.watch(notesProvider.select((s) => s.isSaving));
final failure  = ref.watch(notesProvider.select((s) => s.failure));
```

**Rationale:** During AI streaming `ChatState` updates ~15 times per second (one per token). Without `.select()`, the entire `ChatScreen` rebuilds 15 times/s. With `.select()`, only the `_NotesList` consumer (which watches `messages`) rebuilds — the AppBar, input row, and error banner are skipped entirely.

---

### 3.4 — RepaintBoundary Around the Chat Message List

**File:** `lib/features/chat/presentation/pages/chat_screen.dart`

**Before:**
```dart
ListView.builder(
  controller: _scrollController,
  itemCount: messages.length,
  itemBuilder: (_, i) => _MessageBubble(message: messages[i]),
)
```

**After:**
```dart
RepaintBoundary(
  child: ListView.builder(
    controller: _scrollController,
    itemCount: messages.length,
    itemBuilder: (_, i) => _MessageBubble(message: messages[i]),
  ),
)
```

**Rationale:** `RepaintBoundary` creates an isolated layer in the render tree. When only the last message bubble changes (new streaming token), only the pixels inside the boundary are re-rasterized. The AppBar, input row, and MaterialBanner sit on a separate layer and are composited without re-painting.

---

### 3.5 — CachedNetworkImage with memCache Sizing

**File:** `lib/features/notifications/presentation/pages/announcement_page.dart`

**Before:**
```dart
Image.network(imageUrl)  // no cache, full-res bitmap in memory
```

**After:**
```dart
CachedNetworkImage(
  imageUrl: imageUrl,
  memCacheWidth: MediaQuery.sizeOf(context).width.toInt(),
  memCacheHeight: 200,
  fadeInDuration: const Duration(milliseconds: 200),
  placeholder: (_, __) => const Center(child: CircularProgressIndicator()),
  errorWidget: (_, __, ___) => const Icon(Icons.broken_image_outlined),
)
```

**Rationale:**
- Disk cache: the image is downloaded once and served from disk on subsequent visits — zero extra bandwidth.
- `memCacheWidth` / `memCacheHeight`: the codec decodes the image at display size, not full resolution. A 1920×1080 source decoded at 400×200 uses ~8× less memory.
- `placeholder` / `errorWidget`: eliminates layout jumps and provides graceful fallback.

---

## 4. Verification Results

After applying all optimizations:

```bash
flutter analyze
# No issues found!

flutter test
# All tests passed.
```

| Metric | Before | After | Δ |
|---|---|---|---|
| Average UI-thread frame time | ~22 ms | ~11 ms | −50% |
| Jank frame count (30 s scroll) | ~18 | ~4 | −78% |
| Notes list initial build (50 items) | ~22 ms | ~6 ms | −73% |
| Peak heap during AI streaming | ~88 MB | ~74 MB | −16% |
| Image memory on AnnouncementPage | ~7 MB/visit | ~1.2 MB (cached) | −83% |

> Screenshots: `../screenshots/after-profile.png`, `../screenshots/memory-snapshot-before.png`, `../screenshots/memory-snapshot-after.png`

---

## 5. Memory Profiling (Step 5)

**Procedure:**
1. Open DevTools → Memory tab
2. Take a Heap Snapshot on the Notes list page
3. Navigate: Notes → Home → Notes → Home (repeat 5×)
4. Take a second snapshot
5. Compare: filter for `_NotesPageState`, `ScrollController`, `TextEditingController`

**Findings:**
- No accumulating `_NotesPageState` instances — `dispose()` correctly frees all three `TextEditingController`s and the scroll controller.
- `ImageCache` size stable at ~2 MB after the first `CachedNetworkImage` load (disk cache prevents repeated heap allocations).
- No growing `StreamSubscription` instances — `HomePage`'s `tokenRefreshes.listen()` subscription is cleaned up by the `ConsumerStatefulWidget` lifecycle.

---

## 6. Reflection

**Which optimization had the biggest impact?**  
`SliverList.builder` + `Riverpod .select()` together had the largest measurable impact. The eager `Column` + `map().toList()` pattern caused O(n) work on every state update. Combined with broad `ref.watch()`, even a "save note" action triggered a full re-layout of every note tile. After both fixes the build phase for the notes screen dropped from ~22 ms to ~6 ms.

**How was verification done?**  
Flutter DevTools Performance tab was used to record the same interaction scenario before and after each optimization. Flame Charts were compared frame-by-frame. `flutter analyze` confirmed no regressions in static analysis.

**Trade-offs faced:**  
Extracting widgets into separate classes (`_NoteTile`, `_NotesList`, etc.) adds file length and nesting. This is a worthwhile trade-off: the extra classes are small, clearly named, and each has a single responsibility. The alternative (keeping everything inline) is shorter to write but harder to profile and maintain.

**When should premature optimization be avoided?**  
Before profiling. Techniques like `RepaintBoundary` on every widget, or `select()` on every provider, add cognitive overhead without guaranteed benefit. The correct workflow is: measure first with DevTools, identify the actual hot path, then apply the targeted fix. The bottleneck is rarely where intuition says it is.
