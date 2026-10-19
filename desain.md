# desain.md — Spesifikasi Aplikasi "Tugasku" (Flutter, Offline)

> **Dokumen ini ditujukan untuk AI coding agent (opencode).** Baca seluruh file ini sebelum menulis kode, dan baca ulang bagian yang relevan di awal setiap tugas. Ini adalah sumber kebenaran untuk desain, arsitektur, dan batasan proyek.

---

## CATATAN PENTING — STATUS PENGERJAAN

- **Tahap 1 (Fondasi) sudah SELESAI pada hari ini, Jumat 16 Oktober 2026.**
  - Isi tahap: dependency Bagian 4 terpasang, struktur folder Bagian 6 dibuat, `AppColors`/`AppTheme`/`AppStrings`/`TextStyles`, font Plus Jakarta Sans didaftarkan, `app_router.dart` (rute placeholder), `AppBottomNav` + FAB pensil, dan `GradientHeader`.
  - Hasil verifikasi saat penyelesaian: `flutter analyze` = **0 issue**, `flutter test` = **semua lulus**, `flutter build bundle` = sukses.
  - Catatan teknis: paket `timezone` memakai `^0.10.1` (versi 1.x tidak tersedia di pub.dev); font Plus Jakarta Sans disimpan sebagai file statis di `assets/fonts/` (diunduh sekali saat pengembangan, bukan saat runtime).
- **Tahap 2 (Data Lokal) sudah SELESAI pada Senin, 19 Oktober 2026.**
  - Isi tahap: tabel drift `Tasks`/`Labels`/`TaskLabels`/`Projects` (`lib/data/db/tables.dart`), `app_database.dart` dengan seed 5 label (Belajar, Olahraga, Kerja, Pribadi, Kebiasaan), `TaskRepository` + `LabelRepository` (CRUD, stream, pencarian tak peka huruf), provider Riverpod (`lib/data/providers.dart`), `task_grouping.dart` + `date_utils.dart` (fungsi murni), serta unit test `test/task_grouping_test.dart` dan `test/task_repository_test.dart` (drift in-memory + uji persistensi file).
  - Hasil verifikasi saat penyelesaian: `dart run build_runner build` = **sukses**, `flutter analyze` = **0 issue**, `flutter test` = **26 test semua lulus**.
  - Catatan teknis: `dueDate`/`reminderAt`/`completedAt`/`createdAt` **disimpan UTC** dan repositori menormalisasi hasil bacaan drift (lokal) kembali ke UTC — tampilkan WIB di UI; `Labels.name` memakai constraint `UNIQUE` lewat `text().unique()` (drift 2.34 tidak punya `uniqueKey()`; override `uniqueKeys` berformat lama diabaikan generator); API grouping yang dipakai UI adalah `groupTasks(tasks, now: ...)` → `TaskGroupSection(key, title, tasks, overdueTaskIds)`; `main.dart` membuka `AppDatabase` dan meng-override `appDatabaseProvider` sebelum `runApp`. Peringatan drift "multiple databases" hanya muncul di debug test persistensi (dua instance dibuat berurutan) — aman.
- **Tahap 3 (MVP Layar Inti) sudah SELESAI pada Senin, 19 Oktober 2026.**
  - Isi tahap: alur `Onboarding → Profil Lokal → Tugasku` dengan redirect `GoRouter` berbasis flag `onboarding_done`/`user_name` (`shared_preferences`, provider `ProfileController`); layar Tugasku dengan header gradien (kolom pencarian fungsional, menu ⋯ Urutkan dengan 4 pilihan — persistensi dialog formal datang di Tahap 4), seksi kelompok (judul kapital + badge jumlah) dari `groupTasks`, `TaskCard` (lingkaran centang, judul, tanggal via `intl` locale `id`, `LabelChip`), swipe-kiri hapus + Snackbar Urungkan (4 detik) yang memulihkan tugas beserta tautan labelnya, bottom sheet Tambah Tugas (judul, tanggal, jam, label multi-pilih, catatan) dengan backdrop blur, layar Ubah Tugas (`/task/edit/:id`), `EmptyState`.
  - Hasil verifikasi saat penyelesaian: `flutter analyze` = **0 issue**, `flutter test` = **28 test semua lulus** (termasuk alur onboarding, daftar terelompokkan, centang via UI, tab Kalender).
  - Catatan teknis: tanggal disimpan UTC dan dibaca ulang sebagai UTC oleh repositori; UI mengonversi `toLocal()` saat menampilkan. FAB bottom nav membuka sheet Tambah; centang tugas dan pengurangan di dalam seksi berfungsi penuh. Sort menu saat ini diurutkan dalam memori (state Riverpod), dialog modal + simpan `shared_preferences` disesuaikan di Tahap 4. Picker Material menampilkan teks lokal perangkat (lokal `id_ID` penuh menyusul bersama `localizationsDelegates` di Tahap 4).
