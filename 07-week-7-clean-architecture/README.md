# Week 7 — Clean Architecture: Campus Notify

## Layer Diagram & Dependency Rule

```
┌─────────────────────────────────────────────────────┐
│  presentation  (widgets, pages, Riverpod notifiers)  │
│  lib/features/*/presentation/                        │
└──────────────────────┬──────────────────────────────┘
                       │  depends on ↓
┌──────────────────────▼──────────────────────────────┐
│  domain  (entities, repository interfaces, usecases) │
│  lib/features/*/domain/  +  lib/core/               │
│  ⚡ Pure Dart — zero Flutter/Dio/Firebase imports    │
└──────────────────────▲──────────────────────────────┘
                       │  implements ↑
┌──────────────────────┴──────────────────────────────┐
│  data  (models, repository impls, Dio, SecureStorage)│
│  lib/features/*/data/                               │
└─────────────────────────────────────────────────────┘

Golden rule: arrows only point INWARD (toward domain).
```

---

## Struktur Proyek

```
lib/
├── core/
│   ├── failures.dart              # sealed Failure hierarchy
│   └── network/api_client.dart    # Dio wrapper (no auth logic)
├── features/
│   ├── auth/
│   │   ├── domain/
│   │   │   ├── entities/user_session.dart
│   │   │   ├── repositories/auth_repository.dart   ← interface
│   │   │   └── usecases/login.dart
│   │   ├── data/
│   │   │   ├── datasources/token_store.dart
│   │   │   └── repositories/auth_repository_impl.dart
│   │   └── presentation/
│   │       ├── providers/auth_provider.dart         ← DI wiring
│   │       └── pages/login_page.dart
│   ├── announcements/
│   │   ├── domain/
│   │   │   ├── entities/announcement.dart
│   │   │   └── repositories/announcement_repository.dart ← interface
│   │   ├── data/
│   │   │   ├── models/announcement_model.dart
│   │   │   └── repositories/announcement_repository_impl.dart
│   │   └── presentation/
│   │       ├── providers/announcement_providers.dart
│   │       └── pages/announcement_page.dart
│   ├── home/
│   │   └── presentation/pages/home_page.dart
│   └── notifications/
│       └── data/push_service.dart
├── main.dart
├── router.dart
└── routes.dart
```

---

## File Lama → Tujuan Baru (Audit Refactor)

| File Lama | Layer | Problem | Tujuan Baru |
|-----------|-------|---------|-------------|
| `data/auth_repository.dart` | data | Interface + impl bercampur, tidak ada kontrak domain | Pecah: `auth/domain/repositories/` (interface) + `auth/data/repositories/` (impl) |
| `data/api_client.dart` | data | Mengimpor `AuthRepository` dari data → circular dep | `core/network/api_client.dart` (hanya Dio config) |
| `data/api_errors.dart` | data | Exception bocor ke atas | `core/failures.dart` (sealed Failure) |
| `data/token_store.dart` | data | OK | `auth/data/datasources/token_store.dart` |
| `providers/auth_provider.dart` | presentation | Missing imports, no DI structure | `auth/presentation/providers/auth_provider.dart` |
| `pages/login_page.dart` | presentation | Kosong | `auth/presentation/pages/login_page.dart` |
| `pages/home_page.dart` | presentation | Kosong | `home/presentation/pages/home_page.dart` |
| `pages/announcement_page.dart` | presentation | Kosong | `announcements/presentation/pages/announcement_page.dart` |
| `messaging/push_service.dart` | data | Kosong | `notifications/data/push_service.dart` |

---

## 3 Sterility Grep Results

Jalankan setelah refactor — semua harus kosong:

```bash
# 1. Presentation bebas dari data layer
grep -rn "Dio\(|openDatabase|FlutterSecureStorage" lib/features/*/presentation
# → (no output) ✅

# 2. Tidak ada business logic mentah di build()
grep -rn "DateFormat\|jsonDecode\|toIso8601String" lib/features/*/presentation
# → (no output) ✅

# 3. Tidak ada instansiasi manual repository di presentation
grep -rn "Repository(\|Dio(BaseOptions" lib/features/*/presentation
# → (no output) ✅

# 4. Domain bebas dari Flutter/Dio/Firebase
grep -rn "package:\(flutter\|dio\|sqflite\|firebase\)" lib/features/*/domain
# → (no output) ✅
```

---

## Cara Menjalankan

```bash
# Install dependencies
flutter pub get

# Jalankan di emulator/device
flutter run

# Jalankan tests
flutter test test/features/

# Static analysis
flutter analyze
```

---

## AI Tools yang Digunakan

- **Kiro AI** (IDE assistant) — digunakan untuk scaffolding awal dan mengisi implementasi berdasarkan slide Week 7

### Prompt Utama

```
Project: campus_notify (auth + FCM + announcements).
Current: lib/{data, providers, pages}, mixed repos, widgets calling Dio directly.
Tasks:
1. Propose feature-first Clean Architecture.
2. Each old file → new destination.
3. Flag over-engineering for simple CRUD.
4. Riverpod DI wiring, no extra package.
Explain the trade-off of each decision.
```

---

## Proposal AI vs Keputusan Akhir

| Usulan AI | Keputusan | Alasan |
|-----------|-----------|--------|
| Use case untuk semua CRUD (`GetAnnouncements`, `Logout`) | **Ditolak** | Tidak ada aturan bisnis — repo langsung cukup |
| Use case `Login` | **Diterima** | Ada validasi input + aturan bisnis |
| Satu `AppRepository` untuk semua fitur | **Ditolak** | Melanggar Interface Segregation |
| Interface repo di `data/` | **Ditolak** | Harus di `domain/` — Dependency Inversion |
| `ApiClient` dengan refresh interceptor yang menarik `AuthRepository` | **Diubah** | Circular dependency — pisahkan responsibility |
| `PushService` dipanggil dari widget | **Diubah** | Dibungkus di `notifications/data/`, inisialisasi dari `main.dart` |

Lihat detail lengkap: [docs/ai-challenge.md](docs/ai-challenge.md)

---

## Issues yang Ditemukan & Test Results

### Issues
1. **Circular dependency** di `ApiClient` versi awal — diperbaiki dengan memisahkan konfigurasi Dio dari logika auth
2. **Duplikasi kode** di `announcement.dart` — entity, repo interface, dan model dijadikan satu file — dipecah ke file terpisah
3. **Interface bocor ke data layer** — diperbaiki dengan memindahkan semua interface ke `domain/`

### Tests
```
test/features/auth/login_test.dart
  ✅ Login use case - sukses mengembalikan UserSession
  ✅ Login use case - gagal mengembalikan AuthFailure (repo gagal)
  ✅ Login use case - input kosong ditolak sebelum menyentuh repo
  ✅ Login use case - whitespace-only email ditolak

test/features/announcements/announcement_repository_test.dart
  ✅ AnnouncementRepository contract - fetchAll sukses
  ✅ AnnouncementRepository contract - fetchAll gagal NetworkFailure
  ✅ AnnouncementRepository contract - fetchById sukses
  ✅ AnnouncementRepository contract - fetchById gagal
  ✅ AnnouncementRepository contract - entity tidak punya import Flutter/Dio
```

---

## Screenshots

> Tambahkan screenshot sebelum dan sesudah refactor di folder `screenshots/`.
> `screenshots/before.png` — tampilan dengan struktur lama
> `screenshots/after.png` — tampilan dengan struktur clean architecture

Perilaku UI identik sebelum dan sesudah refactor.
