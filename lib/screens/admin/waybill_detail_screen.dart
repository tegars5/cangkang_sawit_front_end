import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacings.dart';
import '../../core/theme/app_radius.dart';
import '../../core/utils/result.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/icon_container.dart';
import '../../repositories/waybill_repository.dart';
import '../../models/waybill.dart';

class WaybillDetailScreen extends StatefulWidget {
  final int waybillId;

  const WaybillDetailScreen({super.key, required this.waybillId});

  @override
  State<WaybillDetailScreen> createState() => _WaybillDetailScreenState();
}

class _WaybillDetailScreenState extends State<WaybillDetailScreen> {
  final _waybillRepository = WaybillRepository();
  Waybill? _waybill;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchWaybillDetail();
  }

  Future<void> _fetchWaybillDetail() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await _waybillRepository.getWaybillDetail(widget.waybillId);

    if (!mounted) return;

    result
        .onSuccess((waybill) {
          setState(() {
            _waybill = waybill;
            _isLoading = false;
          });
        })
        .onFailure((failure) {
          setState(() {
            _error = failure.message;
            _isLoading = false;
          });
        });
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange[700]!;
      case 'in_transit':
        return Colors.blue[700]!;
      case 'delivered':
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
      case 'in_transit':
        return Icons.local_shipping_outlined;
      case 'delivered':
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
        title: Text('Detail Surat Jalan', style: AppTextStyles.headlineMedium),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacings.xl),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: AppColors.error),
                    const SizedBox(height: AppSpacings.md),
                    Text(
                      _error!,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacings.md),
                    ElevatedButton.icon(
                      onPressed: _fetchWaybillDetail,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            )
          : _waybill == null
          ? const Center(child: Text('Data tidak ditemukan'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacings.screenPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildWaybillNumberCard(),
                  const SizedBox(height: AppSpacings.itemSpacing),
                  _buildStatusCard(),
                  const SizedBox(height: AppSpacings.itemSpacing),
                  _buildOrderInfoCard(),
                  const SizedBox(height: AppSpacings.itemSpacing),
                  _buildDriverInfoCard(),
                  const SizedBox(height: AppSpacings.itemSpacing),
                  _buildDestinationCard(),
                ],
              ),
            ),
    );
  }

  Widget _buildWaybillNumberCard() {
    return AppCard(
      child: Column(
        children: [
          const IconContainer(icon: Icons.description_rounded, iconSize: 48),
          const SizedBox(height: AppSpacings.md),
          Text(
            _waybill!.waybillNumber,
            style: AppTextStyles.displayMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacings.xs),
          Text(
            'Dibuat: ${_waybill!.formattedDate}',
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
    final statusColor = _getStatusColor(_waybill!.status);
    final statusIcon = _getStatusIcon(_waybill!.status);

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
                  'Status Surat Jalan',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacings.xs),
                Text(
                  _waybill!.statusDisplay,
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

  Widget _buildOrderInfoCard() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.shopping_bag_outlined,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: AppSpacings.sm),
              Text('Informasi Pesanan', style: AppTextStyles.titleLarge),
            ],
          ),
          const SizedBox(height: AppSpacings.md),
          _buildDetailRow(label: 'Kode Pesanan', value: _waybill!.orderCode),
          const SizedBox(height: AppSpacings.sm),
          _buildDetailRow(
            label: 'Berat Total',
            value: '${_waybill!.totalWeight} ton',
          ),
        ],
      ),
    );
  }

  Widget _buildDriverInfoCard() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person_outlined, color: AppColors.primary, size: 24),
              const SizedBox(width: AppSpacings.sm),
              Text('Informasi Driver', style: AppTextStyles.titleLarge),
            ],
          ),
          const SizedBox(height: AppSpacings.md),
          _buildDetailRow(
            label: 'Nama Driver',
            value: _waybill!.driverName ?? 'Belum ditugaskan',
          ),
          const SizedBox(height: AppSpacings.sm),
          _buildDetailRow(
            label: 'Plat Kendaraan',
            value: _waybill!.vehiclePlate ?? '-',
          ),
        ],
      ),
    );
  }

  Widget _buildDestinationCard() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: AppSpacings.sm),
              Text('Tujuan Pengiriman', style: AppTextStyles.titleLarge),
            ],
          ),
          const SizedBox(height: AppSpacings.md),
          _buildDetailRow(label: 'Alamat', value: _waybill!.destination),
        ],
      ),
    );
  }

  Widget _buildDetailRow({required String label, required String value}) {
    return Column(
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
    );
  }
}
