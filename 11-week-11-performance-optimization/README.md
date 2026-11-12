# Campus Notify — Week 11: Performance Optimization

Flutter project chained from Weeks 7–10. This week focuses on identifying and
fixing performance bottlenecks using Flutter DevTools and established
optimization techniques.

## Features

- **Push Notifications** — FCM topic subscribe/unsubscribe, foreground banners,
  deep-link routing from notification tap.
- **Notes** — Local SQLite CRUD with search filtering.
- **AI Chat** — Streaming Gemini responses with in-memory LRU answer cache and
  PII redaction.
- **Announcement Detail** — Deep-link target with optimized network image loading.

## Performance Optimizations Applied

| Technique | Location | Impact |
|---|---|---|
| `SliverList.builder` (lazy rendering) | `notes_page.dart` | Builds only visible note tiles — O(viewport) instead of O(n) |
| Extracted const widgets (`_NoteTile`, `_NotesList`, etc.) | `notes_page.dart`, `home_page.dart`, `chat_screen.dart` | Stable element identity; Flutter skips rebuild when params unchanged |
| Riverpod `.select()` | `notes_page.dart`, `chat_screen.dart` | Each widget rebuilds only when its specific slice of state changes |
| `RepaintBoundary` around chat list | `chat_screen.dart` | Isolates AI-streaming repaints from AppBar and input row |
| `CachedNetworkImage` with `memCacheWidth/Height` | `announcement_page.dart` | Disk caches images; decodes at display size to cut memory use ~83% |

Full findings and before/after metrics: [`docs/performance-report.md`](docs/performance-report.md)

## Project Structure

```
lib/
├── main.dart                        # App entry, Firebase init, Riverpod overrides
├── routing/routes.dart              # Centralised route constants
├── core/
│   ├── failures.dart                # Sealed Failure types
│   ├── api_errors.dart              # Dio → Failure mapping
│   └── format.dart                  # formatDateTime, routeFromMessage
├── ai/ai_service.dart               # Gemini SSE streaming service
└── features/
    ├── auth/                        # Login, JWT token store, auth guard
    ├── notifications/               # FCM, local notifications, HomePage
    ├── notes/                       # SQLite notes CRUD, search
    └── chat/                        # AI chat screen, sanitizer, LRU cache
```

## Running the App

```bash
# Debug
flutter run

# Profile mode (required for accurate DevTools profiling)
flutter run --profile
```

## Code Quality

```bash
flutter analyze   # No issues
flutter test      # All tests pass
```

## Docs & Screenshots

- [`docs/performance-findings.md`](docs/performance-findings.md) — Baseline profiling findings (4 issues identified)
- [`docs/performance-report.md`](docs/performance-report.md) — Full report with before/after metrics, optimizations, and reflection
- [`screenshots/`](screenshots/) — DevTools Flame Chart screenshots _(see `screenshots/README.md` for capture instructions)_

## Dependencies

| Package | Purpose |
|---|---|
| `flutter_riverpod` | State management |
| `go_router` | Declarative routing + auth guard |
| `firebase_core` + `firebase_messaging` | FCM push notifications |
| `flutter_local_notifications` | Foreground notification banners |
| `flutter_secure_storage` | Secure token + API key storage |
| `dio` | HTTP client with JWT refresh interceptor |
| `sqflite` | Local SQLite database (notes) |
| `http` | Gemini SSE streaming |
| `cached_network_image` | ✨ **New (Week 11)** — disk-cached images with memory sizing |
