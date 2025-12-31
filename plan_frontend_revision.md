Berikut draft **plan.md** singkat untuk revisi tampilan dan logic front end `cangkang_sawit_front_end`.[1][2]

***

# Frontend Revision Plan – Cangkang Sawit

## 1. Tujuan

- Menyelaraskan tampilan dan **logic** Flutter app dengan backend terbaru (ComprehensiveDataSeeder).  
- Memastikan semua peran (Admin, Mitra, Driver) bisa menjalankan alur utama tanpa error di lingkungan localhost.

***

## 2. Ruang Lingkup Revisi

- Admin:
  - Dashboard overview (stat card + quick actions).
  - Daftar pesanan + detail pesanan.
  - Manajemen produk.
  - Waybill list + detail.
- Mitra:
  - Daftar pesanan.
  - Detail pesanan + pembayaran.
  - Tracking pengiriman.
- Driver:
  - Daftar tugas pengiriman.
  - Detail tugas + update status (minimal tampil data).  
- General:
  - Error handling.
  - Loading & empty state.
  - Konsistensi bahasa dan format tampilan.

***

## 3. Workflow Revisi (Per Sprint Mini)

### Step 1 – Setup & Baseline

- Pastikan backend berjalan dengan data seeder terbaru:
  - `php artisan migrate:fresh --seed`
  - `php artisan db:seed --class=ComprehensiveDataSeeder`  
- Pastikan **baseUrl** di Flutter mengarah ke:
  - `http://localhost:8000/api`  
- Jalankan app:
  - `flutter run`  

Output yang diharapkan: aplikasi bisa login sebagai Admin, Mitra, Driver walaupun UI belum sempurna.

***

### Step 2 – Admin Flow

#### 2.1 Dashboard Admin

**File utama (contoh, sesuaikan dengan struktur project):**

- `lib/screens/admin/admin_overview_screen.dart`
- `lib/screens/admin/admin_dashboard_screen.dart`
- `lib/core/widgets/dashboard_stat_card.dart`
- `lib/core/widgets/dashboard_quick_action_button.dart`

**Task:**

- Pastikan memanggil `/api/admin/dashboard-summary` dan menggunakan field:
  - `new_orders`, `pending_shipments`, `active_partners`, `inventory_tons`
  - `orders_completed`, `orders_processing`, `orders_in_transit`, `orders_awaiting`
- Perbaiki tampilan:
  - Layout mirip desain referensi (header, 2x2 stat card, quick actions, order status).
  - Teks dan label dalam bahasa Indonesia.
- Logic navigasi:
  - `New Orders` → buka Orders dengan filter `status = pending`.
  - `Pending Shipments` → filter `status = on_delivery`.
  - `Inventory` / `Manage Products` → ke Kelola Produk.
  - `View All Shipments` → Orders tanpa filter.

#### 2.2 Daftar & Detail Pesanan Admin

**File:**

- `lib/screens/admin/admin_orders_screen.dart`
- `lib/screens/admin/admin_order_detail_screen.dart` (atau sejenis)
- `lib/repositories/order_repository.dart`

**Task:**

- Tambah/rapikan:
  - Parameter `initialStatus` untuk filter.
  - Status badge (Pending, Confirmed, On Delivery, Completed, Cancelled).
- Di detail pesanan:
  - Tampilkan produk (dari `order_items`), total harga, status pesanan, status pembayaran.
  - Tombol aksi admin (kalau ada) minimal tidak menyebabkan error.

***

### Step 3 – Mitra Flow

#### 3.1 Daftar Pesanan Mitra

**File:**

- `lib/screens/mitra/mitra_orders_screen.dart` (nama bisa berbeda)
- `lib/repositories/order_repository.dart`

**Task:**

- Load semua order milik Mitra login:
  - Tampilkan 3 pending + 1 on_delivery sesuai data sample.
- UI:
  - Judul: “Daftar Pesanan”.
  - Badge status, total harga, tanggal.
- Empty state:
  - Jika tidak ada data → tampilkan pesan “Belum ada pesanan”.

#### 3.2 Detail Pesanan + Pembayaran

**File:**

- `lib/screens/mitra/order_detail_screen.dart`
- `lib/repositories/payment_repository.dart`

**Task:**

