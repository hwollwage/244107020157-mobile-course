# Refleksi — Week 7 Clean Architecture

## Exit Ticket

### 1. Entity vs Model

| | Entity | Model |
|---|---|---|
| **Lokasi** | `domain/entities/` | `data/models/` |
| **Isi** | Objek bisnis murni (pure Dart) | Representasi JSON/SQLite + mapping |
| **Tahu** | Hanya aturan bisnis | `fromJson`, `toMap`, dan cara konversi ke entity |
| **Contoh** | `Announcement` (hanya id, title, body, createdAt) | `AnnouncementModel` (punya `fromJson()` dan `toEntity()`) |
| **Boleh diimport oleh** | Semua layer | Hanya data layer |

Mapping (`toMap`/`fromMap`/`fromJson`) **hanya boleh ada di model**. Widget dan use case tidak pernah melihat `AnnouncementModel`.

---

### 2. Use Case vs Repo Langsung

| | Kapan |
|---|---|
| **Use case dibutuhkan** | Ketika ada aturan bisnis: validasi input, kombinasi >1 repo, transformasi data sebelum disimpan |
| **Repo langsung cukup** | CRUD satu baris tanpa aturan bisnis (`fetchAll`, `fetchById`, `logout`) |

Contoh konkret di proyek ini:
- `Login` → **use case** karena memvalidasi email/password kosong _sebelum_ menyentuh network
- `fetchAll`, `logout` → **repo langsung** karena hanya meneruskan panggilan

---

### 3. Kenapa Interface di Domain, Bukan Data

Dependency Inversion Principle mensyaratkan bahwa:
- Modul high-level (domain) **mendefinisikan** abstraksi yang dia butuhkan
- Modul low-level (data) **mengimplementasikan** abstraksi itu

Kalau interface di `data/`:
```
domain → data (salah — panah keluar dari domain)
```

Kalau interface di `domain/`:
```
data → domain (benar — panah menuju domain)
```

Efek praktisnya: domain bisa ditest dengan `FakeAuthRepository` tanpa membutuhkan Dio atau Firebase sama sekali. Ini yang membuat use case bisa diuji secara unit murni.

---

### 4. Bagian AI yang Ditolak dan Alasannya

**Ditolak: Use case untuk setiap operasi CRUD** (`GetAnnouncements`, `Logout`, `GetAnnouncementById`)

Alasan penolakan:
- Tidak ada logika bisnis di dalamnya — semuanya langsung meneruskan ke repo
- Menambah 3 file ekstra tanpa manfaat testability (repo interface sudah cukup sebagai test boundary)
- Slide secara eksplisit menyatakan: _"repo direct suffices → one-line CRUD"_

Keputusan akhir: hanya `Login` yang dibuat sebagai use case karena ada validasi real.

---

## Refleksi Personal

Yang paling menantang selama refactor adalah menyadari bahwa "memindahkan folder" saja tidak cukup — yang penting adalah **ke mana arah import-nya**. File `api_client.dart` yang lama secara tidak sengaja mengimpor `AuthRepository` dari `data/`, yang menciptakan circular dependency. Baru ketika menggambar panah di kepala sendiri terlihat masalahnya.

Pelajaran terbesar: domain yang bersih berarti bisa membuka folder `features/auth/domain/` dan tidak menemukan satu pun `import 'package:dio'` atau `import 'package:flutter'`. Kalau ada satu saja, itu sinyal panah dependensi sudah terbalik.

AI berguna untuk menamakan file dan mengusulkan struktur folder, tapi keputusan tentang "apakah ini butuh use case?" harus tetap dari developer yang memahami aturan bisnis proyeknya.
