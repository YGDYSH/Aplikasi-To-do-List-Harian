class AppStrings {
  const AppStrings._();

  static const appName = 'Tugasku';
  static const fontPrimary = 'Plus Jakarta Sans';
  static const localeId = 'id';

  static const tabTasks = 'Daftar';
  static const tabCalendar = 'Kalender';
  static const addTask = 'Tambah Tugas';

  static const onboardingTitle = 'Selesaikan Tugasmu';
  static const onboardingSubtitle =
      'Hanya satu sentuhan untuk mulai merencanakan aktivitas harianmu.';
  static const onboardingNext = 'Lanjut';

  static const profileTitle = 'Ayo Mulai!';
  static const profileSubtitle = 'Siapa namamu?';
  static const nameLabel = 'NAMA';
  static const nameHint = 'Namamu';
  static const startButton = 'Mulai';

  static const dashboardTitle = 'Dasbor';
  static const tasksTitle = 'Tugasku';
  static const calendarTitle = 'Kalender';
  static const todayGreeting = 'Hari ini';

  static const groupToday = 'Hari Ini';
  static const groupTomorrow = 'Besok';
  static const groupThisWeek = 'Minggu Ini';
  static const groupLater = 'Nanti';
  static const groupNoDate = 'Tanpa Tanggal';

  static const searchTasksHint = 'Cari tugas...';
  static const searchScheduleHint = 'Cari jadwal atau tugas...';
  static const sortTitle = 'Urutkan';
  static const sortDueDate = 'Tanggal Jatuh Tempo';
  static const sortPriority = 'Prioritas';
  static const sortLabel = 'Label';
  static const sortProject = 'Proyek';

  static const labelIconTooltip = 'Atur label';
  static const dateIconTooltip = 'Atur tanggal';
  static const timeIconTooltip = 'Atur waktu';
  static const noteIconTooltip = 'Atur catatan';
  static const attachLabels = 'Pasang label';
  static const cancelButton = 'Batal';
  static const noLabelsYet = 'Belum ada label';

  static const taskUnit = 'TUGAS';
  static const addTaskPrompt = 'Apa yang ingin kamu kerjakan?';
  static const addTaskHint = 'Tambahkan tugas baru...';
  static const reminderHint = 'Pengingat otomatis disetel untuk 15.00 WIB';

  static const tasksEmptyTitle = 'Belum ada tugas';
  static const taskLoadError = 'Gagal memuat tugas';
  static const editTaskTitle = 'Ubah Tugas';
  static const saveButton = 'Simpan';
  static const dateLabel = 'Tanggal';
  static const timeLabel = 'Waktu';
  static const labelLabel = 'Label';
  static const noteLabel = 'Catatan';
  static const selectLabelsTitle = 'Pilih label';
  static const selectedItems = 'dipilih';
  static const clearAllButton = 'Hapus semua';

  static const taskDeleted = 'Tugas dihapus';
  static const undoAction = 'Urungkan';

  static const tasksPlaceholder = 'Daftar tugasmu akan muncul di sini';
  static const calendarPlaceholder = 'Jadwalmu akan muncul di sini';

  // Prioritas (Bagian 3.7 & Dialog Urutkan 3.5)
  static const priorityIconTooltip = 'Atur prioritas';
  static const priorityLow = 'Rendah';
  static const priorityMedium = 'Sedang';
  static const priorityHigh = 'Tinggi';

  // Dasbor (Bagian 3.3)
  static const dashboardProjects = 'Proyek';
  static const dashboardLabels = 'Label';
  static const dashboardStatus = 'Status';
  static const shortcutKanban = 'Kanban';
  static const dashboardSettingsTooltip = 'Ubah nama';
  static const statusNotStarted = 'Belum Mulai';
  static const statusInProgress = 'Sedang Dikerjakan';
  static const statusCompleted = 'Selesai';
  static const addProjectTitle = 'Tambah Proyek';
  static const addProjectNameHint = 'Nama proyek';
  static const addLabelTitle = 'Tambah Label';
  static const addLabelNameHint = 'Nama label';
  static const noProjectsYet = 'Belum ada proyek';
  static const saveChangesButton = 'Simpan';

  // Kalender (Bagian 3.6)
  static const scheduledTasksSection = 'Tugas Terjadwal';
  static const weekTasksSection = 'Jadwal Tugas';
  static const viewAllLink = 'Lihat Semua';
  static const timezoneSuffix = 'WIB';
  static const calendarModeMonth = 'Bulan';
  static const calendarModeWeek = 'Minggu';
  static String calendarTasksScheduledToday(int count) =>
      '$count $taskUnit dijadwalkan hari ini';
  static String taskTimeRange(String time) => '$time $timezoneSuffix';

  // Statistik empty state (Bagian 3.6 Halaman 11)
  static const statsCompletedLabel = 'TERSELESAIKAN';
  static const statsProductivityLabel = 'PRODUKTIVITAS';
  static const statsTaskUnit = 'Tugas';
  static const statsYayTitle = 'Hebat! Kamu telah menyelesaikan semua tugas hari ini';
  static const statsYaySubtitle = 'atau ketuk tombol + untuk menambahkan tugas baru';
  static const statsCategorySection = 'Kategori Tugas';
  static String statsCompletedValue(int count) => '$count $statsTaskUnit';
  static String statsProductivityValue(int percent) => '$percent% Selesai';

  // Notifikasi pengingat
  static const reminderNotificationBody = 'Waktunya mengerjakan tugas ini';

  // Tugas berulang (Tahap 5, Bagian 3.4)
  static const repeatIconTooltip = 'Atur pengulangan';
  static const repeatNone = 'Tidak Berulang';
  static const repeatDaily = 'Harian';
  static const repeatTwoDays = 'Setiap dua hari';
  static const repeatWeekly = 'Mingguan';

  // Tambah Cepat parsing (Tahap 5, Bagian 3.7)
  static const quickParseIconTooltip = 'Contoh: "besok pukul 15.00"';

  // Kanban (Tahap 5)
  static const kanbanTitle = 'Kanban';

  // Cadangan data JSON via clipboard (Tahap 5)
  static const dataSectionLabel = 'Data';
  static const exportDataButton = 'Ekspor Data';
  static const importDataButton = 'Impor Data';
  static const exportDataDone = 'Data disalin ke clipboard';
  static const importDialogTitle = 'Impor Data';
  static const importHint = 'Tempel JSON di sini...';
  static const importConfirmButton = 'Impor';
  static const importEmptyClipboard = 'Clipboard kosong';
  static const importNontaskJson = 'Format JSON tidak dikenali';
  static String importDone(int count) => '$count tugas diimpor';
}
