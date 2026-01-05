import 'package:cangkang_sawit_mobile/core/utils/result.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacings.dart';
import '../../core/theme/app_radius.dart';
import '../../core/widgets/primary_button.dart';
import '../../repositories/order_repository.dart';
import '../../models/order.dart';

class AdminOrderConfirmBottomSheet extends StatefulWidget {
  final Order order;

  const AdminOrderConfirmBottomSheet({super.key, required this.order});

  @override
  State<AdminOrderConfirmBottomSheet> createState() =>
      _AdminOrderConfirmBottomSheetState();
}

class _AdminOrderConfirmBottomSheetState
    extends State<AdminOrderConfirmBottomSheet> {
  final _orderRepository = OrderRepository();
  bool _isProcessing = false;

  Future<void> _handleApprove() async {
    setState(() {
      _isProcessing = true;
    });

    final result = await _orderRepository.approveOrder(widget.order.id);

    if (!mounted) return;

    setState(() {
      _isProcessing = false;
    });

    if (result is Success) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pesanan berhasil disetujui'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context, true);
    } else if (result is Failure) {
      if (!mounted) return;
      final failure = result as Failure;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(failure.message),
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
      height: MediaQuery.of(context).size.height * 0.7,
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
              padding: const EdgeInsets.all(AppSpacings.xl),
              child: Column(
                children: [
                  // Icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.local_shipping_outlined,
                      size: 40,
                      color: AppColors.success,
                    ),
                  ),

                  const SizedBox(height: AppSpacings.xl),

                  // Title
                  Text(
                    'Konfirmasi Pesanan Ini?',
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
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: AppRadius.mediumRadius,
                      border: Border.all(
                        color: AppColors.success.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.location_on,
                          color: AppColors.success,
                          size: 24,
                        ),
                        const SizedBox(width: AppSpacings.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Setelah Disetujui',
                                style: AppTextStyles.titleMedium.copyWith(
                                  color: AppColors.success,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Pesanan akan masuk ke tahap persiapan pengiriman. Anda dapat menugaskan driver dan membuat surat jalan untuk pesanan ini.',
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
                  text: 'Setujui Pesanan',
                  onPressed: _isProcessing ? null : _handleApprove,
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
                    color: AppColors.success,
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
