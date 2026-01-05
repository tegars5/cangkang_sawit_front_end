import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacings.dart';
import '../../core/theme/app_radius.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/utils/result.dart';
import '../../repositories/order_repository.dart';
import '../../models/order.dart';

class AssignDriverBottomSheet extends StatefulWidget {
  final Order order;
  final ScrollController? scrollController;

  const AssignDriverBottomSheet({
    super.key,
    required this.order,
    this.scrollController,
  });

  @override
  State<AssignDriverBottomSheet> createState() =>
      _AssignDriverBottomSheetState();
}

class _AssignDriverBottomSheetState extends State<AssignDriverBottomSheet> {
  final _orderRepository = OrderRepository();
  bool _isLoading = true;
  bool _isProcessing = false;
  List<Map<String, dynamic>> _availableDrivers = [];
  int? _selectedDriverId;

  @override
  void initState() {
    super.initState();
    _fetchAvailableDrivers();
  }

  Future<void> _fetchAvailableDrivers() async {
    setState(() {
      _isLoading = true;
    });

    final result = await _orderRepository.getAvailableDrivers(widget.order.id);

    if (!mounted) return;

    if (result is Success) {
      setState(() {
        _availableDrivers = (result as Success).data;
        _isLoading = false;
      });
    } else if (result is Failure) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text((result as Failure).message),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _handleAssignDriver() async {
    if (_selectedDriverId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih driver terlebih dahulu'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    final result = await _orderRepository.assignDriver(
      widget.order.id,
      _selectedDriverId!,
    );

    if (!mounted) return;

    setState(() {
      _isProcessing = false;
    });

    if (result is Success) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Driver berhasil ditugaskan'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context, true);
    } else if (result is Failure) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text((result as Failure).message),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  String _getMainProductInfo() {
    if (widget.order.orderItems != null &&
        widget.order.orderItems!.isNotEmpty) {
      final firstItem = widget.order.orderItems!.first;
      return '${firstItem.productName} - ${firstItem.quantity} Ton';
    }
    return '${widget.order.totalWeight} Ton';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textTertiary.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              controller: widget.scrollController,
              padding: const EdgeInsets.all(AppSpacings.xl),
              child: Column(
                children: [
                  // Icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person_add_outlined,
                      size: 40,
                      color: Colors.blue,
                    ),
                  ),

                  const SizedBox(height: AppSpacings.xl),

                  // Title
                  Text(
                    'Tugaskan Driver?',
                    style: AppTextStyles.headlineMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: AppSpacings.xl),

                  // Order Details Table
                  Container(
                    padding: const EdgeInsets.all(AppSpacings.md),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.textTertiary.withValues(alpha: 0.2),
                      ),
                      borderRadius: AppRadius.mediumRadius,
                    ),
                    child: Column(
                      children: [
                        _buildDetailRow(
                          'Order ID',
                          widget.order.orderCode,
                          isFirst: true,
                        ),
                        _buildDetailRow(
                          'Destination',
                          widget.order.destination,
                        ),
                        _buildDetailRow(
                          'Product',
                          _getMainProductInfo(),
                          isLast: true,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacings.xl),

                  // Info Card
                  Container(
                    padding: const EdgeInsets.all(AppSpacings.md),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: AppRadius.mediumRadius,
                      border: Border.all(
                        color: Colors.blue.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.notifications_active,
                          color: Colors.blue,
                          size: 24,
                        ),
                        const SizedBox(width: AppSpacings.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Notifikasi Driver',
                                style: AppTextStyles.titleMedium.copyWith(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Driver yang dipilih akan mendapat notifikasi task baru dan dapat memulai pengiriman.',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textPrimary,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacings.xl),

                  // Driver List
                  if (_isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(AppSpacings.xl),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (_availableDrivers.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(AppSpacings.xl),
                      child: Column(
                        children: [
                          Icon(
                            Icons.person_off_outlined,
                            size: 48,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(height: AppSpacings.md),
                          Text(
                            'Tidak ada driver tersedia',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pilih Driver',
                          style: AppTextStyles.titleMedium.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppSpacings.sm),
                        ..._availableDrivers.map((driver) {
                          final driverId = driver['id'] as int;
                          final driverName = driver['name'] as String;
                          final isAvailable = driver['status'] == 'available';

                          return Container(
                            margin: const EdgeInsets.only(
                              bottom: AppSpacings.sm,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: _selectedDriverId == driverId
                                    ? AppColors.primary
                                    : AppColors.textTertiary.withValues(
                                        alpha: 0.2,
                                      ),
                                width: _selectedDriverId == driverId ? 2 : 1,
                              ),
                              borderRadius: AppRadius.mediumRadius,
                            ),
                            child: RadioListTile<int>(
                              value: driverId,
                              groupValue: _selectedDriverId,
                              onChanged: isAvailable
                                  ? (value) {
                                      setState(() {
                                        _selectedDriverId = value;
                                      });
                                    }
                                  : null,
                              title: Text(
                                driverName,
                                style: AppTextStyles.titleMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Row(
                                children: [
                                  Icon(
                                    isAvailable
                                        ? Icons.check_circle
                                        : Icons.local_shipping,
                                    size: 14,
                                    color: isAvailable
                                        ? AppColors.success
                                        : Colors.orange,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    isAvailable ? 'Available' : 'On Delivery',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: isAvailable
                                          ? AppColors.success
                                          : Colors.orange,
                                    ),
                                  ),
                                ],
                              ),
                              activeColor: AppColors.primary,
                            ),
                          );
                        }),
                      ],
                    ),

                  const SizedBox(height: AppSpacings.xl * 2),
                ],
              ),
            ),
          ),

          // Action Buttons
          Container(
            padding: const EdgeInsets.all(AppSpacings.xl),
            decoration: BoxDecoration(
              color: AppColors.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PrimaryButton(
                  text: _selectedDriverId != null
                      ? 'Tugaskan ke ${_availableDrivers.firstWhere((d) => d['id'] == _selectedDriverId)['name']}'
                      : 'Pilih Driver',
                  onPressed: _isProcessing || _selectedDriverId == null
                      ? null
                      : _handleAssignDriver,
                  isLoading: _isProcessing,
                ),
                const SizedBox(height: AppSpacings.sm),
                TextButton(
                  onPressed: _isProcessing
                      ? null
                      : () => Navigator.pop(context, false),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacings.md,
                    ),
                  ),
                  child: Text(
                    'Batal',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Column(
      children: [
        if (!isFirst)
          Divider(
            height: 1,
            color: AppColors.textTertiary.withValues(alpha: 0.2),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacings.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 100,
                child: Text(
                  label,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.blue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacings.md),
              Expanded(
                child: Text(
                  value,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