- **Tahap 4 (Fitur Pelengkap) sudah SELESAI pada Senin, 19 Oktober 2026.**
  - Isi tahap: Dasbor (`/home/dashboard`, cabang shell agar tetap punya bottom bar + FAB dibuka lewat ikon grid di header Tugasku — keputusan pengguna) dengan kartu pintasan Daftar/Kalender/Kanban (Kanban nonaktif sampai Tahap 5), seksi Proyek (bisa dilipat + dialog tambah proyek via `ProjectRepository` baru), Label (grid 2 kolom + jumlah, dialog tambah label memakai palet warna token), Status (chip titik berwarna + jumlah, `statusCountsProvider`); avatar + dialog ubah nama di header Dasbor. Dialog Urutkan modal (`sort_dialog.dart`, RadioGroup, latar diburamkan) menggantikan menu popup ⋯ dan pilihan dipersistenkan via `SortOptionController` + `sharedPrefsProvider` (kunci `task_sort_option`). Prioritas: dialog `priority_picker_dialog.dart` (Rendah/Sedang/Tinggi) dipakai lower sheet Tambah (5 ikon aksi dalam Wrap) & layar Ubah (tile ketiga). Kalender (`table_calendar`): mode Bulan/Minggu pemilih chip, titik penanda (ungu belum selesai/hijau selesai), seksi Tugas Terjadwal (badge tanggal + jumlah, kartu ikon jam "HH:mm WIB"), mode Minggu info "N tugas dijadwalkan hari ini" + tautan Lihat Semua (kembali ke Bulan), pencarian header filter stream, kartu statistik `StatsSummaryCard` (TERSELESAIKAN/PRODUKTIVITAS/CHIP Kategori) saat hari terpilih tanpa tugas dan di layar Tugasku bila SEMUA tugas selesai, helper murni `core/utils/day_stats.dart` (5 test). Notifikasi: `lib/services/notification_service.dart` (flatten `initializeTimeZones` + `Asia/Jakarta`, `POST_NOTIFICATIONS` diminta saat pengguna pertama memilih jam, `zonedSchedule` `inexactAllowWhileIdle`, cancel saat hapus/selesai, jadwal ulang saat ubah/Urungkan, id = id tugas), manifest ditambah `POST_NOTIFICATIONS`/`RECEIVE_BOOT_COMPLETED`/`SCHEDULE_EXACT_ALARM`/`USE_EXACT_ALARM` + 2 receiver boot (boot receiver `android:exported="false"`, label aplikasi diganti "Tugasku"); reminderAt otomatis = dueDate bila jam dipilih. `flutter_localizations` (SDK, sejalan dengan catatan desain Bagian 3/Catatan Tahap 3) ditambahkan untuk `localizationsDelegates` + locale `id_ID` di `app.dart`.
  - Hasil verifikasi saat penyelesaian: `flutter analyze` = **0 issue**, `flutter test` = **33 test semua lulus** (16 repository + 9 grouping + 5 day_stats + 3 widget), `flutter build apk --debug` = **sukses**.
  - Catatan teknis: `sharedPrefsProvider` (provider sinkron, di-override di main/test; sisa FutureProvider lama dihapus) menuntut override tambahan di semua widget test. Darpmemberi Hati-hati API drift 2.34: `orderBy` select sederhana menerima `List<OrderClauseGenerator<T>>` (closure `(tbl) => OrderingTerm.asc(tbl.id)`), sedangkan `.join()` tetap `List<OrderingTerm>`. GroupedTasksController kini memanggil notifikasi lewat `notificationServiceProvider` (best-effort, tidak mem-crash di test). Peringatan "Kotlin daemon compilation failed" saat build = noise (file paket di drive C: vs proyek di D:), build tetap sukses.
