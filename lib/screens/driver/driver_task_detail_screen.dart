import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacings.dart';
import '../../core/theme/app_radius.dart';
import '../../core/utils/result.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/icon_container.dart';
import '../../core/widgets/primary_button.dart';
import '../../repositories/driver_repository.dart';
import '../../models/delivery_order.dart';
import '../../models/driver_distance.dart';

class DriverTaskDetailScreen extends StatefulWidget {
  final DeliveryOrder task;

  const DriverTaskDetailScreen({super.key, required this.task});

  @override
  State<DriverTaskDetailScreen> createState() => _DriverTaskDetailScreenState();
}

class _DriverTaskDetailScreenState extends State<DriverTaskDetailScreen> {
  final _driverRepository = DriverRepository();
  DriverDistance? _driverDistance;
  bool _isLoadingDistance = false;
  String? _distanceError;
  bool _isUpdatingStatus = false;

  @override
  void initState() {
    super.initState();
    _fetchDriverDistance();
  }

  Future<void> _fetchDriverDistance() async {
    setState(() {
      _isLoadingDistance = true;
      _distanceError = null;
    });

    final result = await _driverRepository.getDriverDistance(widget.task.id);

    if (!mounted) return;

    result
        .onSuccess((distance) {
          setState(() {
            _driverDistance = distance;
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

  Future<void> _updateTaskStatus(String newStatus) async {
    setState(() => _isUpdatingStatus = true);

    try {
      final result = await _driverRepository.updateTaskStatus(
        widget.task.id,
        newStatus,
      );

      if (!mounted) return;

      result
          .onSuccess((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Status berhasil diperbarui'),
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
    } finally {
      if (mounted) {
        setState(() => _isUpdatingStatus = false);
      }
    }
  }

  Future<void> _sendLocation() async {
    // Check location permission
    var status = await Permission.location.status;
    if (status.isDenied) {
      status = await Permission.location.request();
    }

    if (status.isPermanentlyDenied) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Izin lokasi ditolak permanen. Silakan aktifkan di pengaturan.',
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (!status.isGranted) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Izin lokasi diperlukan untuk mengirim lokasi'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Get current position
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final result = await _driverRepository.sendLocation(
        widget.task.id,
        position.latitude,
        position.longitude,
      );

      if (!mounted) return;

      result
          .onSuccess((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Lokasi berhasil dikirim'),
                backgroundColor: AppColors.success,
              ),
            );
          })
          .onFailure((failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(failure.message),
                backgroundColor: AppColors.error,
              ),
            );
          });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mendapatkan lokasi: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showUpdateStatusDialog() {
    final statuses = [
      {'value': 'on_the_way', 'label': 'Dalam Perjalanan'},
      {'value': 'arrived', 'label': 'Tiba di Tujuan'},
      {'value': 'completed', 'label': 'Selesai'},
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Pilih status baru:', style: AppTextStyles.bodyMedium),
            const SizedBox(height: AppSpacings.md),
            ...statuses.map(
              (status) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacings.sm),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _updateTaskStatus(status['value']!);
                  },
                  child: Text(status['label']!),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'assigned':
        return Colors.orange[700]!;
      case 'on_the_way':
        return Colors.blue[700]!;
      case 'arrived':
        return Colors.purple[700]!;
      case 'completed':
        return Colors.green[700]!;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'assigned':
        return Icons.assignment_outlined;
      case 'on_the_way':
        return Icons.local_shipping_outlined;
      case 'arrived':
        return Icons.location_on_outlined;
      case 'completed':
        return Icons.check_circle_outline;
      default:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Detail Tugas', style: AppTextStyles.headlineMedium),
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
            _buildTaskDetailsCard(),
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
          const IconContainer(icon: Icons.local_shipping_rounded, iconSize: 48),
          const SizedBox(height: AppSpacings.md),
          Text(
            widget.task.orderCode,
            style: AppTextStyles.displayMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacings.xs),
          Text(
            'Tugas Pengiriman',
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
    final statusColor = _getStatusColor(widget.task.status);
    final statusIcon = _getStatusIcon(widget.task.status);

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
                  'Status Pengiriman',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacings.xs),
                Text(
                  widget.task.statusDisplay,
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

  Widget _buildTaskDetailsCard() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Detail Tugas', style: AppTextStyles.titleLarge),
          const SizedBox(height: AppSpacings.md),
          _buildDetailRow(
            icon: Icons.location_on_outlined,
            label: 'Tujuan Pengiriman',
            value: widget.task.destination,
          ),
          const SizedBox(height: AppSpacings.sm),
          _buildDetailRow(
            icon: Icons.scale_outlined,
            label: 'Berat Total',
            value: '${widget.task.totalWeight} ton',
          ),
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
          else if (_driverDistance != null)
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
                        Icons.my_location,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: AppSpacings.sm),
                      Expanded(
                        child: Text(
                          'Posisi Anda',
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
                        _driverDistance!.formattedDistance,
                        style: AppTextStyles.titleMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: AppSpacings.sm),
                      Text(
                        _driverDistance!.formattedDuration,
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
                          _driverDistance!.destination,
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
        PrimaryButton(
          text: 'Update Status',
          icon: Icons.update_outlined,
          onPressed: _isUpdatingStatus ? null : _showUpdateStatusDialog,
          isLoading: _isUpdatingStatus,
        ),
        const SizedBox(height: AppSpacings.sm),
        OutlinedButton.icon(
          onPressed: _sendLocation,
          icon: const Icon(Icons.location_on),
          label: const Text('Kirim Lokasi Saat Ini'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ],
    );
  }
}
