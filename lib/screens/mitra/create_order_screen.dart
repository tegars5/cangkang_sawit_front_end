import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacings.dart';
import '../../core/theme/app_radius.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/loading_section.dart';
import '../../core/widgets/error_view.dart';
import '../../services/api_client.dart';
import '../../models/product.dart';

class CreateOrderScreen extends StatefulWidget {
  const CreateOrderScreen({super.key});

  @override
  State<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen> {
  final _apiClient = ApiClient();
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final _destinationController = TextEditingController();
  final _weightController = TextEditingController();
  final _notesController = TextEditingController();

  // Location data
  double? _destinationLat;
  double? _destinationLng;
  String? _selectedAddress;

  // State
  List<Product> _products = [];
  bool _isLoadingProducts = false;
  bool _isCreatingOrder = false;
  String? _productsError;
  Product? _selectedProduct;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  @override
  void dispose() {
    _destinationController.dispose();
    _weightController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _fetchProducts() async {
    setState(() {
      _isLoadingProducts = true;
      _productsError = null;
    });

    try {
      final response = await _apiClient.getProducts();

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _products = data
              .map((json) => Product.fromJson(json))
              .where((product) => product.isAvailable)
              .toList();
        });
      } else {
        setState(() {
          _productsError = 'Gagal memuat daftar produk';
        });
      }
    } catch (e) {
      setState(() {
        _productsError = 'Terjadi kesalahan: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingProducts = false;
        });
      }
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.surface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  double? get _totalPrice {
    if (_selectedProduct == null || _weightController.text.isEmpty) {
      return null;
    }
    final weight = double.tryParse(_weightController.text);
    if (weight == null) return null;
    return _selectedProduct!.pricePerTon * weight;
  }