- **Tahap 5 belum dikerjakan (opsional, hanya bila diminta).** Lanjutkan sesuai Bagian 9.
- Aplikasi tetap 100% offline: tidak ada env/`.env`, API key, backend, atau paket autentikasi yang ditambahkan.

---

## 0. Aturan Kerja Agent (WAJIB DIPATUHI)

1. **Kerjakan satu tahap pada satu waktu** (lihat Bagian 9). Jangan melompat ke tahap berikutnya sebelum diminta.
2. **Setelah tiap tahap selesai:** jalankan `flutter analyze` (harus 0 error/warning) dan, jika ada test, `flutter test`. Lalu berhenti dan laporkan: file yang dibuat/diubah, hasil analyze, dan cara memverifikasi di HP.
3. **Hanya gunakan paket yang tercantum di Bagian 4.** Jika butuh paket lain, berhenti dan tanyakan dulu.
4. **Jangan** menambahkan backend, Firebase, HTTP request, analytics, atau login sosial. Aplikasi 100% offline.
5. **Jangan hardcode** warna, ukuran radius, atau string UI di widget. Pakai `AppColors`, `AppTheme`, dan `AppStrings`.
6. **Jangan ubah file di luar lingkup tugas** yang diberikan. Jika perlu refactor besar, minta persetujuan.
7. **UI tidak boleh mengakses database langsung.** Alur wajib: `Widget → Provider (Riverpod) → Repository → Database`.
8. Semua teks yang tampil ke pengguna **berbahasa Indonesia**. Nama kelas/variabel/komentar kode boleh bahasa Inggris.
9. Jika desain ambigu atau ada konflik antara dokumen ini dan permintaan pengguna, **tanyakan**, jangan menebak.
10. Tulis kode lengkap (bukan potongan "..."), dan pastikan proyek selalu bisa `flutter run` setelah setiap perubahan.

**Dikerjakan manusia, bukan agent:** instalasi Flutter/Android Studio, mengaktifkan Debugging USB, menyambungkan HP, menjalankan `flutter run` di perangkat, dan memasang APK. Agent cukup memberi perintahnya bila diminta.

---

## 1. Ringkasan Produk

| Item          | Nilai                                                                                |
| ------------- | ------------------------------------------------------------------------------------ |
| Nama aplikasi | Tugasku                                                                              |
| Platform      | Android (prioritas). iOS tidak dikerjakan dulu                                       |
| Bahasa UI     | Indonesia, locale `id_ID`                                                            |
| Backend       | **Tidak ada.** Semua data tersimpan lokal                                            |
| Gaya visual   | Ungu/indigo, kartu putih membulat, header gradien ungu dengan sudut bawah melengkung |
| Font          | Plus Jakarta Sans (letakkan di `assets/fonts/`, jangan unduh saat runtime)           |

---

## 2. Keputusan Desain: Pengganti Login

Desain Stitch memiliki layar Masuk/Daftar dan tombol Facebook/Google/Apple. Karena tanpa server:

- **Jangan implementasikan autentikasi.** Tombol sosial **tidak ditampilkan**.
- Ganti dengan layar **Profil Lokal**: satu field **Nama** (opsional foto nanti), tombol "Mulai". Simpan nama dengan `shared_preferences`.
- Pakai gaya visual Halaman 2/5 (ikon centang dalam kotak ungu di atas, judul, field membulat, tombol ungu lebar) untuk layar ini. Judul: "Ayo Mulai!", subjudul: "Siapa namamu?".
- Alur peluncuran: `Onboarding (sekali saja) → Profil Lokal (sekali saja) → Home`. Simpan flag `onboarding_done` dan `user_name`.

