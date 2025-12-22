# Plan Frontend - Cangkang Sawit Mobile (Flutter)

**Backend Repository:** https://github.com/tegars5/cangkang_sawit_backend

**Last Updated:** 2025-12-22

---

## 1. Auth & App Shell

### 1.1 Login & Authentication
- [x] Login screen dengan email & password
- [x] Integrasi POST /api/login
- [x] Simpan token ke SharedPreferences
- [x] Simpan role user (mitra/admin/driver)
- [x] Simpan user data
- [x] Error handling & validation
- [x] Loading state saat login
- [x] Password visibility toggle

### 1.2 App Initialization & Routing
- [x] Splash screen dengan auto-redirect
- [x] Cek token & role saat app start
- [x] Auto-redirect ke home sesuai role
- [x] Redirect ke login jika belum login
- [x] Named routes untuk navigasi
- [x] Role-based routing:
  - [x] mitra → /mitra/orders
  - [x] admin → /admin/orders
  - [x] driver → /driver/tasks

### 1.3 Logout
- [x] Tombol logout di semua role screens
- [x] Hapus token & role dari storage
- [x] Clear user data
- [x] Navigasi kembali ke login
- [x] Konfirmasi dialog sebelum logout

---

## 2. Mitra - Orders & Distance

### 2.1 Orders List Screen
- [x] Integrasi GET /api/orders
- [x] Tampilkan list orders dengan OrderListItem
- [x] Loading state saat fetch data
- [x] Error state dengan retry
- [x] Empty state (belum ada pesanan)
- [x] Pull to refresh
- [x] Tampilkan order code, status, destination, weight
- [x] Status color coding
- [x] Navigation ke detail screen
- [ ] Filter by status (opsional)
- [ ] Search orders (opsional)

### 2.2 Order Detail Screen
- [x] Tampilkan detail order (code, status, destination, weight, mitra name)
- [x] Status card dengan icon & color
- [x] Integrasi GET /api/orders/{orderId}/distance
- [x] Model OrderDistance untuk parsing
- [x] Tampilkan jarak dari gudang (km)
- [x] Tampilkan estimasi waktu (menit/jam)
- [x] Format: "Dari gudang: 5.3 km (±15 menit)"
- [x] Loading state untuk distance
- [x] Error handling untuk distance
- [x] Action buttons (tracking, cancel)
- [x] Implement cancel order (POST /api/orders/{order}/cancel)
- [x] Implement payment (POST /api/orders/{order}/pay)

### 2.3 Tracking Map (Opsional/Future)
- [ ] Buat TrackingScreen
- [ ] Integrasi google_maps_flutter
- [ ] GET /api/orders/{order}/tracking
- [ ] Tampilkan marker driver di map
- [ ] Panel bawah dengan info order
- [ ] Real-time location updates
- [ ] Distance & duration info

### 2.4 Create Order (Completed)
- [x] Form create order
- [x] POST /api/orders
- [x] Pilih produk
- [x] Input destination & weight
- [x] Validation

---

## 3. Admin - Dashboard, Orders, Assign Driver

### 3.1 Admin Dashboard
- [x] Integrasi GET /api/orders
- [x] Hitung statistik dari data orders
- [x] StatCard untuk total pesanan
- [x] StatCard untuk dalam pengiriman
- [x] StatCard untuk selesai
- [x] Tampilkan pesanan terbaru (10 items)
- [x] Loading state
- [x] Error handling
- [x] Pull to refresh
- [x] Responsive layout (mobile & tablet)

### 3.2 Admin Orders List
- [x] Integrasi GET /api/orders
- [x] Tampilkan semua orders
- [x] OrderListItem dengan info lengkap
- [x] Loading & error states
- [x] Navigation ke order actions
- [ ] Filter by status
- [ ] Search by order code
- [ ] Sort by date/status

### 3.3 Assign Driver (Completed)
- [x] Buat AssignDriverDialog
- [x] GET /api/admin/drivers (list drivers)
- [x] Radio/selection untuk pilih driver
- [x] POST /api/admin/orders/{order}/assign-driver
- [x] Loading state saat assign
- [x] Success/error feedback
- [x] Refresh orders setelah assign
- [x] Validation (driver availability)

