import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacings.dart';
import '../../core/utils/result.dart';
import '../../core/widgets/order_list_item.dart';
import '../../repositories/waybill_repository.dart';
import '../../models/waybill.dart';
import 'waybill_detail_screen.dart';

class WaybillListScreen extends StatefulWidget {
  const WaybillListScreen({super.key});

  @override
  State<WaybillListScreen> createState() => _WaybillListScreenState();
}

class _WaybillListScreenState extends State<WaybillListScreen> {
  final _waybillRepository = WaybillRepository();
  List<Waybill> _waybills = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchWaybills();
  }

  Future<void> _fetchWaybills() async {
    setState(() {
      _isLoading = true;
    });

    final result = await _waybillRepository.getWaybills();

    if (!mounted) return;

    result
        .onSuccess((waybills) {
          setState(() {
            _waybills = waybills;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Surat Jalan', style: AppTextStyles.headlineMedium),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _isLoading ? null : _fetchWaybills,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading && _waybills.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchWaybills,
              child: _waybills.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacings.xl),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.description_outlined,
                              size: 64,
                              color: AppColors.textTertiary,
                            ),
                            const SizedBox(height: AppSpacings.md),
                            Text(
                              'Belum ada surat jalan',
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(AppSpacings.md),
                      itemCount: _waybills.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: AppSpacings.sm),
                      itemBuilder: (context, index) {
                        final waybill = _waybills[index];
                        return OrderListItem(
                          title: waybill.waybillNumber,
                          subtitle:
                              '${waybill.orderCode} • ${waybill.totalWeight} ton',
                          status: waybill.statusDisplay,
                          statusColor: _getStatusColor(waybill.status),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    WaybillDetailScreen(waybillId: waybill.id),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
    );
  }
}
