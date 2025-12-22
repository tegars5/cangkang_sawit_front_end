# Dokumentasi Aplikasi Flutter - Cangkang Sawit Mobile

## 📱 Struktur Project

```
lib/
├── main.dart                          # Entry point aplikasi
├── services/
│   └── api_client.dart               # HTTP client untuk komunikasi dengan backend Laravel
└── screens/
    ├── auth/
    │   └── login_screen.dart         # Halaman login
    └── mitra/
        └── orders_screen.dart        # Halaman orders untuk mitra (placeholder)
```

## 🔧 Konfigurasi

### 1. Base URL Backend

Edit file `lib/services/api_client.dart` baris 10:

```dart
static const String baseUrl = 'http://127.0.0.1:8000/api';
```

**Untuk testing di HP fisik**, ganti dengan IP komputer Anda:
```dart
static const String baseUrl = 'http://192.168.1.100:8000/api';
```

> **Cara mendapatkan IP komputer:**
> - Windows: Buka CMD, ketik `ipconfig`, lihat "IPv4 Address"
> - Mac/Linux: Buka Terminal, ketik `ifconfig` atau `ip addr`

### 2. Format Response Laravel

Aplikasi ini mengharapkan response dari endpoint `POST /api/login` dengan format:

```json
{
  "user": {
    "id": 1,
    "name": "Nama User",
    "email": "user@example.com",
    "role": "mitra"
  },
  "token": "1|xxxxxxxxxxxxxxxx"
}
```

**Role yang didukung:**
- `mitra` → Diarahkan ke `MitraOrdersScreen`
- `admin` → Placeholder (akan diarahkan ke AdminDashboardScreen)
- `driver` → Placeholder (akan diarahkan ke DriverDashboardScreen)

## 🚀 Cara Menjalankan

### 1. Install Dependencies

```bash
flutter pub get
```

### 2. Jalankan Aplikasi

```bash
flutter run
```

### 3. Testing di HP Fisik

1. Pastikan HP dan komputer terhubung ke WiFi yang sama
2. Ganti `baseUrl` di `api_client.dart` dengan IP komputer Anda
3. Pastikan Laravel backend sudah running di `php artisan serve --host=0.0.0.0`
4. Jalankan `flutter run` dan pilih device HP Anda

## 📝 Fitur yang Sudah Diimplementasi

### ✅ ApiClient (`lib/services/api_client.dart`)

**Method yang tersedia:**

| Method | Fungsi | Parameter |
|--------|--------|-----------|
| `setToken(String token)` | Simpan token ke SharedPreferences | token |
| `getToken()` | Ambil token dari SharedPreferences | - |
| `clearToken()` | Hapus token | - |
| `setRole(String role)` | Simpan role user | role |
| `getRole()` | Ambil role user | - |
| `setUserData(Map)` | Simpan data user lengkap | userData |
| `getUserData()` | Ambil data user lengkap | - |
| `clearAllData()` | Hapus semua data (untuk logout) | - |
| `get(String path)` | HTTP GET request | path endpoint |
| `post(String path, Map body)` | HTTP POST request | path, body JSON |
| `put(String path, Map body)` | HTTP PUT request | path, body JSON |
| `delete(String path)` | HTTP DELETE request | path endpoint |

**Contoh penggunaan:**

```dart
final apiClient = ApiClient();

// Login
final response = await apiClient.post('/login', {
  'email': 'user@example.com',
  'password': 'password123',
});

// Get data dengan token
final ordersResponse = await apiClient.get('/orders');

// Logout
await apiClient.clearAllData();
```

### ✅ LoginScreen (`lib/screens/auth/login_screen.dart`)

**Fitur:**
- Form validation untuk email dan password
- Toggle visibility password
- Loading indicator saat login
- Error handling dengan dialog
- Auto-navigate berdasarkan role setelah login berhasil
- Menyimpan token, role, dan user data ke SharedPreferences

**Flow:**
1. User input email & password
2. Validasi form
3. Kirim POST request ke `/api/login`
4. Jika sukses:
   - Simpan token, role, dan user data
   - Navigate ke screen sesuai role