- Tampilkan:
  - Kode pesanan, status, total amount, detail produk.
  - Status pembayaran: Paid / Pending / Failed / Expired.
- Logic tombol “Bayar Sekarang”:
  - **Hide / disable** jika payment status `paid`.
  - **Tampil aktif** jika `pending` / `unpaid`.
  - Tampilkan pesan jika `failed` / `expired`.
- Integrasi pembayaran:
  - Saat klik “Bayar Sekarang”, panggil endpoint payment (Tripay).
  - Buka URL pembayaran (webview / browser) jika tersedia.
  - Jika tidak ada URL → tampilkan snackbar error yang jelas.

***

### Step 4 – Tracking & Waybill

#### 4.1 Tracking Pengiriman (Mitra)

**File:**

- `lib/screens/mitra/order_tracking_screen.dart`
- `lib/repositories/tracking_repository.dart`

**Task:**

- Peta:
  - Gunakan Google Maps untuk menampilkan rute dari `delivery_tracks` (Semarang → Surabaya).
- Tampilkan:
  - Marker start (origin), end (destination), dan posisi terakhir driver.
  - Polyline menghubungkan semua titik.
  - Informasi driver (nama, email).
  - Status pengiriman: On Delivery / Completed.
- Error handling:
  - Jika tidak ada `delivery_order` → tampilkan teks: “Tracking belum tersedia untuk pesanan ini”.

#### 4.2 Waybill (Admin)

**File:**

- `lib/screens/admin/waybill_list_screen.dart`
- `lib/screens/admin/waybill_detail_screen.dart`
- `lib/repositories/waybill_repository.dart`

**Task:**

- List:
  - Tampilkan 3 waybill sample (nomor, order code, status).
  - Tambahkan pull-to-refresh.
- Detail:
  - Tampilkan data:
    - Nomor waybill, informasi order, driver, catatan, tanggal.
  - Sediakan tombol “Export PDF” (UI saja cukup jika backend belum full).

***

### Step 5 – Driver Flow

#### 5.1 Dashboard / Tugas Driver

**File:**

- `lib/screens/driver/driver_tasks_screen.dart`
- `lib/screens/driver/driver_task_detail_screen.dart`
- `lib/repositories/delivery_repository.dart`

**Task:**

- Tugas:
  - Tampilkan list delivery orders untuk driver login.
  - Minimal 1 tugas untuk `driver1@csawit.com`.
- Detail:
  - Tampilkan tujuan, status, dan snapshot map.
  - (Opsional) Tambah tombol update status (On The Way, Arrived, Completed) sesuai endpoint backend.

***

### Step 6 – General Hardening

**Lint & Analyze**

- Jalankan:
  - `flutter analyze`
  - Fix warning/error yang muncul.

**Error Handling & State**

- Di semua repository:
  - Tangkap exception dan kirim pesan user-friendly.
- Di semua list:
  - Tiga state jelas:
    - `loading` → CircularProgressIndicator / skeleton.
    - `success` → list data.
    - `error` → teks “Terjadi kesalahan…” + tombol coba lagi.

**Bahasa & Format**

- Pastikan semua string UI pakai Bahasa Indonesia.
- Format:
  - Harga → pakai format rupiah.
  - Tanggal/waktu → format lokal.

***

## 7. Testing Checklist

### Admin

- [ ] Login admin → dashboard tampil angka sesuai API (total_orders, inventory_tons).
- [ ] Klik New Orders → Orders dengan status Pending.
- [ ] Klik Pending Shipments → Orders dengan status On Delivery.
- [ ] Buka satu order → detail tampil lengkap.

### Mitra

- [ ] Login mitra → list 3 pending + 1 on_delivery.
- [ ] Buka detail → status + pembayaran benar.
- [ ] Tombol Bayar hilang jika sudah paid.
- [ ] Tracking map muncul untuk order on_delivery.

### Driver

- [ ] Login driver1 → minimal 1 tugas tampil.
- [ ] Detail tugas tampil lengkap.

### Waybill

- [ ] Waybill list menampilkan 3 data.
- [ ] Detail waybill tampil lengkap.

### Umum

- [ ] Tidak ada crash saat offline → tampil pesan koneksi.
- [ ] Pull-to-refresh berfungsi di semua list.
- [ ] `flutter analyze` tanpa error.

***
