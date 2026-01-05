import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacings.dart';
import '../../core/theme/app_radius.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/utils/result.dart';
import '../../repositories/waybill_repository.dart';
import '../../models/order.dart';
import 'waybill_detail_screen.dart';

class CreateWaybillBottomSheet extends StatefulWidget {
  final Order order;
  final ScrollController? scrollController;

  const CreateWaybillBottomSheet({
    super.key,
    required this.order,
    this.scrollController,
  });

  @override
  State<CreateWaybillBottomSheet> createState() =>
      _CreateWaybillBottomSheetState();
}

class _CreateWaybillBottomSheetState extends State<CreateWaybillBottomSheet> {
  final _waybillRepository = WaybillRepository();
  final _waybillNumberController = TextEditingController();
  bool _isProcessing = false;
  PlatformFile? _selectedFile;

  @override
  void dispose() {
    _waybillNumberController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;

        // Check file size (max 5MB)
        if (file.size > 5 * 1024 * 1024) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('File terlalu besar. Maksimal 5MB'),
                backgroundColor: AppColors.error,
              ),
            );
          }
          return;
        }

        setState(() {
          _selectedFile = file;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error memilih file: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _handleCreateWaybill() async {
    if (_waybillNumberController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nomor surat jalan harus diisi'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    final result = await _waybillRepository.createWaybill(widget.order.id);

    if (!mounted) return;

    setState(() {
      _isProcessing = false;
    });

    if (result is Success) {
      final waybillId = (result as Success).data.id;

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Surat jalan berhasil dibuat'),
          backgroundColor: AppColors.success,
        ),
      );

      // Close bottom sheet
      Navigator.pop(context, true);

      // Navigate to waybill detail
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WaybillDetailScreen(waybillId: waybillId),
        ),
      );
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

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
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
                      color: Colors.orange.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.description_outlined,
                      size: 40,
                      color: Colors.orange,
                    ),
                  ),

                  const SizedBox(height: AppSpacings.xl),

                  // Title
                  Text(
                    'Buat Surat Jalan?',
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
                        _buildDetailRow('Product', _getMainProductInfo()),
                        _buildDetailRow(
                          'Driver',
                          widget.order.driverName ?? 'N/A',
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
                      color: Colors.orange.withValues(alpha: 0.1),
                      borderRadius: AppRadius.mediumRadius,
                      border: Border.all(
                        color: Colors.orange.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.upload_file,
                          color: Colors.orange,
                          size: 24,
                        ),
                        const SizedBox(width: AppSpacings.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Upload Surat Jalan',
                                style: AppTextStyles.titleMedium.copyWith(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Upload file PDF surat jalan (maksimal 5MB). Driver akan dapat melihat surat jalan ini.',
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

                  // Waybill Number Input
                  TextField(
                    controller: _waybillNumberController,
                    decoration: InputDecoration(
                      labelText: 'Nomor Surat Jalan',
                      hintText: 'Contoh: SJ/2024/07/123',
                      prefixIcon: const Icon(Icons.tag),
                      border: OutlineInputBorder(
                        borderRadius: AppRadius.mediumRadius,
                      ),
                      filled: true,
                      fillColor: AppColors.surface,
                    ),
                  ),

                  const SizedBox(height: AppSpacings.md),

                  // File Picker
                  InkWell(
                    onTap: _pickFile,
                    borderRadius: AppRadius.mediumRadius,
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacings.md),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _selectedFile != null
                              ? AppColors.success
                              : AppColors.textTertiary.withValues(alpha: 0.3),
                          width: 2,
                          style: BorderStyle.solid,
                        ),
                        borderRadius: AppRadius.mediumRadius,
                        color: _selectedFile != null
                            ? AppColors.success.withValues(alpha: 0.05)
                            : AppColors.surface,
                      ),
                      child: _selectedFile == null
                          ? Column(
                              children: [
                                Icon(
                                  Icons.cloud_upload_outlined,
                                  size: 48,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(height: AppSpacings.sm),
                                Text(
                                  'Klik untuk upload PDF',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Maksimal 5MB',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.textTertiary,
                                  ),
                                ),
                              ],
                            )
                          : Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.success.withValues(
                                      alpha: 0.1,
                                    ),
                                    borderRadius: AppRadius.smallRadius,
                                  ),
                                  child: const Icon(
                                    Icons.picture_as_pdf,
                                    color: AppColors.success,
                                    size: 32,
                                  ),
                                ),
                                const SizedBox(width: AppSpacings.md),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _selectedFile!.name,
                                        style: AppTextStyles.titleMedium
                                            .copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _formatFileSize(_selectedFile!.size),
                                        style: AppTextStyles.bodySmall.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: () {
                                    setState(() {
                                      _selectedFile = null;
                                    });
                                  },
                                  color: AppColors.error,
                                ),
                              ],
                            ),
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
                  text: 'Buat Surat Jalan',
                  onPressed: _isProcessing ? null : _handleCreateWaybill,
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
                    color: Colors.orange,
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
