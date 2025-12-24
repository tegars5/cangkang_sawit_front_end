/// Application string resources
class AppStrings {
  // App
  static const String appName = 'Cangkang Sawit';

  // Auth
  static const String login = 'Masuk';
  static const String logout = 'Keluar';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String loginSuccess = 'Login berhasil';
  static const String loginFailed = 'Login gagal';
  static const String logoutConfirm = 'Apakah Anda yakin ingin keluar?';

  // Common
  static const String loading = 'Memuat...';
  static const String retry = 'Coba Lagi';
  static const String cancel = 'Batal';
  static const String save = 'Simpan';
  static const String delete = 'Hapus';
  static const String edit = 'Edit';
  static const String submit = 'Kirim';
  static const String confirm = 'Konfirmasi';
  static const String yes = 'Ya';
  static const String no = 'Tidak';

  // Orders
  static const String orders = 'Pesanan';
  static const String orderDetails = 'Detail Pesanan';
  static const String createOrder = 'Buat Pesanan';
  static const String orderCreatedSuccess = 'Pesanan berhasil dibuat';
  static const String orderCancelledSuccess = 'Pesanan berhasil dibatalkan';
  static const String cancelOrder = 'Batalkan Pesanan';
  static const String cancelOrderConfirm =
      'Apakah Anda yakin ingin membatalkan pesanan ini?';
  static const String payNow = 'Bayar Sekarang';
  static const String trackDelivery = 'Lacak Pengiriman';

  // Products
  static const String selectProduct = 'Pilih Produk';
  static const String product = 'Produk';

  // Form Fields
  static const String destination = 'Alamat Tujuan';
  static const String weight = 'Berat';
  static const String deliveryDate = 'Tanggal Pengiriman';
  static const String notes = 'Catatan';
  static const String notesOptional = 'Catatan (Opsional)';
  static const String totalPrice = 'Total Harga';

  // Placeholders
  static const String enterDestination =
      'Masukkan alamat lengkap tujuan pengiriman';
  static const String enterWeight = 'Masukkan berat dalam ton';
  static const String selectDeliveryDate = 'Pilih tanggal pengiriman';
  static const String addNotes = 'Tambahkan catatan jika diperlukan';

  // Driver
  static const String tasks = 'Tugas';
  static const String taskDetails = 'Detail Tugas';
  static const String updateStatus = 'Update Status';
  static const String sendLocation = 'Kirim Lokasi Saat Ini';
  static const String locationSentSuccess = 'Lokasi berhasil dikirim';

  // Admin
  static const String dashboard = 'Dashboard';
  static const String assignDriver = 'Assign Driver';
  static const String driverAssignedSuccess = 'Driver berhasil ditugaskan';

  // Status
  static const String pending = 'Menunggu';
  static const String onDelivery = 'Dikirim';
  static const String completed = 'Selesai';
  static const String cancelled = 'Dibatalkan';

  // Errors
  static const String errorGeneric = 'Terjadi kesalahan';
  static const String errorNetwork = 'Gagal terhubung ke server';
  static const String errorLoadData = 'Gagal memuat data';
  static const String errorInvalidInput = 'Input tidak valid';
  static const String errorPermissionDenied = 'Izin ditolak';
  static const String errorLocationDenied = 'Izin lokasi ditolak';
  static const String errorLocationDeniedPermanent =
      'Izin lokasi ditolak permanen. Aktifkan di pengaturan.';

  // Empty States
  static const String noOrders = 'Belum ada pesanan';
  static const String noTasks = 'Belum ada tugas';
  static const String noProducts = 'Tidak ada produk tersedia';
  static const String noDrivers = 'Tidak ada driver tersedia';

  // Validation
  static const String fieldRequired = 'harus diisi';
  static const String emailInvalid = 'Format email tidak valid';
  static const String passwordTooShort = 'Password minimal 6 karakter';
  static const String addressTooShort = 'Alamat terlalu pendek';
  static const String weightInvalid = 'Berat harus berupa angka positif';
}
