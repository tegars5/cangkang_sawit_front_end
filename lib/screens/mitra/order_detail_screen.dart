import 'package:cangkang_sawit_mobile/core/widgets/icon_container.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacings.dart';
import '../../core/theme/app_radius.dart';
import '../../core/utils/result.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/primary_button.dart';
import '../../repositories/order_repository.dart';
import '../../models/order.dart';
import '../../models/order_distance.dart';

class OrderDetailScreen extends StatefulWidget {
  final Order order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final _orderRepository = OrderRepository();
  OrderDistance? _orderDistance;
  bool _isLoadingDistance = false;
  String? _distanceError;

  @override
  void initState() {
    super.initState();
    _fetchOrderDistance();
  }

  Future<void> _fetchOrderDistance() async {
    setState(() {
      _isLoadingDistance = true;
      _distanceError = null;
    });

    final result = await _orderRepository.getOrderDistance(widget.order.id);

    if (!mounted) return;

    result
        .onSuccess((distance) {
          setState(() {
            _orderDistance = distance;
            _isLoadingDistance = false;
          });
        })
        .onFailure((failure) {
          setState(() {
            _distanceError = failure.message;
            _isLoadingDistance = false;
          });
        });
  }

  Future<void> _handlePayment() async {
    final result = await _orderRepository.payOrder(widget.order.id);

    if (!mounted) return;

    result
        .onSuccess((data) async {
          final paymentUrl = data['payment_url'] as String?;

          if (paymentUrl != null && paymentUrl.isNotEmpty) {
            final uri = Uri.parse(paymentUrl);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);

              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Silakan selesaikan pembayaran di browser'),
                  backgroundColor: AppColors.success,
                ),
              );
            } else {
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Gagal membuka halaman pembayaran'),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          } else {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('URL pembayaran tidak tersedia'),
                backgroundColor: AppColors.error,
              ),
            );
          }
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

  Future<void> _handleCancelOrder() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Pembatalan'),
        content: const Text('Apakah Anda yakin ingin membatalkan pesanan ini?'),
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

    final result = await _orderRepository.cancelOrder(widget.order.id);

    if (!mounted) return;

    result
        .onSuccess((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pesanan berhasil dibatalkan'),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.pop(context, true);
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange[700]!;
      case 'on_delivery':
        return Colors.blue[700]!;
      case 'completed':
        return Colors.green[700]!;
      case 'cancelled':
        return Colors.red[700]!;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.pending_outlined;
      case 'on_delivery':
        return Icons.local_shipping_outlined;
      case 'completed':
        return Icons.check_circle_outline;
      case 'cancelled':
        return Icons.cancel_outlined;
      default:
        return Icons.info_outline;
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacings.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildOrderCodeCard(),
            const SizedBox(height: AppSpacings.itemSpacing),
            _buildStatusCard(),
            const SizedBox(height: AppSpacings.itemSpacing),
            _buildOrderDetailsCard(),
            const SizedBox(height: AppSpacings.itemSpacing),
            _buildDistanceCard(),
            const SizedBox(height: AppSpacings.sectionSpacing),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCodeCard() {
    return AppCard(
      child: Column(
        children: [
          const IconContainer(icon: Icons.receipt_long_rounded, iconSize: 48),
          const SizedBox(height: AppSpacings.md),
          Text(
            widget.order.orderCode,
            style: AppTextStyles.displayMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacings.xs),
          if (widget.order.createdAt != null)
            Text(
              'Dibuat: ${widget.order.createdAt}',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    final statusColor = _getStatusColor(widget.order.status);
    final statusIcon = _getStatusIcon(widget.order.status);

    return Container(
      padding: const EdgeInsets.all(AppSpacings.md),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: AppRadius.mediumRadius,
        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: 32),
          const SizedBox(width: AppSpacings.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Status Pesanan',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacings.xs),
                Text(
                  widget.order.statusDisplay,
                  style: AppTextStyles.titleLarge.copyWith(
                    color: statusColor,
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

  Widget _buildOrderDetailsCard() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Detail Pesanan', style: AppTextStyles.titleLarge),
          const SizedBox(height: AppSpacings.md),
          _buildDetailRow(
            icon: Icons.location_on_outlined,
            label: 'Tujuan',
            value: widget.order.destination,
          ),
          const SizedBox(height: AppSpacings.sm),
          _buildDetailRow(
            icon: Icons.scale_outlined,
            label: 'Berat Total',
            value: '${widget.order.totalWeight} ton',
          ),
          if (widget.order.mitraName != null) ...[
            const SizedBox(height: AppSpacings.sm),
            _buildDetailRow(
              icon: Icons.business_outlined,
              label: 'Mitra',
              value: widget.order.mitraName!,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: AppSpacings.sm),
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
              Text(value, style: AppTextStyles.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDistanceCard() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.route_outlined, color: AppColors.primary),
              const SizedBox(width: AppSpacings.sm),
              Text('Informasi Jarak', style: AppTextStyles.titleLarge),
            ],
          ),
          const SizedBox(height: AppSpacings.md),
          if (_isLoadingDistance)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpacings.md),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_distanceError != null)
            Container(
              padding: const EdgeInsets.all(AppSpacings.md),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: AppRadius.smallRadius,
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: AppColors.error, size: 20),
                  const SizedBox(width: AppSpacings.sm),
                  Expanded(
                    child: Text(
                      _distanceError!,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else if (_orderDistance != null)
            Container(
              padding: const EdgeInsets.all(AppSpacings.md),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: AppRadius.smallRadius,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.warehouse_outlined,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: AppSpacings.sm),
                      Expanded(
                        child: Text(
                          _orderDistance!.origin,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacings.xs),
                  Row(
                    children: [
                      Icon(
                        Icons.arrow_downward,
                        color: AppColors.primary,
                        size: 16,
                      ),
                      const SizedBox(width: AppSpacings.sm),
                      Text(
                        _orderDistance!.formattedDistance,
                        style: AppTextStyles.titleMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: AppSpacings.sm),
                      Text(
                        _orderDistance!.formattedDuration,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacings.xs),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: AppSpacings.sm),
                      Expanded(
                        child: Text(
                          _orderDistance!.destination,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          else
            Text(
              'Informasi jarak tidak tersedia',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Payment button for pending orders that haven't been paid
        if (widget.order.status == 'pending' &&
            widget.order.paymentStatus != 'paid') ...[
          PrimaryButton(
            text: 'Bayar Sekarang',
            icon: Icons.payment,
            onPressed: _handlePayment,
          ),
          const SizedBox(height: AppSpacings.sm),
        ],
        // Tracking button for orders in delivery
        if (widget.order.status == 'on_delivery')
          PrimaryButton(
            text: 'Lacak Pengiriman',
            icon: Icons.map_outlined,
            onPressed: () {
              // TODO: Navigate to tracking screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Fitur tracking akan segera ditambahkan'),
                ),
              );
            },
          ),
        // Cancel button for pending orders
        if (widget.order.status == 'pending') ...[
          if (widget.order.paymentStatus == 'paid')
            const SizedBox(height: AppSpacings.sm),
          OutlinedButton.icon(
            onPressed: _handleCancelOrder,
            icon: const Icon(Icons.cancel_outlined),
            label: const Text('Batalkan Pesanan'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: BorderSide(color: AppColors.error),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ],
      ],
    );
  }
}
