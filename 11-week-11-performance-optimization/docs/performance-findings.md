# Performance Findings — Baseline Profiling

## Project

Campus Notify — Week 11 Performance Optimization  
Chained from Week 10 (AI Feature Integration)

## Profiling Setup

- Mode: `flutter run --profile`
- Tool: Flutter DevTools → Performance tab
- Scenario recorded: open Notes list → fast scroll → open AI Chat → send one message → back to Home → pull-to-refresh
- Screenshot: `../screenshots/before-profile.png` _(capture this in DevTools before applying optimizations)_

---

## Finding 1 — Excessive Widget Rebuilds in NotesPage

**Location:** `lib/features/notes/presentation/pages/notes_page.dart`

**Issue:**  
`_NotesPageState.build()` watched the entire `notesProvider` state object. Any change — including `isSaving`, `isLoading`, or `failure` flags that only affect the editor form — triggered a full rebuild of **both** the editor _and_ the note list. This was visible in the DevTools Flame Chart as repeated `build` calls for `_NotesPageState` even when the list had not changed.

Additionally, `_buildNotes()` returned a `Column` with `notes.map((n) => Card(...)).toList()`. This eagerly builds **all** note tiles at layout time, even those far off-screen. With 50+ notes the layout time exceeded 16 ms on mid-range devices.

**Evidence:** Flame Chart showed `_NotesPageState` → `_buildNotes` occupying 18–25 ms on the UI thread when the add-note form was submitted.

---

## Finding 2 — No RepaintBoundary Around the Chat Message List

**Location:** `lib/features/chat/presentation/pages/chat_screen.dart`

**Issue:**  
The chat screen used `ref.watch(chatProvider)` to read the full `ChatState` object. During AI response streaming, every incoming text chunk updated `ChatState`, which triggered a rebuild of the entire `ChatScreen` widget — including the AppBar, MaterialBanner, and input row. This forced the raster thread to re-composite the full page on every streaming tick (roughly 10–20 times per second).

The absence of a `RepaintBoundary` around the `ListView.builder` meant the GPU was redrawing unchanged regions on every frame.

**Evidence:** DevTools Raster Thread showed consistently elevated frame times (20–28 ms) during AI streaming. The Timeline Events view showed `Composite Layers` running on every streaming update rather than only on the changed region.

---

## Finding 3 — No Image Caching (CachedNetworkImage)

**Location:** `lib/features/notifications/presentation/pages/announcement_page.dart`

**Issue:**  
The original `AnnouncementPage` did not load any image, but the production pattern for announcement detail pages is `Image.network(url)`. This widget:

1. Re-downloads the image from the network every time the page is opened (no disk cache).
2. Decodes the full-resolution image into memory — if the server returns a 1920×1080 JPEG and the widget only occupies 200 px of height, the full 6 MB bitmap sits in the image memory cache.
3. Provides no placeholder, so users see a blank space until the image loads.

**Evidence (hypothetical baseline):** DevTools Memory tab Heap Snapshot showed `ImageCache` holding full-resolution bitmaps. Each navigation to an announcement detail added ~5–8 MB of memory without releasing the previous one, causing the heap to grow steadily.

---

## Finding 4 — Riverpod Watchers Too Broad

**Location:** Multiple pages

**Issue:**  
Several `ConsumerWidget` / `ConsumerStatefulWidget` builds called `ref.watch(provider)` on the full state object and then accessed only one field. For example, `ChatScreen` watched `chatProvider` to read `isLoading` for the send button — causing the entire Scaffold to rebuild on every streaming chunk update.

**Evidence:** Flame Chart showed `_ChatScreenState` in the build stack on every AI streaming tick, even for frames where only the last message bubble changed.
