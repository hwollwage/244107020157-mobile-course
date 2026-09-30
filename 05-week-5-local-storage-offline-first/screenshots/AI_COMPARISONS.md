# Flutter Offline Notes — Local Storage Decision Report

---

## 1. AI Prompt Used

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

This prompt was given to an AI coding assistant (Claude) as instructed by the codelab.

---

## 2. Initial AI Output (Summary)

The AI returned:
- A comparison table of the 4 storage options across 6 criteria (query complexity, relational needs, reactivity, type-safety, boilerplate, testability).
- A recommendation: **SharedPreferences** for theme preference, **Drift** for notes (1000+).
- A single-table Drift schema with added `isDirty` and `updatedAt` columns for future sync support.
- A `watchAllNotes()` code example using Drift's built-in `.watch()` as evidence for the reactivity claim.
- A trade-off explanation for each option (SharedPreferences, Hive, sqflite, Drift).


---

## 3. Verification Results — AI Verification Checklist

| # | Checklist Question | Finding |
|---|---|---|
| 1 | Did the AI put the note list in SharedPreferences? | **No.** The AI explicitly rejected this option for 1000+ notes, since it would mean rewriting one giant JSON blob on every small edit. |
| 2 | Does the AI's schema support a sync queue (dirty flag / updated_at), or only plain CRUD? | **Supported.** The Drift schema includes an `isDirty` column (boolean, defaults to `true`) and `updatedAt` (defaults to `currentDateAndTime`) — not just plain CRUD. |
| 3 | Is the AI's "real-time" claim backed by an actual stream (Drift/watch), or just assumed? | **Backed by real code**, not assumed. The AI provided a working `.watch()` example in `watchAllNotes()`, which is a genuine Drift API, not an empty claim. |
| 4 | Is the AI's boilerplate estimate realistic once you actually try the install (`flutter pub add` + schema migration)? | **Needs manual verification** — not yet validated with a real install.


---

## 4. Final Comparison Table

| Criteria | SharedPreferences | Hive | sqflite (SQLite) | Drift |
|---|---|---|---|---|
| Query complexity | None (key/value get/set only) | Limited (manual filtering in Dart) | Full (SQL: JOIN, WHERE, ORDER BY) | Full (SQL via type-safe query builder) |
| Relational needs | Not supported | Not native (manual reference keys) | Native (foreign keys) | Native + type-safe |
| Reactivity (streams) | None built-in | Yes (`box.watch()`) | None built-in (needs manual `StreamController`) | Built-in (`.watch()` per query) |
| Type-safety | Low (everything via string keys) | Medium (`TypeAdapter` + codegen) | Low (raw `Map<String, dynamic>`) | High (generated Dart classes, compile-time column errors) |
| Boilerplate size | Very small | Small–medium | Medium–large (raw SQL strings + manual mapping) | Medium upfront (`build_runner`), small per query after |
| Testability | Easy | Medium | Medium (`sqflite_common_ffi`) | Easy (`NativeDatabase.memory()`) |

### AI's Final Recommendation

| Need | Choice | Reason |
|---|---|---|
| Theme preference | **SharedPreferences** | Just 1–2 flat key-value pairs, no query/relation needs — a database would be overkill |
| Notes (1000+) | **Drift** | Needs real filtering/sorting at scale, built-in reactive streams, and type-safety as the schema grows |
