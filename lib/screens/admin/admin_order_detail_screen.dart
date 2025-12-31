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
import 'waybill_detail_screen.dart';
import '../mitra/order_tracking_screen.dart';

class AdminOrderDetailScreen extends StatefulWidget {
  final int orderId;

  const AdminOrderDetailScreen({super.key, required this.orderId});

  @override
  State<AdminOrderDetailScreen> createState() => _AdminOrderDetailScreenState();
}

class _AdminOrderDetailScreenState extends State<AdminOrderDetailScreen> {
  final _orderRepository = OrderRepository();
  Order? _order;
  bool _isLoading = false;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _fetchOrderDetail();
  }

  Future<void> _fetchOrderDetail() async {
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

  Future<void> _handleApproveOrder() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Persetujuan'),
        content: Text('Setujui pesanan ${_order!.orderCode}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Setujui'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isProcessing = true;
    });

    final result = await _orderRepository.approveOrder(_order!.id);

    if (!mounted) return;

    setState(() {
      _isProcessing = false;
    });

    result
        .onSuccess((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pesanan berhasil disetujui'),
              backgroundColor: AppColors.success,
            ),
          );
          _fetchOrderDetail(); // Refresh
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
      _fetchOrderDetail(); // Refresh to show assigned driver
    }
  }

  Future<void> _handleCreateWaybill() async {
    final result = await showDialog<int>(
      context: context,
      builder: (context) => CreateWaybillDialog(order: _order!),
    );

    if (result != null && mounted) {
      // Navigate to waybill detail
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WaybillDetailScreen(waybillId: result),
        ),
      );
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

  Color _getPaymentStatusColor(String? status) {
    switch (status) {
      case 'paid':
        return Colors.green[700]!;
      case 'pending':
      case 'unpaid':
        return Colors.orange[700]!;
      case 'failed':
      case 'expired':
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
        title: Text('Detail Pesanan', style: AppTextStyles.headlineMedium),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _isLoading ? null : _fetchOrderDetail,
            tooltip: 'Refresh',
          ),
        ],
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
          : RefreshIndicator(
              onRefresh: _fetchOrderDetail,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppSpacings.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildOrderHeader(),
                    const SizedBox(height: AppSpacings.md),
                    _buildStatusCards(),
                    const SizedBox(height: AppSpacings.md),
                    _buildOrderInfo(),
                    const SizedBox(height: AppSpacings.md),
                    if (_order!.orderItems != null &&
                        _order!.orderItems!.isNotEmpty) ...[
                      _buildProductItems(),
                      const SizedBox(height: AppSpacings.md),
                    ],
                    _buildPriceBreakdown(),
                    const SizedBox(height: AppSpacings.md),
                    if (_order!.driverName != null) _buildDriverInfo(),
                    const SizedBox(height: AppSpacings.xl),
                    _buildActionButtons(),
                    const SizedBox(height: AppSpacings.md),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildOrderHeader() {
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
                      'Kode Pesanan',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _order!.orderCode,
                      style: AppTextStyles.titleLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_order!.createdAt != null) ...[
            const SizedBox(height: AppSpacings.sm),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  _order!.createdAt!,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusCards() {
    final statusColor = _getStatusColor(_order!.status);
    final paymentColor = _getPaymentStatusColor(_order!.paymentStatus);

    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(AppSpacings.md),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: AppRadius.mediumRadius,
              border: Border.all(color: statusColor.withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.local_shipping_outlined,
                  color: statusColor,
                  size: 28,
                ),
                const SizedBox(height: 8),
                Text(
                  'Status Pesanan',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _order!.statusDisplay,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: AppSpacings.sm),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(AppSpacings.md),
            decoration: BoxDecoration(
              color: paymentColor.withValues(alpha: 0.1),
              borderRadius: AppRadius.mediumRadius,
              border: Border.all(color: paymentColor.withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                Icon(Icons.payment, color: paymentColor, size: 28),
                const SizedBox(height: 8),
                Text(
                  'Status Pembayaran',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _order!.paymentStatusDisplay,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: paymentColor,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderInfo() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Informasi Pesanan', style: AppTextStyles.titleLarge),
          const SizedBox(height: AppSpacings.md),
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
            icon: Icons.scale_outlined,
            label: 'Total Berat',
            value: '${_order!.totalWeight} ton',
          ),
          if (_order!.paymentMethod != null) ...[
            const SizedBox(height: AppSpacings.sm),
            _buildInfoRow(
              icon: Icons.credit_card_outlined,
              label: 'Metode Pembayaran',
              value: _order!.paymentMethod!.toUpperCase(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
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
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProductItems() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Produk', style: AppTextStyles.titleLarge),
          const SizedBox(height: AppSpacings.md),
          ...(_order!.orderItems!.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return Column(
              children: [
                if (index > 0) const Divider(height: 24),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.productName,
                            style: AppTextStyles.titleMedium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${item.quantity} ton × ${item.formattedPricePerUnit}',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      item.formattedSubtotal,
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            );
          })),
        ],
      ),
    );
  }

  Widget _buildPriceBreakdown() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Rincian Harga', style: AppTextStyles.titleLarge),
          const SizedBox(height: AppSpacings.md),
          Container(
            padding: const EdgeInsets.all(AppSpacings.md),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: AppRadius.smallRadius,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Pembayaran',
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _order!.formattedTotalPrice,
                  style: AppTextStyles.titleLarge.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
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
            radius: 24,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            child: Icon(Icons.person, color: AppColors.primary, size: 28),
          ),
          const SizedBox(width: AppSpacings.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Driver',
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
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    final canApprove = _order!.status == 'pending';
    final canAssignDriver =
        _order!.status == 'confirmed' && _order!.driverId == null;
    final canCreateWaybill =
        _order!.status == 'confirmed' && _order!.driverId != null;
    final canTrack = _order!.status == 'on_delivery';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (canApprove)
          PrimaryButton(
            text: 'Setujui Pesanan',
            icon: Icons.check_circle_outline,
            onPressed: _isProcessing ? null : _handleApproveOrder,
          ),
        if (canAssignDriver) ...[
          if (canApprove) const SizedBox(height: AppSpacings.sm),
          PrimaryButton(
            text: 'Tugaskan Driver',
            icon: Icons.person_add_outlined,
            onPressed: _isProcessing ? null : _handleAssignDriver,
          ),
        ],
        if (canCreateWaybill) ...[
          if (canApprove || canAssignDriver)
            const SizedBox(height: AppSpacings.sm),
          PrimaryButton(
            text: 'Buat Surat Jalan',
            icon: Icons.description_outlined,
            onPressed: _isProcessing ? null : _handleCreateWaybill,
          ),
        ],
        if (canTrack) ...[
          const SizedBox(height: AppSpacings.sm),
          PrimaryButton(
            text: 'Lacak Pengiriman',
            icon: Icons.map_outlined,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OrderTrackingScreen(order: _order!),
                ),
              );
            },
          ),
        ],
      ],
    );
  }
}
