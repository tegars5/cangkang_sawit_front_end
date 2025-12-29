Status sekarang
Backend:

Endpoint products (index, store, show, update, delete) sudah siap dengan field name, description, price, stock, category, images.
​

Frontend:

Belum ada:

product_repository.dart

admin_products_screen.dart

product_form_screen.dart

product_card.dart

Belum ada menu navigasi ke layar produk di dashboard admin. 

2. Langkah next untuk Product Management
Disarankan urutan:

Model & Repository

Buat models/product.dart (kalau belum) dengan field yang sama seperti backend.

Buat services/product_repository.dart:

Future<List<Product>> getProducts()

Future<Product> createProduct(...)

Future<Product> updateProduct(...)

Future<void> deleteProduct(int id)

Pakai endpoint:

GET /products

POST /products

PUT /products/{id}

DELETE /products/{id}. 

UI List Produk Admin

Buat screens/admin/admin_products_screen.dart:

List/grid produk.

Tampilkan gambar, nama, harga, stok, kategori.

FAB “Tambah Produk”.

Tombol edit & delete di setiap card.

Form Tambah/Edit Produk

screens/admin/product_form_screen.dart:

TextField: nama, deskripsi, harga, stok, kategori.

Input URL gambar (sementara) atau picker kalau mau.

Validasi sederhana + tombol Simpan.

Integrasi Navigasi

Tambah menu “Produk” di dashboard admin bottom nav(buat widget baru) yang mengarah ke AdminProductsScreen.