---

## 3. Spesifikasi Layar

Navigasi utama: **bottom bar** dengan 2 tab (**Daftar**, **Kalender**) dan **FAB bulat ungu berikon pensil** di tengah (membuka bottom sheet Tambah Tugas).

### 3.1 Onboarding (Halaman 1)

- Latar putih dengan ornamen lingkaran ungu pucat di kanan bawah.
- Tengah-atas: kotak ungu membulat (radius ±28) berisi ikon centang putih, dengan titik/bintang dekoratif kecil.
- Bawah-kiri: judul **"Selesaikan Tugasmu"** (tebal), subjudul "Hanya satu sentuhan untuk mulai merencanakan aktivitas harianmu."
- Indikator halaman (3 titik, titik aktif memanjang, ungu) di kiri bawah.
- Kanan bawah: tombol bulat ungu dengan ikon panah → lanjut ke Profil Lokal.

### 3.2 Profil Lokal (berdasarkan Halaman 2 & 5)

Lihat Bagian 2. Field nama dengan label kecil kapital "NAMA". Tombol "Mulai" ungu lebar. Tanpa login sosial, tanpa "Lupa kata sandi".

### 3.3 Dasbor (Halaman 3)

- **Header gradien ungu** (sudut bawah radius ±32): avatar bulat kiri atas, ikon pengaturan kanan atas, teks kecil "Hari ini, 1 Mei" (tanggal dinamis), judul besar **"Dasbor"**.
- **3 kartu pintasan** sejajar: Daftar, Kalender, Kanban (ikon + label). Kanban boleh dinonaktifkan sampai Tahap 5.
- **Seksi "Proyek"** (bisa dilipat, tombol + di kanan): baris kartu berisi ikon, nama proyek, badge jumlah tugas.
- **Seksi "Label"** (bisa dilipat, tombol +): grid 2 kolom chip kartu berisi ikon label + nama + jumlah. Label awal: Belajar, Olahraga, Kerja, Pribadi, Kebiasaan.
- **Seksi "Status"**: chip horizontal dengan titik berwarna: Belum Mulai (merah), Sedang Dikerjakan (oranye), Selesai (hijau).
- Bottom bar + FAB.

### 3.4 Tugasku / Daftar (Halaman 4 & 6)

- Header gradien: ikon grid kiri, **kolom pencarian** pil putih transparan ("Cari tugas..."), ikon menu "⋯" kanan (membuka dialog Urutkan), teks tanggal, judul **"Tugasku"**.
- Daftar dikelompokkan dengan judul seksi kapital kecil + badge jumlah ("2 TUGAS"): **Hari Ini**, **Besok**, **Minggu Ini**, lalu **Nanti** dan **Tanpa Tanggal** bila ada.
- **Kartu tugas:** lingkaran centang (outline ungu) di kiri, judul tebal, tanggal kecil di bawah judul (mis. "1 Mei"), chip label berwarna di kanan.
- Tugas selesai: lingkaran terisi centang, teks pudar (dan opsional dicoret).
- **Swipe ke kiri:** latar merah dengan ikon tempat sampah → hapus. Tampilkan Snackbar "Tugas dihapus" dengan aksi **Urungkan**.
- Tap kartu → bottom sheet/halaman edit tugas.
- Tugas berulang menampilkan keterangan kecil (mis. "Setiap dua hari") — Tahap 5.

### 3.5 Dialog Urutkan (Halaman 7)

Dialog modal putih membulat, judul "Urutkan", tombol tutup (×), 4 opsi radio: **Tanggal Jatuh Tempo, Prioritas, Label, Proyek**. Latar belakang diburamkan. Pilihan disimpan (provider/`shared_preferences`).

### 3.6 Kalender (Halaman 8, 9, 11)

