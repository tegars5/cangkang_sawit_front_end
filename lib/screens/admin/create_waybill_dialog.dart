import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacings.dart';
import '../../core/utils/result.dart';
import '../../core/widgets/primary_button.dart';
import '../../repositories/waybill_repository.dart';
import '../../models/order.dart';

class CreateWaybillDialog extends StatefulWidget {
  final Order order;

  const CreateWaybillDialog({super.key, required this.order});

  @override
  State<CreateWaybillDialog> createState() => _CreateWaybillDialogState();
}

class _CreateWaybillDialogState extends State<CreateWaybillDialog> {
  final _waybillRepository = WaybillRepository();
  final _notesController = TextEditingController();
  bool _isCreating = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _handleCreate() async {
    if (widget.order.driverId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Driver belum ditugaskan untuk pesanan ini'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isCreating = true;
    });

    final result = await _waybillRepository.createWaybill(widget.order.id);

    if (!mounted) return;

    setState(() {
      _isCreating = false;
    });

    result
        .onSuccess((waybill) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Surat jalan berhasil dibuat'),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.pop(context, waybill.id);
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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Buat Surat Jalan'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pesanan: ${widget.order.orderCode}',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacings.sm),
            Text(
              'Driver: ${widget.order.driverName ?? "Belum ditugaskan"}',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: AppSpacings.md),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Catatan (Opsional)',
                hintText: 'Masukkan catatan untuk surat jalan',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              enabled: !_isCreating,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isCreating ? null : () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        PrimaryButton(
          text: _isCreating ? 'Membuat...' : 'Buat',
          onPressed: _isCreating ? null : _handleCreate,
        ),
      ],
    );
  }
}
