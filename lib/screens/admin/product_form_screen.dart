import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacings.dart';
import '../../core/utils/result.dart';
import '../../core/widgets/primary_button.dart';
import '../../repositories/product_repository.dart';
import '../../models/product.dart';

class ProductFormScreen extends StatefulWidget {
  final Product? product; // null for create, non-null for edit

  const ProductFormScreen({super.key, this.product});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _productRepository = ProductRepository();

  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;
  late TextEditingController _categoryController;
  late TextEditingController _imageUrlController;

  bool _isLoading = false;
  bool get _isEditMode => widget.product != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _descriptionController = TextEditingController(
      text: widget.product?.description ?? '',
    );
    _priceController = TextEditingController(
      text: widget.product?.price.toString() ?? '',
    );
    _stockController = TextEditingController(
      text: widget.product?.stock.toString() ?? '',
    );
    _categoryController = TextEditingController(
      text: widget.product?.category ?? '',
    );
    _imageUrlController = TextEditingController(
      text: widget.product?.primaryImage ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _categoryController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final productData = {
      'name': _nameController.text.trim(),
      'description': _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      'price': double.parse(_priceController.text.trim()),
      'stock': int.parse(_stockController.text.trim()),
      'category': _categoryController.text.trim().isEmpty
          ? null
          : _categoryController.text.trim(),
      'images': _imageUrlController.text.trim().isEmpty
          ? null
          : [_imageUrlController.text.trim()],
    };

    final result = _isEditMode
        ? await _productRepository.updateProduct(
            widget.product!.id,
            productData,
          )
        : await _productRepository.createProduct(productData);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    result
        .onSuccess((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _isEditMode
                    ? 'Produk berhasil diupdate'
                    : 'Produk berhasil ditambahkan',
              ),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.pop(context, true); // Return true to indicate success
        })
        .onFailure((failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(failure.message),
              backgroundColor: AppColors.error,
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          _isEditMode ? 'Edit Produk' : 'Tambah Produk',
          style: AppTextStyles.headlineMedium,
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacings.screenPadding),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nama Produk *',
                hintText: 'Masukkan nama produk',
                prefixIcon: Icon(Icons.inventory_2_outlined),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Nama produk harus diisi';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacings.md),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Deskripsi',
                hintText: 'Masukkan deskripsi produk',
                prefixIcon: Icon(Icons.description_outlined),
              ),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: AppSpacings.md),
            TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(
                labelText: 'Harga *',
                hintText: 'Masukkan harga produk',
                prefixIcon: Icon(Icons.attach_money),
                prefixText: 'Rp ',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Harga harus diisi';
                }
                final price = double.tryParse(value.trim());
                if (price == null || price <= 0) {
                  return 'Harga harus lebih dari 0';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacings.md),
            TextFormField(
              controller: _stockController,
              decoration: const InputDecoration(
                labelText: 'Stok *',
                hintText: 'Masukkan jumlah stok',
                prefixIcon: Icon(Icons.inventory_outlined),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Stok harus diisi';
                }
                final stock = int.tryParse(value.trim());
                if (stock == null || stock < 0) {
                  return 'Stok tidak boleh negatif';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacings.md),
            TextFormField(
              controller: _categoryController,
              decoration: const InputDecoration(
                labelText: 'Kategori',
                hintText: 'Masukkan kategori produk',
                prefixIcon: Icon(Icons.category_outlined),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: AppSpacings.md),
            TextFormField(
              controller: _imageUrlController,
              decoration: const InputDecoration(
                labelText: 'URL Gambar',
                hintText: 'Masukkan URL gambar produk',
                prefixIcon: Icon(Icons.image_outlined),
              ),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: AppSpacings.xl),
            PrimaryButton(
              text: _isEditMode ? 'Update Produk' : 'Tambah Produk',
              icon: _isEditMode ? Icons.check : Icons.add,
              onPressed: _isLoading ? null : _handleSubmit,
              isLoading: _isLoading,
            ),
            const SizedBox(height: AppSpacings.md),
            OutlinedButton(
              onPressed: _isLoading ? null : () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
          ],
        ),
      ),
    );
  }
}