5. Jika gagal:
   - Tampilkan error dialog

### ✅ MitraOrdersScreen (`lib/screens/mitra/orders_screen.dart`)

**Fitur:**
- Menampilkan informasi user yang login
- Tombol logout dengan konfirmasi
- Placeholder untuk fitur orders (siap dikembangkan)

**Flow logout:**
1. User klik tombol logout
2. Tampilkan dialog konfirmasi
3. Jika confirm:
   - Hapus semua data dari SharedPreferences
   - Navigate ke LoginScreen

### ✅ Main App (`lib/main.dart`)

**Fitur:**
- Auto-login: Cek token saat app dibuka
- Jika ada token → langsung ke screen sesuai role
- Jika tidak ada token → ke LoginScreen
- Tema aplikasi menggunakan Google Fonts Poppins
- Material 3 design
- Warna tema hijau (#2E7D32) sesuai tema cangkang sawit

## 🎨 Tema Aplikasi

**Primary Color:** Dark Green (#2E7D32)

**Font:** Google Fonts Poppins

**Design System:**
- Border radius: 12px
- Card elevation: 2
- Button padding: 24px horizontal, 12px vertical
- Input field dengan filled background

## 🔐 Autentikasi Flow

```
App Start
    ↓
Cek Token di SharedPreferences
    ↓
    ├─ Ada Token → Cek Role
    │       ├─ mitra → MitraOrdersScreen
    │       ├─ admin → AdminDashboardScreen (TODO)
    │       └─ driver → DriverDashboardScreen (TODO)
    │
    └─ Tidak Ada Token → LoginScreen
            ↓
        User Login
            ↓
        POST /api/login
            ↓
        ├─ Success → Simpan token & role → Navigate
        └─ Failed → Show Error Dialog
```

## 📦 Dependencies yang Digunakan

```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^latest           # HTTP client untuk API calls
  shared_preferences: ^latest  # Local storage untuk token
  google_fonts: ^latest   # Google Fonts Poppins
```

## 🛠️ Pengembangan Selanjutnya

### TODO List:

1. **Admin Dashboard Screen**
   - Buat file `lib/screens/admin/dashboard_screen.dart`
   - Implementasi fitur admin

2. **Driver Dashboard Screen**
   - Buat file `lib/screens/driver/dashboard_screen.dart`
   - Implementasi fitur driver

3. **Mitra Orders Screen - Implementasi Lengkap**
   - Fetch orders dari API
   - Tampilkan list orders
   - Detail order
   - Tracking pengiriman

4. **Error Handling yang Lebih Baik**
   - Interceptor untuk handle 401 (unauthorized)
   - Auto-logout jika token expired
   - Retry mechanism

5. **Loading States**
   - Skeleton loading
   - Pull to refresh
   - Infinite scroll

### Contoh Implementasi Fetch Orders:

```dart
// Di MitraOrdersScreen
Future<void> _fetchOrders() async {
  try {
    final response = await _apiClient.get('/orders');
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _orders = data['orders'];
      });
    }
  } catch (e) {
    // Handle error
  }
}
```

## 🐛 Troubleshooting

### 1. Error: Connection Refused

**Solusi:**
- Pastikan Laravel backend sudah running
- Cek base URL sudah benar
- Jika testing di HP, pastikan WiFi sama dan gunakan IP komputer

### 2. Error: Token Invalid

**Solusi:**
- Logout dan login ulang
- Cek format token di response Laravel
- Pastikan Sanctum sudah dikonfigurasi dengan benar di Laravel

### 3. Error: CORS

**Solusi:**
- Pastikan CORS sudah dikonfigurasi di Laravel
- Tambahkan header yang diperlukan di backend

## 📞 Kontak & Support

Jika ada pertanyaan atau issue, silakan hubungi developer atau buat issue di repository.

---

**Dibuat dengan ❤️ untuk Sistem Manajemen Logistik Cangkang Sawit**
