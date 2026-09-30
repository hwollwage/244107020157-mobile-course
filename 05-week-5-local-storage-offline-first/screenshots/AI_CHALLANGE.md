# Week 5: AI Challenge

## Prompt used
```
Flutter Offline Notes app: note CRUD + theme preference.
Compare SharedPreferences, Hive, sqflite (SQLite), and Drift
for these two needs. Requirements:
- Criteria: query complexity, relational needs, reactivity (streams),
  type-safety, boilerplate size, and testability.
- Give a final recommendation: which for preferences, which for notes,
  with reasons in one table.
- Show the table/box schema for 1000+ notes.
Explain the trade-off of each choice.
```

## Initial AI output
✏️ Paste the raw output from your AI assistant here.

## Final comparison table
| Criteria         | SharedPreferences | Hive                | sqflite (SQLite)             | Drift                       |
|------------------|-------------------|---------------------|------------------------------|-----------------------------|
| Query complexity | None (key lookup) | Manual filter in Dart | Full SQL (WHERE/ORDER/JOIN) | SQL via type-safe DSL       |
| Relational needs | No                | Manual references   | Native (FK, JOIN)            | Native                      |
| Reactivity       | No                | Yes (listenable)    | None built in (manual invalidate) | Built-in streams (`watch`) |
| Type-safety      | Primitives only   | TypeAdapters        | Maps, manual `fromMap`       | Checked at compile time     |
| Boilerplate      | Very small        | Medium (adapters)   | Medium (SQL strings)         | Largest (build_runner)      |
| Testability      | Built-in mock     | Temp directory      | Fake repository              | In-memory database          |

## Final decision
- **Preferences:** SharedPreferences (small key-value settings).
- **Notes:** sqflite (SQLite). Drift is the upgrade path if streams or complex
  queries are needed later.

## Schema for 1000+ notes
**SQLite (chosen):**
```sql
CREATE TABLE notes(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,
  body TEXT NOT NULL DEFAULT '',
  updated_at TEXT NOT NULL,
  dirty INTEGER NOT NULL DEFAULT 0
);
CREATE INDEX idx_notes_updated ON notes(updated_at DESC);
CREATE INDEX idx_notes_dirty ON notes(dirty);
```
Hive: one `Box<Note>` named `notes`, int keys. Drift: `class Notes extends Table`.

## Verification checklist
- **Note list in SharedPreferences?** Rejected. A single JSON blob is fragile
  for queries, partial updates, and sync.
- **Schema supports a sync queue?** Yes: `dirty` and `updated_at`. Plain CRUD
  alone would not be enough.
- **"Real-time" claim backed by streams?** sqflite has no streams; I use
  `ref.invalidate` after each mutation. Real streams exist only in Drift/Hive.
- **Boilerplate estimate realistic?** ✏️ Fill in after trying the installs
  (sqflite needs only `flutter pub add`; Drift needs build_runner and migrations).
- **Part of the AI recommendation I rejected:** ✏️ Example: the AI recommended
  Drift for notes. I chose sqflite because the app is small, Drift's boilerplate
  is not worth it here, and `ref.invalidate` covers the reactivity I need.

## Test results
✏️ Paste the output of `flutter analyze` and `flutter test`.