### 3.4 Waybill Management (Opsional)
- [ ] Buat WaybillScreen
- [ ] GET /api/orders/{order}/waybill
- [ ] Tampilkan info waybill (no, tanggal, driver, kendaraan)
- [ ] Tombol "Download PDF"
- [ ] GET /api/orders/{order}/waybill/pdf
- [ ] Integrasi url_launcher untuk buka PDF
- [ ] POST /api/admin/orders/{order}/waybill (create/update)

---

## 4. Driver - Tasks, Distance, Tracking

### 4.1 Driver Tasks List
- [x] Integrasi GET /api/driver/orders
- [x] Tampilkan list tugas dengan OrderListItem
- [x] Status: assigned, on_the_way, arrived, completed
- [x] Loading & error states
- [x] Pull to refresh
- [x] Navigation ke task detail
- [x] Empty state (belum ada tugas)
- [x] Driver info card

### 4.2 Driver Task Detail Screen
- [x] Tampilkan detail task (code, status, destination, weight)
- [x] Status card dengan icon & color
- [x] Integrasi GET /driver/delivery-orders/{id}/distance
- [x] Model DriverDistance untuk parsing
- [x] Tampilkan jarak driver → tujuan (km)
- [x] Tampilkan estimasi waktu (menit)
- [x] Format: "Driver → tujuan: 1.2 km (±4 menit)"
- [x] Loading state untuk distance
- [x] Error handling untuk distance

### 4.3 Driver Actions
- [x] Update status button
- [x] Dialog pilihan status (on_the_way, arrived, completed)
- [x] POST /api/driver/delivery-orders/{id}/status
- [x] Kirim lokasi button
- [x] POST /api/driver/delivery-orders/{id}/track
- [x] Loading states untuk actions
- [x] Success/error feedback
- [x] Refresh task setelah update
- [x] Real GPS integration (ganti dummy coordinates)

### 4.4 Real GPS (Completed)
- [x] Integrasi package geolocator
- [x] Request location permission
- [x] Get current GPS coordinates
- [x] Ganti dummy lat/lng dengan GPS aktual
- [ ] Background location tracking (future)
- [ ] Auto-send location periodically (future)

---

## 5. Distance & Duration Features

### 5.1 Models
- [x] OrderDistance model
  - [x] Parse JSON response
  - [x] Properties: orderId, distanceKm, durationMinutes, origin, destination
  - [x] Helper: formattedDistance, formattedDuration, displayText
- [x] DriverDistance model
  - [x] Parse JSON response
  - [x] Properties: deliveryOrderId, distanceKm, durationMinutes, driverLocation, destination
  - [x] Helper: formattedDistance, formattedDuration, displayText

### 5.2 API Integration
- [x] ApiClient.getOrderDistance(orderId)
- [x] ApiClient.getDriverDistance(deliveryOrderId)
- [x] Bearer token authentication
- [x] Error handling

### 5.3 UI Implementation
- [x] Distance card di OrderDetailScreen
- [x] Distance card di DriverTaskDetailScreen
- [x] Loading indicator
- [x] Error state dengan retry
- [x] Visual indicators (icons, colors)
- [x] Formatted display text

---

## 6. Shared Widgets & Theming

