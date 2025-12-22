plan.md – Cangkang Sawit App (End‑to‑End)
1. Tujuan Proyek
Membangun sistem manajemen penjualan & pengiriman cangkang sawit dengan:

Backend Laravel (REST API)

Mobile app Flutter (Mitra, Admin, Driver)

Fitur utama:

Pemesanan produk

Pembayaran online

Penugasan driver

Tracking pengiriman real‑time

Surat jalan (waybill) + PDF

UI modern terinspirasi dari Stitch design reference
https://stitch.withgoogle.com/projects/17568227581934998648

2. Lingkup Backend (Laravel)
Status: SUDAH SELESAI & TERUJI.
​

2.1 Autentikasi & Role
Laravel Sanctum untuk API token.

Role: admin, mitra, driver.

Endpoint:

POST /api/register

POST /api/login

POST /api/logout

GET /api/me

2.2 Manajemen Produk & Pesanan
Produk:

GET /api/products

POST /api/products (admin)

Pesanan (mitra):

GET /api/orders

POST /api/orders

GET /api/orders/{order}

POST /api/orders/{order}/cancel

POST /api/orders/{order}/pay

2.3 Pembayaran (Tripay)
Callback: POST /api/payment/tripay/callback

Sinkronisasi status pembayaran → status orders.

2.4 Pengiriman & Tracking
Assign driver (admin):

POST /api/admin/orders/{order}/assign-driver

Buat/update delivery_orders, set status assigned, on_delivery.

Driver:

GET /api/driver/orders

POST /api/driver/delivery-orders/{id}/status

POST /api/driver/delivery-orders/{id}/track

Tracking untuk mitra:

GET /api/orders/{order}/tracking

Mengembalikan status pengiriman + posisi GPS terakhir.
​

2.5 Surat Jalan (Waybill) + PDF
Buat/update waybill (admin):

POST /api/admin/orders/{order}/waybill

Lihat waybill (admin/mitra pemilik order):

GET /api/orders/{order}/waybill

Download PDF:

GET /api/orders/{order}/waybill/pdf

Menggunakan barryvdh/laravel-dompdf dan view waybill.blade.php.
​

3. Lingkup Frontend (Flutter)
Status: Kerangka & UI utama SUDAH JADI, tinggal integrasi API penuh.
​

3.1 Struktur Project
lib/main.dart – routing & bootstrap (gunakan AppTheme.lightTheme).

lib/services/api_client.dart – HTTP client + token (http + shared_preferences).

lib/core/theme/ – AppColors, AppTextStyles, AppSpacings, AppRadius, AppTheme.

lib/core/widgets/ –

AppTextField

PrimaryButton

AppCard

IconContainer

StatCard

OrderListItem
​

lib/screens/auth/login_screen.dart

lib/screens/mitra/mitra_orders_screen.dart

lib/screens/admin/admin_orders_screen.dart

lib/screens/driver/driver_tasks_screen.dart

3.2 Desain (Mengacu Stitch)
Poppins font, warna hijau utama #4CAF50, background netral, card dengan shadow lembut.

Layout lapang: padding 24–32, spacing antar section 24–48.

Konsistensi:

Semua warna/spacing/typography lewat theme (AppColors, dll.).

Tidak ada hardcoded style di screen.
​

4. Task Frontend – Integrasi & Penyempurnaan
4.1 Login & Routing Role
Status: SUDAH.
​

Login ke /api/login, simpan:

token (SharedPreferences).

role user.

Navigasi berdasarkan role:

mitra → /mitra/orders

admin → /admin/orders

driver → /driver/tasks

4.2 Mitra – Orders Screen (API)
Status: DALAM PENGEMBANGAN.

Panggil GET /api/orders dengan ApiClient.

Tampilkan:

List order (kode, status, total, tujuan) memakai OrderListItem atau card.

UX:

Loading state + error state.

(Opsional) Tombol ke detail tracking → nantinya memanggil GET /api/orders/{order}/tracking.

4.3 Admin – Dashboard & Orders (API)
Status: DALAM PENGEMBANGAN.

Panggil GET /api/orders.

Hitung & tampilkan dengan StatCard:

Total pesanan.

Dalam pengiriman.

Selesai.

“Pesanan Terbaru”:

List beberapa order terbaru dengan OrderListItem.

(Plan lanjutan):

Action “Assign Driver” → nanti memanggil POST /api/admin/orders/{order}/assign-driver via dialog/bottom sheet.

4.4 Driver – Tasks & Actions (API)
Status: DALAM PENGEMBANGAN.

Panggil GET /api/driver/orders.

Tampilkan list tugas dengan OrderListItem (status: assigned, on_the_way, completed, dll.).

Saat tap item:

Bottom sheet:

Ubah status → POST /api/driver/delivery-orders/{id}/status.

Kirim lokasi → POST /api/driver/delivery-orders/{id}/track (dummy lat/lng dulu).

UX:

Gunakan PrimaryButton, loading & error state.

4.5 Tracking Map (Mitra) – (OPSIONAL / LANJUTAN)
Halaman tracking yang memanggil GET /api/orders/{order}/tracking.

Tampilkan:

Detail order + driver.

Marker posisi driver di Google Maps (pakai google_maps_flutter).

Desain mengikuti Stitch: map dengan panel bawah (bottom sheet) berisi info singkat.

4.6 Waybill View & Download (Mitra/Admin) – (LANJUTAN)
Screen sederhana untuk:

Menampilkan data waybill dari GET /api/orders/{order}/waybill.

Tombol “Download PDF” → buka GET /api/orders/{order}/waybill/pdf di browser atau webview.

5. Quality & Dokumentasi
Jalankan flutter analyze → 0 issue.

Jalankan php artisan test atau minimal manual test untuk semua endpoint utama.

Screenshot:

Login, Mitra Orders, Admin Dashboard, Driver Tasks, Tracking, Waybill/PDF.

Dokumentasi skripsi:

Diagram arsitektur sistem (Client Flutter – API Laravel – Database).

Diagram flow utama:

Mitra pesan → bayar → admin assign → driver kirim → mitra tracking → waybill PDF.

Penjelasan clean architecture di frontend (theme + widgets + screens)