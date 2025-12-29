import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacings.dart';
import '../../core/utils/result.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/icon_container.dart';
import '../../core/widgets/order_list_item.dart';
import '../../repositories/driver_repository.dart';
import '../../repositories/auth_repository.dart';
import '../../models/delivery_order.dart';
import 'driver_task_detail_screen.dart';

class DriverTasksScreen extends StatefulWidget {
  const DriverTasksScreen({super.key});

  @override
  State<DriverTasksScreen> createState() => _DriverTasksScreenState();
}

class _DriverTasksScreenState extends State<DriverTasksScreen> {
  final _driverRepository = DriverRepository();
  final _authRepository = AuthRepository();
  List<DeliveryOrder> _tasks = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  Future<void> _fetchTasks() async {
    setState(() {
      _isLoading = true;
    });

    final result = await _driverRepository.getDriverTasks();

    if (!mounted) return;

    result
        .onSuccess((tasks) {
          setState(() {
            _tasks = tasks;
            _isLoading = false;
          });
        })
        .onFailure((failure) {
          setState(() {
            _isLoading = false;
          });
        });
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _authRepository.logout();
      if (!mounted) return;
      context.go('/login');
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Tugas Driver', style: AppTextStyles.headlineMedium),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _isLoading ? null : _fetchTasks,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: _handleLogout,
            tooltip: 'Keluar',
          ),
        ],
      ),
      body: _isLoading && _tasks.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchTasks,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppSpacings.screenPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDriverInfoCard(),
                    const SizedBox(height: AppSpacings.xl),
                    _buildTasksSection(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildDriverInfoCard() {
    return AppCard(
      child: Row(
        children: [
          const IconContainer(
            icon: Icons.local_shipping_rounded,
            iconSize: 48,
            size: 88,
          ),
          const SizedBox(width: AppSpacings.itemSpacing),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Driver Dashboard', style: AppTextStyles.titleLarge),
                const SizedBox(height: AppSpacings.sm),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacings.sm,
                        vertical: AppSpacings.xs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Status: Aktif',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacings.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacings.sm,
                        vertical: AppSpacings.xs,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${_tasks.length} Tugas',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.orange[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTasksSection() {
    if (_tasks.isEmpty && !_isLoading) {
      return Container(
        padding: const EdgeInsets.all(AppSpacings.xl),
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(
              Icons.assignment_outlined,
              size: 64,
              color: AppColors.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: AppSpacings.md),
            Text(
              'Belum ada tugas',
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacings.xs),
            Text(
              'Tugas pengiriman akan muncul di sini',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Tugas Pengiriman', style: AppTextStyles.headlineMedium),
            Text('${_tasks.length} tugas', style: AppTextStyles.bodyMedium),
          ],
        ),
        const SizedBox(height: AppSpacings.md),
        ..._tasks.map(
          (task) => OrderListItem(
            title: task.orderCode,
            subtitle: '${task.destination} • ${task.totalWeight} ton',
            status: task.statusDisplay,
            statusColor: _getStatusColor(task.status),
            onTap: () async {
              final shouldRefresh = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (context) => DriverTaskDetailScreen(task: task),
                ),
              );
              if (shouldRefresh == true) {
                _fetchTasks();
              }
            },
          ),
        ),
      ],
    );
  }
}
