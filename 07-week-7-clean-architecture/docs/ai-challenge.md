# AI Challenge — Week 7 Clean Architecture

## Prompt yang Digunakan

```
Project: campus_notify (auth + FCM + announcements).
Current: lib/{data, providers, pages},
mixed repos, widgets calling Dio directly.
Tasks:
1. Propose feature-first Clean Architecture.
2. Each old file → new destination.
3. Flag over-engineering for simple CRUD.
4. Riverpod DI wiring, no extra package.
Explain the trade-off of each decision.
```

---

## Proposal AI vs Keputusan Akhir

| No | Usulan AI | Keputusan | Alasan |
|----|-----------|-----------|--------|
| 1 | Buat use case untuk semua operasi: `GetAnnouncements`, `Logout`, `GetAnnouncementById` | **Ditolak** | CRUD satu baris — repo langsung sudah cukup. Menambah use case tanpa aturan bisnis = over-engineering (melanggar prinsip pragmatisme slide) |
| 2 | Buat use case `Login` | **Diterima** | Login punya aturan bisnis nyata: validasi input sebelum menyentuh network. Use case ini juga bisa ditest tanpa Dio |
| 3 | Satu `AppRepository` untuk auth + announcement + push | **Ditolak** | Melanggar Interface Segregation — satu interface raksasa memaksa semua impl bergantung pada semua kontrak |
| 4 | Letakkan interface repository di `data/` | **Ditolak** | Kontrak harus ada di `domain/` — ini inti dari Dependency Inversion. Kalau interface di `data`, domain bergantung ke data (panah terbalik) |
| 5 | `PushService` dipanggil langsung dari widget | **Diubah** | Dibungkus dalam `features/notifications/data/push_service.dart` dan diinisialisasi dari `main.dart`, bukan dari widget |
| 6 | `ApiClient` mengandung refresh-token interceptor yang menarik `AuthRepository` dari `data/` | **Diubah** | Menimbulkan circular dependency (`AuthRepositoryImpl` → `ApiClient` → `AuthRepository`). Dipecah: `ApiClient` hanya konfigurasi Dio, refresh logic dipindahkan ke impl jika diperlukan |

---

## 2 Kelemahan yang Ditemukan di Proposal AI

### Kelemahan 1 — Use Case untuk Setiap CRUD
AI mengusulkan `GetAnnouncements`, `GetAnnouncementById`, dan `Logout` sebagai use case terpisah. Semuanya hanya _pass-through_ ke repo (tidak ada aturan bisnis, tidak menggabungkan repo). Ini over-engineering: menambah 3 file ekstra, meningkatkan indirection, dan tidak ada nilai testability tambahan karena repo contract sudah cukup.

**Bukti:** Slide menyatakan _"needed → combines >1 repo / owns rules"_. Ketiganya tidak memenuhi syarat.

### Kelemahan 2 — Failure/Exception masih bocor ke atas
Dalam proposal awal, AI menaruh `ApiException` dan `AppException` di `data/` lalu mengimport-nya dari `domain/`. Ini membalik panah: `domain → data`. Keputusan akhir: **satu sealed class `Failure` di `core/failures.dart`** yang diimpor semua layer, sehingga tidak ada layer yang bergantung ke layer lain hanya untuk tipe error.

---

## Perubahan Manual yang Dilakukan

1. Mendeteksi circular dependency di `ApiClient` (versi awal menarik `AuthRepository`), diperbaiki manual
2. Menghapus duplikasi kode di `announcement.dart` (AI menggenerate entity + repository + model dalam satu file)
3. Menambahkan `fetchById` ke `AnnouncementRepository` — AI hanya membuat `fetchAll`
4. `AuthStateNotifier` ditulis manual — AI mengusulkan `StateNotifier` lama bukan `AutoDisposeAsyncNotifier` (versi baru Riverpod)
5. `TokenStore.save()` diubah ke signature `({required String access, required String refresh})` untuk menghindari positional parameter yang ambigu

---

## Arrow Diagram (tanpa AI)

```
presentation (providers, pages)
      |
      v  depends on
domain (entities, repository interfaces, use cases, failures)
      ^
      |  implements
data (models, repository impls, Dio, secure_storage)
```

- `domain` hanya import `dart:core` dan `core/failures.dart` (pure Dart ✓)
- `data` import `dio`, `flutter_secure_storage`, tapi **tidak diimport oleh domain**
- `presentation` import domain entities dan Riverpod providers — tidak pernah `new Repository()` sendiri
