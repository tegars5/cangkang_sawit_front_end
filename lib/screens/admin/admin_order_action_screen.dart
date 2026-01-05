import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacings.dart';
import '../../core/theme/app_radius.dart';
import '../../core/utils/result.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/primary_button.dart';
import '../../repositories/order_repository.dart';
import '../../models/order.dart';
import 'assign_driver_dialog.dart';
import 'create_waybill_dialog.dart';
import 'admin_order_detail_screen.dart';
import 'admin_order_confirm_bottom_sheet.dart';

class AdminOrderActionScreen extends StatefulWidget {
  final int orderId;

  const AdminOrderActionScreen({super.key, required this.orderId});

  @override
  State<AdminOrderActionScreen> createState() => _AdminOrderActionScreenState();
}

class _AdminOrderActionScreenState extends State<AdminOrderActionScreen> {
  final _orderRepository = OrderRepository();
  Order? _order;
  bool _isLoading = false;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _fetchOrder();
  }

  Future<void> _fetchOrder() async {
    setState(() {
      _isLoading = true;
    });

    final result = await _orderRepository.getOrderById(widget.orderId);

    if (!mounted) return;

    result
        .onSuccess((order) {
          setState(() {
            _order = order;
            _isLoading = false;
          });
        })
        .onFailure((failure) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(failure.message),
              backgroundColor: AppColors.error,
            ),
          );
        });
  }

  Future<void> _handleApprove() async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AdminOrderConfirmBottomSheet(order: _order!),
    );

    if (result == true) {
      // Refresh order data
      await _fetchOrder();
      // Return to list with success
      if (mounted) {
        Navigator.pop(context, true);
      }
    }
  }

  Future<void> _handleCancel() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Pembatalan'),
        content: Text('Batalkan pesanan ${_order!.orderCode}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Tidak'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Ya, Batalkan'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isProcessing = true;
    });

    final result = await _orderRepository.cancelOrder(_order!.id);

    if (!mounted) return;

    setState(() {
      _isProcessing = false;
    });

    result
        .onSuccess((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pesanan berhasil dibatalkan'),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.pop(context, true); // Return true to refresh list
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

  Future<void> _handleAssignDriver() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AssignDriverDialog(order: _order!),
    );

    if (result == true) {
      _fetchOrder(); // Refresh to show assigned driver
    }
  }

  Future<void> _handleCreateWaybill() async {
    final waybillId = await showDialog<int>(
      context: context,
      builder: (context) => CreateWaybillDialog(order: _order!),
    );

    if (waybillId != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Surat jalan berhasil dibuat'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context, true); // Return to list
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange[700]!;
      case 'confirmed':
        return Colors.blue[700]!;
      case 'on_delivery':
        return Colors.purple[700]!;
      case 'completed':
        return Colors.green[700]!;
      case 'cancelled':
        return Colors.red[700]!;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Aksi Pesanan', style: AppTextStyles.headlineMedium),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: _isLoading && _order == null
          ? const Center(child: CircularProgressIndicator())
          : _order == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: AppColors.error),
                  const SizedBox(height: AppSpacings.md),
                  Text(
                    'Pesanan tidak ditemukan',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacings.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildOrderSummary(),
                  const SizedBox(height: AppSpacings.md),
                  _buildItemsSummary(),
                  const SizedBox(height: AppSpacings.md),
                  if (_order!.driverName != null) _buildDriverInfo(),
                  const SizedBox(height: AppSpacings.xl),
                  _buildActionButtons(),
                  const SizedBox(height: AppSpacings.md),
                  _buildDetailLink(),
                ],
              ),
            ),
    );
  }

  Widget _buildOrderSummary() {
    final statusColor = _getStatusColor(_order!.status);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _order!.orderCode,
                      style: AppTextStyles.titleLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _order!.createdAt ?? '',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacings.sm,
                  vertical: AppSpacings.xs,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: AppRadius.smallRadius,
                  border: Border.all(color: statusColor),
                ),
                child: Text(
                  _order!.statusDisplay,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          _buildInfoRow(
            icon: Icons.business_outlined,
            label: 'Mitra',
            value: _order!.mitraName ?? 'N/A',
          ),
          const SizedBox(height: AppSpacings.sm),
          _buildInfoRow(
            icon: Icons.location_on_outlined,
            label: 'Tujuan',
            value: _order!.destination,
          ),
          const SizedBox(height: AppSpacings.sm),
          _buildInfoRow(
            icon: Icons.payments_outlined,
            label: 'Total Harga',
            value: _order!.formattedTotalPrice,
            valueColor: AppColors.primary,
            valueBold: true,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
    bool valueBold = false,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: valueBold ? FontWeight.bold : FontWeight.w600,
                  color: valueColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildItemsSummary() {
    if (_order!.orderItems == null || _order!.orderItems!.isEmpty) {
      return AppCard(
        child: Text(
          'Detail produk tidak tersedia',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    final items = _order!.orderItems!;
    final displayItems = items.take(2).toList();
    final remainingCount = items.length - displayItems.length;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Ringkasan Produk', style: AppTextStyles.titleMedium),
          const SizedBox(height: AppSpacings.sm),
          ...displayItems.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${item.productName} (${item.quantity} ton)',
                      style: AppTextStyles.bodyMedium,
                    ),
                  ),
                  Text(
                    item.formattedSubtotal,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (remainingCount > 0)
            Text(
              '+$remainingCount produk lainnya',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDriverInfo() {
    return AppCard(
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            child: Icon(Icons.person, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: AppSpacings.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Driver Ditugaskan',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _order!.driverName!,
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.check_circle, color: AppColors.success, size: 20),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    final canApprove = _order!.status == 'pending';
    final canCancel = _order!.status == 'pending';
    final canAssignDriver =
        _order!.status == 'confirmed' && _order!.driverId == null;
    final canCreateWaybill =
        _order!.status == 'confirmed' && _order!.driverId != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (canApprove)
          PrimaryButton(
            text: 'Setujui Pesanan',
            icon: Icons.check_circle_outline,
            onPressed: _isProcessing ? null : _handleApprove,
          ),
        if (canCancel) ...[
          if (canApprove) const SizedBox(height: AppSpacings.sm),
          OutlinedButton.icon(
            onPressed: _isProcessing ? null : _handleCancel,
            icon: const Icon(Icons.cancel_outlined),
            label: const Text('Batalkan Pesanan'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: BorderSide(color: AppColors.error),
              padding: const EdgeInsets.symmetric(vertical: AppSpacings.md),
            ),
          ),
        ],
        if (canAssignDriver) ...[
          if (canApprove || canCancel) const SizedBox(height: AppSpacings.sm),
          PrimaryButton(
            text: 'Tugaskan Driver',
            icon: Icons.person_add_outlined,
            onPressed: _isProcessing ? null : _handleAssignDriver,
          ),
        ],
        if (canCreateWaybill) ...[
          if (canApprove || canCancel || canAssignDriver)
            const SizedBox(height: AppSpacings.sm),
          PrimaryButton(
            text: 'Buat Surat Jalan',
            icon: Icons.description_outlined,
            onPressed: _isProcessing ? null : _handleCreateWaybill,
          ),
        ],
      ],
    );
  }

  Widget _buildDetailLink() {
    return Center(
      child: TextButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AdminOrderDetailScreen(orderId: _order!.id),
            ),
          );
        },
        icon: const Icon(Icons.info_outline, size: 18),
        label: const Text('Lihat Detail Lengkap'),
        style: TextButton.styleFrom(foregroundColor: AppColors.primary),
      ),
    );
  }
}
