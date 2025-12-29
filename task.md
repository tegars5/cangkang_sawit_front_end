Tolong refactor dan redesign AdminDashboardScreen di Flutter project cangkang_sawit_mobile supaya mengikuti layout referensi di screen.jpg (dashboard admin Fujiyama Biomass) dan semua elemen berfungsi.

Struktur dan perilaku yang diinginkan:

1. Layout Dashboard
File utama:

lib/screens/admin/admin_dashboard_screen.dart

lib/core/widgets/stat_card.dart atau widget baru untuk kartu statistik

lib/screens/admin/admin_orders_screen.dart

lib/screens/admin/admin_products_screen.dart

lib/screens/admin/assign_driver_dialog.dart (kalau perlu untuk navigasi lanjutan)

Bagian layout:

Header:

Teks: "Welcome back, {nama admin}" (ambil dari user login jika memungkinkan).

Teks kecil: "Last updated: {jam:menit}" berdasarkan waktu terakhir refresh summary dari API.

Grid Stat Cards (2 kolom, 2 baris):

Card 1: "New Orders" → value = jumlah pesanan dengan status pending.

Card 2: "Pending Shipments" → value = jumlah pesanan dengan status on_delivery.

Card 3: "Active Partners" → value = jumlah mitra aktif (boleh sementara hidden jika backend belum ada).

Card 4: "Inventory (Tons)" → value = total stok produk dalam ton (boleh placeholder dulu).

Semua card harus:

Menggunakan widget reusable, misalnya DashboardStatCard.

Dibungkus InkWell / GestureDetector dengan onTap.

Quick Actions (tiga tombol besar):

"Create New Order"

onTap → navigasi ke screen pembuatan pesanan oleh admin (kalau belum ada, boleh sementara arahkan ke CreateOrderScreen untuk Mitra).

"Manage Products"

onTap → navigasi ke AdminProductsScreen.

"View All Shipments"

onTap → navigasi ke AdminOrdersScreen tanpa filter (semua pesanan).

Desain seperti di contoh: tombol full-width, ikon di kiri, teks di tengah.

Order Status (sementara simple)

Box yang menampilkan:

Total Orders (angka).

Breakdown singkat: Completed, In Transit, Processing, Awaiting (boleh dalam bentuk legenda list dulu, tidak harus chart pie).

Data diambil dari summary API backend yang sudah ada (/admin/dashboard-summary).

Recent Activity (opsional, boleh placeholder):

List 2–3 item dengan icon, title, dan waktu relatif (“2 minutes ago”).

Placeholder static dulu, nanti bisa dihubungkan ke activity log.

2. Perilaku Interaktif / Navigasi
Stat Card OnTap:

New Orders:

onTap → buka AdminOrdersScreen(initialStatus: 'pending').

Pending Shipments:

onTap → buka AdminOrdersScreen(initialStatus: 'on_delivery').

Active Partners:

sementara bisa TODO atau arahkan ke screen list mitra jika sudah ada.

Inventory:

onTap → AdminProductsScreen.

Filter di AdminOrdersScreen:

Tambah optional parameter final String? initialStatus;.

Jika initialStatus != null, saat initState:

Set filter status sesuai nilai parameter.

Tampilkan indikator kecil di atas list:

Text: "Pesanan terfilter: {status dalam Bahasa Indonesia}".

Tombol "Hapus Filter" untuk reset dan menampilkan semua pesanan.

State Handling:

Dashboard harus memanggil summary API yang sudah ada, misalnya di initState:

AdminDashboardRepository.getSummary() → mengisi _totalOrders, _pendingCount, _inDeliveryCount, _completedCount, dsb.

Tampilkan CircularProgressIndicator saat loading.

Jika error, tampilkan snackbar dengan pesan yang jelas dalam Bahasa Indonesia.

3. Reusable Widgets
Tolong buat widget-widget berikut (jika belum ada):

DashboardStatCard:

Props: title, value, icon, onTap.

Stylenya mirip card putih rounded di contoh, dengan icon kecil di atas, angka besar, label kecil.

DashboardQuickActionButton:

Props: icon, label, onTap.

Full-width button, background bisa warna navy/primary untuk yang utama ("Create New Order") dan putih dengan border untuk yang lain.

4. Konsistensi Desain & Bahasa
Gunakan warna dan typography yang sudah ada di app (hijau Cangkang Sawit, dsb.), tapi layout mengikuti struktur contoh screen.jpg.

Semua teks dalam Bahasa Indonesia yang natural.

Tetap integrasikan bottom navigation admin yang sudah ada (tab Pesanan/Produk) tanpa merusak struktur routing.

Setelah selesai:

Update walkthrough.md dengan section “Redesain Dashboard Admin” yang menjelaskan perubahan layout dan perilaku baru.

Pastikan tidak ada breaking change di screen lain (orders, products, waybill, tracking).