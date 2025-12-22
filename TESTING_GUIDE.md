# 🧪 Testing Guide - Cangkang Sawit Mobile

## Quick Start Testing

### 1. Persiapan Backend Laravel

Pastikan backend Laravel sudah running:

```bash
cd path/to/cangkang_sawit_backend
php artisan serve
```

Atau jika ingin diakses dari HP:

```bash
php artisan serve --host=0.0.0.0 --port=8000
```

### 2. Kredensial Testing

Gunakan kredensial yang sudah ada di database Laravel Anda. Contoh:

**Mitra:**
```
Email: mitra1@example.com
Password: password
```

**Admin:**
```
Email: admin@example.com
Password: password
```

**Driver:**
```
Email: driver1@example.com
Password: password
```

> ⚠️ **Penting:** Sesuaikan dengan data yang ada di database Laravel Anda!

### 3. Langkah Testing

#### A. Testing di Emulator/Simulator

1. Pastikan base URL di `lib/services/api_client.dart`:
   ```dart
   static const String baseUrl = 'http://10.0.2.2:8000/api';  // Android Emulator
   // atau
   static const String baseUrl = 'http://127.0.0.1:8000/api'; // iOS Simulator
   ```

2. Jalankan aplikasi:
   ```bash
   flutter run
   ```

3. Login dengan kredensial mitra
4. Verifikasi:
   - ✅ Login berhasil
   - ✅ Token tersimpan
   - ✅ Navigate ke MitraOrdersScreen
   - ✅ Nama dan email user ditampilkan

#### B. Testing di HP Fisik

1. Cari IP komputer Anda:
   ```bash
   # Windows
   ipconfig
   
   # Mac/Linux
   ifconfig
   ```
   Contoh hasil: `192.168.1.100`

2. Update base URL di `lib/services/api_client.dart`:
   ```dart
   static const String baseUrl = 'http://192.168.1.100:8000/api';
   ```

3. Pastikan HP dan komputer di WiFi yang sama

4. Jalankan Laravel backend:
   ```bash
   php artisan serve --host=0.0.0.0
   ```

5. Jalankan Flutter app:
   ```bash
   flutter run
   ```

6. Test login di HP

### 4. Checklist Testing

#### ✅ Login Flow
- [ ] Form validation bekerja (email kosong)
- [ ] Form validation bekerja (password < 6 karakter)
- [ ] Form validation bekerja (email tidak valid)
- [ ] Loading indicator muncul saat login
- [ ] Error dialog muncul jika kredensial salah
- [ ] Login berhasil dengan kredensial yang benar
- [ ] Token tersimpan di SharedPreferences
- [ ] Navigate ke screen yang sesuai dengan role

#### ✅ Auto-Login
- [ ] Close app setelah login
- [ ] Buka app lagi
- [ ] Langsung masuk ke screen sesuai role (tidak perlu login lagi)

#### ✅ Logout Flow
- [ ] Tombol logout muncul di AppBar
- [ ] Dialog konfirmasi muncul saat klik logout
- [ ] Batal logout bekerja
- [ ] Logout berhasil dan kembali ke LoginScreen
- [ ] Token terhapus dari SharedPreferences
- [ ] Tidak bisa auto-login setelah logout

#### ✅ Role-Based Navigation
- [ ] Login sebagai mitra → MitraOrdersScreen
- [ ] Login sebagai admin → Show success dialog (placeholder)
- [ ] Login sebagai driver → Show success dialog (placeholder)

### 5. Testing API Calls

#### Manual Test dengan Postman/Thunder Client

**Login Request:**
```
POST http://127.0.0.1:8000/api/login
Content-Type: application/json

{
  "email": "mitra1@example.com",
  "password": "password"
}
```

**Expected Response:**
```json
{
  "user": {
    "id": 1,
    "name": "Mitra Satu",
    "email": "mitra1@example.com",
    "role": "mitra"
  },
  "token": "1|xxxxxxxxxxxxxxxx"
}
```

### 6. Debug Tips

#### Lihat Console Log

Tambahkan print statement untuk debugging:

```dart
// Di login_screen.dart, setelah response
print('Response status: ${response.statusCode}');
print('Response body: ${response.body}');
```

#### Cek SharedPreferences

Tambahkan di `_loadUserData()` di MitraOrdersScreen:

```dart
Future<void> _loadUserData() async {
  final userData = await _apiClient.getUserData();
  final token = await _apiClient.getToken();
  final role = await _apiClient.getRole();
  
  print('User Data: $userData');
  print('Token: $token');
  print('Role: $role');
  
  setState(() {
    _userData = userData;
  });
}
```

#### Clear SharedPreferences

Jika perlu reset data:

```dart
// Tambahkan button temporary untuk clear data
ElevatedButton(
  onPressed: () async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    print('All data cleared!');
  },
  child: Text('Clear All Data'),
)
```

### 7. Common Issues & Solutions

| Issue | Solusi |
|-------|--------|
| Connection refused | Cek Laravel sudah running, cek base URL |
| CORS error | Tambahkan CORS middleware di Laravel |
| Token invalid | Cek format response Laravel, pastikan ada field "token" |
| Auto-login tidak bekerja | Cek token tersimpan dengan benar |
| Tidak bisa logout | Cek route '/login' sudah terdaftar |

### 8. Next Steps After Testing

Setelah semua testing berhasil:

1. ✅ Implementasi fitur orders untuk mitra
2. ✅ Implementasi admin dashboard
3. ✅ Implementasi driver dashboard
4. ✅ Tambahkan fitur tracking
5. ✅ Tambahkan fitur waybill

---

## 📱 Screenshot Testing Checklist

Ambil screenshot untuk dokumentasi:

1. Login screen (empty state)
2. Login screen (with validation errors)
3. Login screen (loading state)
4. Mitra orders screen (logged in)
5. Logout confirmation dialog
6. Login screen (after logout)

---

**Happy Testing! 🚀**