- Header gradien: pencarian "Cari jadwal atau tugas...", judul **"Kalender"**, lalu **pemilih mode tampilan** (4 ikon segmented): Bulan, Minggu, dan mode lain (Agenda/Daftar). Implementasi awal: **Bulan** dan **Minggu** saja.
- **Mode Bulan:** kartu putih berisi kalender bulanan (header "Mei 2024" dengan panah), hari terpilih lingkaran ungu terisi, titik kecil di bawah tanggal yang punya tugas. Di bawahnya seksi **"Tugas Terjadwal"** + badge tanggal dan jumlah tugas, daftar kartu tugas dengan ikon jam dan rentang waktu (mis. "14:00 – 15:00 WIB").
- **Mode Minggu:** strip 7 hari (M S S R K J S), baris info "N tugas dijadwalkan hari ini" + badge nama hari, lalu "Jadwal Tugas" (+ tautan "Lihat Semua").
- **Empty state "semua selesai" (Halaman 11):** kartu dengan ilustrasi maskot, judul "Hebat! Kamu telah menyelesaikan semua tugas hari ini", teks "atau ketuk tombol + untuk menambahkan tugas baru", dua statistik: **TERSELESAIKAN** (mis. "8 Tugas") dan **PRODUKTIVITAS** (mis. "100% Selesai"). Di bawahnya baris chip **Kategori Tugas**.
- Zona waktu tampilan: **WIB** (`Asia/Jakarta`), format jam 24 jam.

### 3.7 Tambah Tugas Cepat (Halaman 10)

- Bottom sheet naik dari bawah bersama keyboard, latar belakang diburamkan, gelembung kecil "Apa yang ingin kamu kerjakan?".
- Satu `TextField` judul + tombol kirim bulat ungu (ikon panah atas).
- Baris ikon aksi: **tanggal/jam**, **prioritas**, **label**, **catatan**.
- Teks bantuan: "Pengingat otomatis disetel untuk 15.00 WIB" muncul bila jam dipilih.
- **Parsing bahasa natural** (mis. "hari ini pukul 15.00") adalah fitur **Tahap 5**. Sebelum itu, tanggal & jam dipilih lewat picker.

---

## 4. Tech Stack (HANYA ini)

| Kebutuhan            | Paket                                                                                      |
| -------------------- | ------------------------------------------------------------------------------------------ |
| State management     | `flutter_riverpod`                                                                         |
| Database lokal       | `drift`, `sqlite3_flutter_libs`, `path_provider`, `path`; dev: `drift_dev`, `build_runner` |
| Navigasi             | `go_router`                                                                                |
| Kalender             | `table_calendar`                                                                           |
| Notifikasi lokal     | `flutter_local_notifications`, `timezone`, `flutter_timezone`                              |
| Format tanggal       | `intl` (locale `id_ID`, panggil `initializeDateFormatting`)                                |
| Pengaturan sederhana | `shared_preferences`                                                                       |

Dilarang: Firebase, `http`/`dio`, paket autentikasi, paket analitik.

---

## 5. Design Tokens

Nilai di bawah adalah **perkiraan dari screenshot**. Jika pengguna memberi kode warna asli dari Stitch, perbarui file ini dan `AppColors`.

```dart
// lib/core/theme/app_colors.dart
class AppColors {
  static const primary        = Color(0xFF5B4FE9); // tombol, FAB, header
  static const primaryLight   = Color(0xFF8B83F5); // ujung gradien header
  static const background     = Color(0xFFF6F5FF);
  static const surface        = Color(0xFFFFFFFF);
  static const textPrimary    = Color(0xFF1E1B3A);
  static const textMuted      = Color(0xFF8A88A3);
  static const danger         = Color(0xFFE5484D); // swipe hapus, status Belum Mulai
  static const warning        = Color(0xFFF5A524); // status Sedang Dikerjakan
  static const success        = Color(0xFF34C38F); // status Selesai
  // Warna chip label
  static const labelPribadi   = Color(0xFFF5A524);
  static const labelKerja     = Color(0xFFF5A524);
  static const labelStudi     = Color(0xFF8B83F5);
  static const labelBelajar   = Color(0xFF8B83F5);
  static const labelOlahraga  = Color(0xFF6B7280);
  static const labelKebiasaan = Color(0xFF34C38F);
}
```