  String get _formattedTotalPrice {
    final price = _totalPrice;
    if (price == null) return 'Rp 0';
    return 'Rp ${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  Future<void> _handleCreateOrder() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedProduct == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih produk terlebih dahulu'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih tanggal pengiriman'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isCreatingOrder = true);

    try {
      final orderData = {
        'destination_address': _selectedAddress ?? _destinationController.text,
        'destination_lat': _destinationLat,
        'destination_lng': _destinationLng,
        'items': [
          {
            'product_id': _selectedProduct!.id,
            'quantity': int.parse(_weightController.text),
          },
        ],
        'notes': _notesController.text.isNotEmpty
            ? _notesController.text
            : null,
      };

      final response = await _apiClient.createOrder(orderData);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (!mounted) return;
        Navigator.of(context).pop(true); // Return true to indicate success
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pesanan berhasil dibuat'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        if (!mounted) return;
        final errorData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorData['message'] ?? 'Gagal membuat pesanan'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isCreatingOrder = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Buat Pesanan Baru', style: AppTextStyles.headlineMedium),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: _isLoadingProducts
          ? const LoadingSection(message: 'Memuat produk...')
          : _productsError != null
          ? Padding(
              padding: const EdgeInsets.all(AppSpacings.screenPadding),
              child: ErrorView(
                message: _productsError!,
                onRetry: _fetchProducts,
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacings.screenPadding),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildProductSelection(),
                    const SizedBox(height: AppSpacings.itemSpacing),
                    _buildDestinationField(),
                    const SizedBox(height: AppSpacings.itemSpacing),
                    _buildWeightField(),
                    const SizedBox(height: AppSpacings.itemSpacing),
                    _buildDatePicker(),
                    const SizedBox(height: AppSpacings.itemSpacing),
                    _buildNotesField(),
                    const SizedBox(height: AppSpacings.itemSpacing),
                    _buildTotalPriceCard(),
                    const SizedBox(height: AppSpacings.sectionSpacing),
                    PrimaryButton(
                      text: 'Buat Pesanan',
                      icon: Icons.shopping_cart,
                      onPressed: _isCreatingOrder ? null : _handleCreateOrder,
                      isLoading: _isCreatingOrder,
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildProductSelection() {
    return Container(
      padding: const EdgeInsets.all(AppSpacings.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.mediumRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pilih Produk',
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacings.sm),
          DropdownButtonFormField<Product>(
            initialValue: _selectedProduct,
            decoration: InputDecoration(
              hintText: 'Pilih produk',
              border: OutlineInputBorder(borderRadius: AppRadius.smallRadius),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacings.md,
                vertical: AppSpacings.sm,
              ),
            ),
            items: _products.map((product) {
              return DropdownMenuItem<Product>(
                value: product,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(product.name, style: AppTextStyles.bodyMedium),
                    Text(
                      product.formattedPrice,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (product) {
              setState(() {
                _selectedProduct = product;
              });
            },
            validator: (value) {
              if (value == null) {
                return 'Pilih produk terlebih dahulu';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDestinationField() {
    return Container(
      padding: const EdgeInsets.all(AppSpacings.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.mediumRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Lokasi Tujuan Pengiriman',
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 4),
              Text('*', style: TextStyle(color: AppColors.error, fontSize: 16)),
            ],
          ),
          const SizedBox(height: AppSpacings.sm),

          // Address Field
          AppTextField(
            controller: _destinationController,
            label: 'Alamat Lengkap',
            hintText: 'Contoh: Jl. Sudirman No. 123, Jakarta Pusat',
            prefixIcon: Icons.home_outlined,
            maxLines: 2,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Alamat tujuan harus diisi';
              }
              if (value.length < 10) {
                return 'Alamat tujuan terlalu pendek';
              }
              return null;
            },
          ),

          const SizedBox(height: AppSpacings.sm),

          // Coordinates Row
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Latitude',
                    hintText: 'Contoh: -6.2088',
                    prefixIcon: Icon(Icons.my_location, size: 20),
                    border: OutlineInputBorder(
                      borderRadius: AppRadius.smallRadius,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacings.sm,
                      vertical: AppSpacings.sm,
                    ),
                  ),
                  keyboardType: TextInputType.numberWithOptions(
                    decimal: true,
                    signed: true,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _destinationLat = double.tryParse(value);
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Wajib diisi';
                    }
                    final lat = double.tryParse(value);
                    if (lat == null) {
                      return 'Format salah';
                    }
                    if (lat < -90 || lat > 90) {
                      return 'Latitude: -90 s/d 90';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: AppSpacings.sm),
              Expanded(
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Longitude',
                    hintText: 'Contoh: 106.8456',
                    prefixIcon: Icon(Icons.my_location, size: 20),
                    border: OutlineInputBorder(
                      borderRadius: AppRadius.smallRadius,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacings.sm,
                      vertical: AppSpacings.sm,
                    ),
                  ),
                  keyboardType: TextInputType.numberWithOptions(
                    decimal: true,
                    signed: true,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _destinationLng = double.tryParse(value);
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Wajib diisi';
                    }
                    final lng = double.tryParse(value);
                    if (lng == null) {
                      return 'Format salah';
                    }
                    if (lng < -180 || lng > 180) {
                      return 'Longitude: -180 s/d 180';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacings.sm),

          // Helper Info
          Container(
            padding: const EdgeInsets.all(AppSpacings.sm),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: AppRadius.smallRadius,
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: AppColors.primary, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cara mendapatkan koordinat:',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '1. Buka Google Maps\n2. Klik lokasi tujuan\n3. Salin koordinat yang muncul',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Success indicator
          if (_destinationLat != null && _destinationLng != null) ...[
            const SizedBox(height: AppSpacings.sm),
            Container(
              padding: const EdgeInsets.all(AppSpacings.sm),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: AppRadius.smallRadius,
                border: Border.all(
                  color: AppColors.success.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: AppColors.success, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Koordinat valid! Jarak akan dihitung otomatis.',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildWeightField() {
    return AppTextField(
      controller: _weightController,
      label: 'Berat (ton)',
      hintText: 'Masukkan berat dalam ton',
      prefixIcon: Icons.scale_outlined,
      keyboardType: TextInputType.number,
      onChanged: (value) {
        setState(() {}); // Rebuild to update total price
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Berat harus diisi';
        }
        final weight = double.tryParse(value);
        if (weight == null || weight <= 0) {
          return 'Berat harus berupa angka positif';
        }
        return null;
      },
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: _selectDate,
      child: Container(
        padding: const EdgeInsets.all(AppSpacings.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.mediumRadius,
          border: Border.all(
            color: _selectedDate == null
                ? AppColors.textTertiary
                : AppColors.primary,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_outlined,
              color: _selectedDate == null
                  ? AppColors.textSecondary
                  : AppColors.primary,
            ),
            const SizedBox(width: AppSpacings.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tanggal Pengiriman',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _selectedDate == null
                        ? 'Pilih tanggal pengiriman'
                        : DateFormat(
                            'dd MMMM yyyy',
                            'id_ID',
                          ).format(_selectedDate!),
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: _selectedDate == null
                          ? AppColors.textSecondary
                          : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesField() {
    return AppTextField(
      controller: _notesController,
      label: 'Catatan (Opsional)',
      hintText: 'Tambahkan catatan jika diperlukan',
      prefixIcon: Icons.note_outlined,
      maxLines: 3,
    );
  }

  Widget _buildTotalPriceCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacings.md),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: AppRadius.mediumRadius,
        border: Border.all(color: AppColors.primary),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Total Harga',
            style: AppTextStyles.titleMedium.copyWith(color: AppColors.primary),
          ),
          Text(
            _formattedTotalPrice,
            style: AppTextStyles.headlineMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
