# #12 | Testing and Quality Assurance

## Skenario pengujian

| # | Skenario | Jenis test | Kategori |
| --- | ---------- | ------------ | ---------- |
| 1 | Judul dengan teks biasa diterima sebagai valid | Unit | Happy path |
| 2 | Judul satu karakter diterima | Unit | Edge case |
| 3 | Judul dengan spasi di depan/belakang tetap valid | Unit | Edge case |
| 4 | String kosong ditolak | Unit | Failure |
| 5 | String hanya spasi ditolak | Unit | Failure |
| 6 | String hanya tab ditolak | Unit | Failure |
| 7 | TaskService mengembalikan data dari repository | Unit | Happy path |
| 8 | TaskService mengembalikan list kosong jika repository kosong | Unit | Edge case |
| 9 | TaskService mengembalikan banyak tugas sesuai urutan | Unit | Happy path |
| 10 | TaskService meneruskan exception dari repository (tidak ditelan) | Unit | Failure |
| 11 | AppBar menampilkan judul "Task list" | Widget | Initial display |
| 12 | TextField task-title-field tersedia | Widget | Initial display |
| 13 | Tombol save-task-button tersedia | Widget | Initial display |
| 14 | Pesan "No tasks yet." muncul saat belum ada tugas | Widget | Initial display |
| 15 | Menekan Save dengan field kosong menampilkan error | Widget | Invalid input |
| 16 | Menekan Save dengan spasi saja menampilkan error | Widget | Invalid input |
| 17 | Tugas yang disimpan muncul di daftar | Widget | Successful action |
| 18 | Field dikosongkan setelah tugas berhasil disimpan | Widget | Successful action |
| 19 | Pesan error hilang setelah input valid | Widget | Successful action |
| 20 | Dapat menambahkan beberapa tugas sekaligus | Widget | Successful action |
| 21 | MyApp merender tanpa error | Widget | Smoke test |
| 22 | Pengguna dapat menambah tugas dan melihatnya di daftar | Integration | Main flow |
| 23 | Submit judul kosong menampilkan validasi error | Integration | Failure flow |
| 24 | Pengguna dapat menambah beberapa tugas berturut-turut | Integration | Main flow |

---
File coverage tersimpan di `coverage/lcov.info`. Coverage menunjukkan bahwa semua branch utama pada `is_valid_task_title.dart`, `task_repository.dart`, dan `task_page.dart` tercakup oleh test.

---

## Integration test

File: `integration_test/app_test.dart`

Terdapat 3 skenario integration test yang menguji alur lengkap aplikasi (dari input hingga tampil di layar). Test ini dijalankan pada emulator/device dengan perintah:

```bash
flutter test integration_test/app_test.dart -d <device_id>
```

> **Catatan:** Integration test tidak dapat dijalankan di lingkungan CI tanpa emulator/device. Semua skenario telah diverifikasi melalui widget test yang setara, dan kode integration test telah ditulis sesuai spesifikasi codelab.

---

## Temuan yang belum terselesaikan

Tidak ada temuan kritis. Beberapa catatan minor:

- `cupertino_icons`, `material_color_utilities`, dan beberapa paket lain memiliki versi terbaru yang tidak kompatibel dengan constraint SDK saat ini — ini bukan blocker dan tidak mempengaruhi fungsionalitas maupun test.

---

## Refleksi

**Bug mana yang paling mudah terlewat tanpa test?**

Kasus whitespace-only (`"   "`) pada validasi judul. Tanpa unit test yang eksplisit, kode yang hanya mengecek `isEmpty` (bukan `trim().isNotEmpty`) akan lolos review manual tapi gagal di input nyata.

**Di mana fake repository dibutuhkan, dan apa manfaatnya?**

`FakeTaskRepository` digunakan di `task_service_test.dart` untuk mengisolasi `TaskService` dari sumber data nyata (network/database). Dengan fake, test dapat mengontrol persis data apa yang dikembalikan dan mensimulasikan error tanpa koneksi internet, sehingga test berjalan cepat dan deterministik.

**Apa yang diajarkan widget test vs integration test?**

- **Widget test** mengajarkan apakah setiap state UI (kosong, error, berhasil) di-render dengan benar dan apakah interaksi user (tap, enterText) menghasilkan perubahan yang diharapkan — tanpa perlu emulator.
- **Integration test** memastikan seluruh komponen bekerja bersama secara end-to-end pada perangkat nyata, menangkap masalah yang tidak muncul di widget test seperti isu inisialisasi, routing, atau rendering antar-frame.

---
