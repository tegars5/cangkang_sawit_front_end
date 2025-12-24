import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacings.dart';
import '../../core/theme/app_radius.dart';
import '../../core/utils/result.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/loading_section.dart';
import '../../core/widgets/error_view.dart';
import '../../repositories/driver_repository.dart';
import '../../models/order.dart';
import '../../models/driver.dart';

class AssignDriverDialog extends StatefulWidget {
  final Order order;

  const AssignDriverDialog({super.key, required this.order});

  @override
  State<AssignDriverDialog> createState() => _AssignDriverDialogState();
}

class _AssignDriverDialogState extends State<AssignDriverDialog> {
  final _driverRepository = DriverRepository();
  List<Driver> _drivers = [];
  bool _isLoading = false;
  bool _isAssigning = false;
  String? _error;
  int? _selectedDriverId;

  @override
  void initState() {
    super.initState();
    _fetchDrivers();
  }

  Future<void> _fetchDrivers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await _driverRepository.getDrivers();

    if (!mounted) return;

    result
        .onSuccess((drivers) {
          setState(() {
            _drivers = drivers;
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

  Future<void> _handleAssign() async {
    if (_selectedDriverId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih driver terlebih dahulu'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isAssigning = true);

    final result = await _driverRepository.assignDriver(
      widget.order.id,
      _selectedDriverId!,
    );

    if (!mounted) return;

    result
        .onSuccess((_) {
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Driver berhasil ditugaskan'),
              backgroundColor: AppColors.success,
            ),
          );
        })
        .onFailure((failure) {
          setState(() => _isAssigning = false);
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
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.largeRadius),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(AppSpacings.screenPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.person_add, color: AppColors.primary, size: 28),
                const SizedBox(width: AppSpacings.sm),
                Expanded(
                  child: Text(
                    'Assign Driver',
                    style: AppTextStyles.headlineMedium,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: AppSpacings.md),
            Text(
              'Order: ${widget.order.orderCode}',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacings.sectionSpacing),
            if (_isLoading)
              const LoadingSection(message: 'Memuat daftar driver...')
            else if (_error != null)
              ErrorView(message: _error!, onRetry: _fetchDrivers)
            else if (_drivers.isEmpty)
              Container(
                padding: const EdgeInsets.all(AppSpacings.xl),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: AppRadius.mediumRadius,
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 48,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: AppSpacings.md),
                    Text(
                      'Tidak ada driver tersedia',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                constraints: const BoxConstraints(maxHeight: 300),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _drivers.length,
                  itemBuilder: (context, index) {
                    final driver = _drivers[index];
                    return RadioListTile<int>(
                      value: driver.id,
                      groupValue: _selectedDriverId,
                      onChanged: driver.isAvailable
                          ? (value) {
                              setState(() {
                                _selectedDriverId = value;
                              });
                            }
                          : null,
                      title: Text(
                        driver.name,
                        style: AppTextStyles.titleMedium,
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (driver.vehicleType != null ||
                              driver.vehicleNumber != null)
                            Text(
                              driver.displayInfo,
                              style: AppTextStyles.bodySmall,
                            ),
                          if (!driver.isAvailable)
                            Text(
                              'Tidak tersedia',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.error,
                              ),
                            ),
                        ],
                      ),
                      activeColor: AppColors.primary,
                    );
                  },
                ),
              ),
            if (!_isLoading && _drivers.isNotEmpty) ...[
              const SizedBox(height: AppSpacings.sectionSpacing),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isAssigning
                          ? null
                          : () => Navigator.of(context).pop(),
                      child: const Text('Batal'),
                    ),
                  ),
                  const SizedBox(width: AppSpacings.sm),
                  Expanded(
                    flex: 2,
                    child: PrimaryButton(
                      text: 'Tugaskan Driver',
                      onPressed: _isAssigning ? null : _handleAssign,
                      isLoading: _isAssigning,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