### 6.1 Theme System
- [x] AppColors - warna konsisten (#4CAF50 primary)
- [x] AppTextStyles - typography konsisten (Poppins)
- [x] AppSpacings - spacing konsisten (24-32 padding)
- [x] AppRadius - border radius konsisten
- [x] AppTheme - light theme configuration

### 6.2 Core Widgets
- [x] AppTextField - input field dengan validation
- [x] PrimaryButton - button dengan loading & icon support
- [x] AppCard - card dengan shadow & radius
- [x] IconContainer - icon dengan background
- [x] StatCard - card untuk statistik
- [x] OrderListItem - list item untuk orders/tasks

### 6.3 Utility Widgets (NEW)
- [x] InfoRow - icon + label + value
- [x] ErrorView - error state dengan retry button
- [x] LoadingSection - loading indicator dengan message

### 6.4 Widget Usage Guidelines
- [x] Semua screen menggunakan theme colors
- [x] Tidak ada hardcoded colors/spacing
- [x] Konsisten padding & spacing
- [x] Reusable components untuk DRY principle

---

## 7. API Client & Services

### 7.1 ApiClient Core
- [x] Base URL configuration
- [x] Token management (get, set, clear)
- [x] Role management (get, set)
- [x] User data management
- [x] HTTP methods: GET, POST, PUT, DELETE
- [x] Bearer token authentication
- [x] Error handling

### 7.2 API Endpoints Implemented
- [x] POST /api/login
- [x] POST /api/logout
- [x] GET /api/orders
- [x] GET /api/orders/{orderId}/distance
- [x] GET /api/driver/orders
- [x] GET /driver/delivery-orders/{id}/distance
- [x] POST /api/driver/delivery-orders/{id}/status
- [x] POST /api/driver/delivery-orders/{id}/track
- [x] GET /api/admin/drivers
- [x] POST /api/admin/orders/{order}/assign-driver
- [x] GET /api/products
- [x] POST /api/orders (create order)
- [x] POST /api/orders/{order}/cancel
- [x] POST /api/orders/{order}/pay

### 7.3 API Endpoints Pending
- [ ] POST /api/register
- [ ] GET /api/me
- [ ] GET /api/orders/{order}/tracking
- [ ] GET /api/orders/{order}/waybill
- [ ] POST /api/admin/orders/{order}/waybill
- [ ] GET /api/orders/{order}/waybill/pdf

---

## 8. Quality & Testing

### 8.1 Code Quality
- [x] Flutter analyze - 0 issues ✅
- [x] No hardcoded values
- [x] Consistent naming conventions
- [x] Proper error handling
- [x] Loading states everywhere
- [x] Clean architecture principles

### 8.2 Testing (Future)
- [ ] Unit tests untuk models
- [ ] Unit tests untuk API client
- [ ] Widget tests untuk shared widgets
- [ ] Integration tests untuk flows
- [ ] Mock API responses

### 8.3 Performance
- [x] Efficient state management
- [x] Proper async/await usage
- [x] No memory leaks (dispose controllers)
- [ ] Image optimization
- [ ] Lazy loading untuk lists

---

## 9. Documentation

### 9.1 Code Documentation
- [x] Widget documentation comments
- [x] Model documentation
- [x] API client documentation
- [x] Usage examples in comments

### 9.2 Project Documentation
- [x] README.md
- [x] task.md (checklist tracking)
- [x] plan_frontend.md (this file)
- [x] walkthrough.md (implementation details)
- [ ] API integration guide
- [ ] Deployment guide

### 9.3 Screenshots (Future)
- [ ] Login screen
- [ ] Mitra orders list
- [ ] Mitra order detail dengan distance
- [ ] Admin dashboard
- [ ] Admin orders list
- [ ] Driver tasks list
- [ ] Driver task detail dengan distance
- [ ] Error states
- [ ] Loading states

---

## 10. Future Enhancements

### 10.1 High Priority (Completed ✅)
- [x] Assign Driver functionality
- [x] Real GPS integration
- [x] Order creation flow
- [x] Payment integration

### 10.2 Medium Priority
- [ ] Tracking Map dengan Google Maps
- [ ] Waybill management
- [ ] Push notifications
- [ ] Offline support

### 10.3 Low Priority
- [ ] Dark mode
- [ ] Multi-language support
- [ ] Advanced filtering & search
- [ ] Export reports
- [ ] Analytics dashboard

---

## Summary

### ✅ Completed Features (Core Functionality)
- Authentication & routing
- Mitra orders with distance info
- Admin dashboard with statistics
- Driver tasks with distance info
- Distance calculation features
- Shared widgets & theming
- **Assign Driver functionality** ✅ NEW
- **Real GPS integration** ✅ NEW
- **Order creation flow** ✅ NEW
- **Payment integration** ✅ NEW
- Clean code with 0 errors

### 🔄 In Progress
- Documentation & screenshots

### ⏳ Pending (Optional/Future)
- Tracking Map
- Waybill management
- Advanced features

**Total Progress:** ~90% of core features completed ✅

**Next Steps:**
1. ~~Implement Assign Driver dialog~~ ✅ DONE
2. ~~Add Real GPS integration~~ ✅ DONE
3. ~~Create Order Creation flow~~ ✅ DONE
4. ~~Add Payment integration~~ ✅ DONE
5. Create Tracking Map screen (optional)
6. Add Waybill management (optional)
7. Complete testing suite