| Token                       | Nilai                                                                              |
| --------------------------- | ---------------------------------------------------------------------------------- |
| Radius kartu                | 16                                                                                 |
| Radius header (sudut bawah) | 32                                                                                 |
| Radius tombol               | 14                                                                                 |
| Radius chip                 | 999                                                                                |
| Padding halaman             | 16–20                                                                              |
| Header                      | `LinearGradient` primaryLight → primary, dengan 1–2 lingkaran transparan dekoratif |
| Bayangan                    | lembut, blur besar, opasitas rendah                                                |

Buat satu `ThemeData` di `app_theme.dart` (Material 3, `colorSchemeSeed` boleh dipakai lalu di-override). Mode gelap bukan target awal.

---

## 6. Struktur Folder (ikuti persis)

```
lib/
├─ main.dart                     # init DB, tz, intl, notifikasi → runApp(ProviderScope)
├─ app.dart                      # MaterialApp.router + tema
├─ core/
│  ├─ theme/                     # app_colors.dart, app_theme.dart, text_styles.dart
│  ├─ constants/                 # app_strings.dart
│  ├─ router/                    # app_router.dart
│  ├─ utils/                     # date_utils.dart, task_grouping.dart
│  └─ widgets/                   # gradient_header.dart, task_card.dart,
│                                # label_chip.dart, app_bottom_nav.dart, empty_state.dart
├─ data/
│  ├─ db/                        # app_database.dart, tables.dart
│  └─ repositories/              # task_repository.dart, label_repository.dart, project_repository.dart
├─ features/
│  ├─ onboarding/
│  ├─ profile/
│  ├─ dashboard/
│  ├─ tasks/                     # task_list_screen, add_task_sheet, sort_dialog, providers
│  ├─ calendar/
│  └─ stats/
└─ services/
   └─ notification_service.dart
assets/
├─ fonts/
└─ images/
```

Setiap `feature` memiliki subfolder `presentation/` (screen, widget) dan `providers/`.

---

## 7. Model Data (drift)

**Tasks**
| Kolom | Tipe | Catatan |
|---|---|---|
| id | int, autoIncrement | |
| title | text | wajib, tidak kosong |
| note | text? | |
| dueDate | dateTime? | disimpan UTC, tampil WIB |
| hasTime | bool | false = hanya tanggal |
| priority | int | 0 rendah, 1 sedang, 2 tinggi |
| status | int | 0 belum mulai, 1 dikerjakan, 2 selesai |
| isDone | bool | sinkron dengan status (done ⇒ status 2) |
| projectId | int? | FK → Projects |
| reminderAt | dateTime? | |
| repeatRule | text? | Tahap 5 |
| completedAt | dateTime? | untuk statistik |
| createdAt | dateTime | |

**Labels**: id, name (unik), colorValue (int)
**TaskLabels**: taskId, labelId (PK gabungan, hapus berantai)
**Projects**: id, name, iconKey

**Seed saat pertama dijalankan:** label Belajar, Olahraga, Kerja, Pribadi, Kebiasaan (+ Studi bila dipakai desain). Proyek contoh tidak perlu di-seed.

**Aturan pengelompokan** (`task_grouping.dart`, fungsi murni + unit test):

- _Hari Ini_: dueDate pada tanggal hari ini; tugas **terlambat** (belum selesai, sebelum hari ini) juga masuk sini dengan penanda merah.
- _Besok_: tanggal besok.
- _Minggu Ini_: setelah besok sampai akhir minggu (Minggu).
- _Nanti_: setelah minggu ini. _Tanpa Tanggal_: dueDate null.

---

## 8. Kontrak Perilaku

