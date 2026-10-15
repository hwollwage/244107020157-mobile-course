# AI Challenge: Week 7 Clean Architecture (campus_notify)

## AI Tool
Claude (Anthropic), dipakai sebagai co-developer untuk usulan struktur dan kerangka kode.

## Prompt
> Project: campus_notify (auth + FCM + announcements). Current: lib/{data, providers, pages}, mixed repos, widgets calling Dio directly. Tasks: 1. Propose feature-first Clean Architecture. 2. Each old file → new destination. 3. Flag over-engineering for simple CRUD. 4. Riverpod DI wiring, no extra package. Explain the trade-off of each decision.

## Arah Dependensi
`presentation → domain ← data`. Interface repository ada di domain, implementasi (Dio, secure storage, Firebase) ada di data. Domain hanya Dart murni.

## Proposal vs Keputusan

| Usulan AI | Keputusan | Alasan |
|---|---|---|
| Feature-first: `auth`, `announcements`, `home`, `notifications` | Terima | Satu fitur satu folder, mudah dihapus |
| Use case `Login` | Terima | Ada aturan bisnis (validasi input) |
| Use case untuk fetch announcements | Tolak | CRUD satu baris, repo langsung cukup (over-engineering) |
| Satu `AppRepository` untuk semua fitur | Tolak | Melanggar Interface Segregation |
| `Failure` sealed class di `core/` | Terima | Error eksplisit, tidak ada exception bocor ke UI |
| Riverpod `Provider` sebagai satu titik DI | Terima | Tanpa package tambahan, widget tidak membuat repo sendiri |

## Kekurangan Proposal AI yang Ditemukan
1. **`PushService` tidak punya abstraksi di domain.** Usulan menaruhnya langsung di `notifications/data/`, sehingga siapa pun yang memakainya bergantung ke implementasi Firebase (melanggar Dependency Inversion). Perbaikan: buat interface tipis di domain, impl di data. (TODO: tulis apakah kamu jadi mengubahnya atau mencatatnya sebagai batasan.)
2. **Provider mengubah `Failure` menjadi `Exception(message)`.** Tipe failure hilang, sehingga UI tidak bisa membedakan `NetworkFailure` dan `AuthFailure`. Perbaikan: pertahankan tipe Failure sampai ke state UI.
3. **Usulan tidak menyebut langkah pembersihan.** Setelah file dipindah, file lama masih tertinggal (dobel di `pages/`, `providers/`, `messaging/`). Perbaikan manual: hapus duplikat dan perbaiki import.

## Perubahan Manual
- Menghapus file lama yang duplikat setelah dibandingkan dengan `diff`.
- Memindahkan `announcement_page.dart` dan `home_page.dart` ke `presentation/pages/`.
- Membuat `announcement_repository_impl.dart` yang belum ada di usulan awal.
- TODO: tambahkan perubahan lain yang kamu lakukan.

## Bukti Sterilitas (jalankan dan tempel hasilnya)
```bash
grep -rnE "Dio\(|openDatabase|FlutterSecureStorage" lib/features/*/presentation
grep -rnE "DateFormat|jsonDecode|toIso8601String" lib/features/*/presentation
grep -rnE "Repository\(|Dio\(BaseOptions" lib/features/*/presentation
grep -rnE "package:(flutter|dio|sqflite|firebase)" lib/features/*/domain
```
Hasil: TODO (tempel output; target semua kosong)

## Hasil Test
`flutter analyze`: TODO
`flutter test`: TODO (login sukses, login gagal, input kosong)

## Screenshot Sebelum/Sesudah
TODO: tambahkan ke `screenshots/` (login, home, pengumuman).

## Kesimpulan
Struktur ini cukup bersih untuk tugas kuliah, tetapi belum sepenuhnya production-ready karena PushService belum diabstraksi dan tipe Failure belum sampai ke UI. Dua hal itu jadi catatan perbaikan berikutnya.