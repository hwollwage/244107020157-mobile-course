# Reflection: Week 7

1. **Entity vs Model:** An entity is a pure business object in the domain with no knowledge of JSON or databases, while a model lives in the data layer, maps raw data (`fromJson`/`toMap`), and is converted to an entity via `toEntity()`.

2. **When a use case is needed:** A use case is needed when there are business rules or multiple repositories to combine (e.g., `Login`), whereas for one-line CRUD, calling the repository directly is enough.

3. **Why the interface belongs in domain, not data:** So that dependencies point inward: the domain defines what it needs and the data layer only implements it, which lets the implementation be swapped or faked in tests without changing business logic.

4. **Which part of the AI proposal I rejected:** I rejected the use case for fetching announcements and the single combined `AppRepository`, because the first is over-engineering for simple CRUD and the second violates Interface Segregation.