- Centang tugas: set `isDone=true`, `status=2`, `completedAt=now`; batalkan centang mengembalikan `status=0`, `completedAt=null`.
- Hapus tugas selalu bisa diurungkan lewat Snackbar (±4 detik).
- Judul kosong tidak boleh disimpan (tombol kirim nonaktif).
- Notifikasi: dijadwalkan saat tugas dengan `reminderAt` disimpan; dibatalkan saat tugas dihapus/selesai/diubah. Minta izin `POST_NOTIFICATIONS` (Android 13+) saat pertama kali pengguna mengatur pengingat, bukan saat aplikasi dibuka.
- Semua query daftar memakai **stream** drift sehingga UI otomatis ter-update.
- Pencarian: filter judul & catatan, tidak peka huruf besar/kecil.

---

## 9. Tahapan Pengerjaan (kerjakan berurutan, satu per satu)

Tiap tahap punya **Kriteria Selesai**. Jangan anggap selesai sebelum semua terpenuhi.

### Tahap 1 — Fondasi (SELESAI — 16 Oktober 2026)

**Kerjakan:** tambah dependency (Bagian 4), buat struktur folder (Bagian 6), `AppColors`, `AppTheme`, `AppStrings`, daftarkan font, `app_router.dart` dengan rute placeholder, `AppBottomNav` + FAB, widget `GradientHeader`.
**Selesai jika:** aplikasi berjalan menampilkan header gradien dan bottom bar dengan 2 tab placeholder; `flutter analyze` bersih.

### Tahap 2 — Data Lokal (SELESAI — 19 Oktober 2026)

**Kerjakan:** tabel drift (Bagian 7), `app_database.dart`, `TaskRepository` & `LabelRepository` (CRUD + stream), seed label, provider Riverpod, unit test untuk `task_grouping.dart` dan repository (database in-memory).
**Selesai jika:** `dart run build_runner build` sukses, test lulus, data tetap ada setelah restart aplikasi.

### Tahap 3 — MVP Layar Inti (SELESAI — 19 Oktober 2026)

**Kerjakan:** Onboarding, Profil Lokal, layar Tugasku (grup Hari Ini/Besok/Minggu Ini, `TaskCard`, `LabelChip`), bottom sheet Tambah Tugas (judul, tanggal, jam, label, catatan), centang selesai, swipe-hapus + Urungkan, layar edit tugas, empty state.
**Selesai jika:** semua perilaku Bagian 8 untuk centang/hapus/tambah/ubah berjalan; tampilan sesuai Bagian 3.1–3.4; tidak ada string hardcode di widget.

### Tahap 4 — Fitur Pelengkap

**Kerjakan:** Dasbor (Proyek, Label, Status, jumlah dinamis), pencarian, dialog Urutkan, prioritas, kalender Bulan & Minggu (`table_calendar`, titik penanda, daftar Tugas Terjadwal), notifikasi pengingat, statistik pada empty state (Terselesaikan, Produktivitas = selesai/total tugas hari itu).
**Selesai jika:** semua layar di Bagian 3 (kecuali bagian yang ditandai Tahap 5) berfungsi dengan data nyata; pengingat muncul pada waktunya.

### Tahap 5 — Opsional (hanya bila diminta)

Tugas berulang, tampilan Kanban, parsing bahasa natural di Tambah Cepat, ekspor/impor data JSON, ikon aplikasi (`flutter_launcher_icons`), splash screen.

---

## 10. Di Luar Lingkup (JANGAN dikerjakan)

- Autentikasi, akun, login sosial, sinkronisasi cloud
- Backend/API apa pun
- Dukungan iOS, web, desktop
- Mode gelap (sampai diminta)
- Lokalisasi bahasa selain Indonesia

---

## 11. Perintah Referensi

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test
flutter run                      # (manusia) jalankan di HP terhubung
flutter build apk --release      # (manusia) hasil: build/app/outputs/flutter-apk/app-release.apk
```

Catatan Android untuk notifikasi: tambahkan izin `POST_NOTIFICATIONS` dan `SCHEDULE_EXACT_ALARM`/`USE_EXACT_ALARM` di `AndroidManifest.xml`, serta receiver boot dari dokumentasi `flutter_local_notifications` agar pengingat bertahan setelah HP restart.
