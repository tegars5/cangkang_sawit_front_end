import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacings.dart';
import '../../core/utils/result.dart';
import '../../core/widgets/stat_card.dart';
import '../../core/widgets/chart_placeholder.dart';
import '../../core/widgets/order_list_item.dart';
import '../../repositories/order_repository.dart';
import '../../repositories/auth_repository.dart';
import '../../repositories/waybill_repository.dart';
import '../../models/order.dart';
import 'assign_driver_dialog.dart';
import 'waybill_detail_screen.dart';
import 'admin_order_confirm_bottom_sheet.dart';
import 'assign_driver_bottom_sheet.dart';
import 'create_waybill_bottom_sheet.dart';
import 'admin_order_detail_screen.dart';

class AdminOrdersScreen extends StatefulWidget {
  final String? initialStatus;

  const AdminOrdersScreen({super.key, this.initialStatus});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  final _orderRepository = OrderRepository();
  final _authRepository = AuthRepository();
  final _waybillRepository = WaybillRepository();
  List<Order> _orders = [];
  bool _isLoading = false;
  int _totalOrders = 0;
  int _pending = 0;
  int _onDelivery = 0;
  int _completed = 0;
  String? _statusFilter;

  @override
  void initState() {
    super.initState();
    _statusFilter = widget.initialStatus;
    _fetchDashboardSummary();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    setState(() {
      _isLoading = true;
    });

    final result = await _orderRepository.getOrders();

    if (!mounted) return;

    result
        .onSuccess((orders) {
          setState(() {
            _orders = orders;
            _isLoading = false;
            // Calculate pending from orders list
            _pending = orders.where((o) => o.status == 'pending').length;
          });
        })
        .onFailure((failure) {
          setState(() {
            _isLoading = false;
          });
        });
  }

  void _setStatusFilter(String? status) {
    setState(() {
      _statusFilter = status;
    });
  }

  List<Order> get _filteredOrders {
    if (_statusFilter == null) return _orders;
    return _orders.where((order) => order.status == _statusFilter).toList();
  }

  Future<void> _fetchDashboardSummary() async {
    final result = await _orderRepository.getAdminDashboardSummary();

    if (!mounted) return;

    result
        .onSuccess((summary) {
          setState(() {
            _totalOrders = summary['total_orders'] ?? 0;
            _onDelivery = summary['in_delivery'] ?? 0;
            _completed = summary['completed'] ?? 0;
          });
        })
        .onFailure((failure) {
          // Silently fail, keep existing values
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

  void _showOrderActions(Order order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Aksi untuk ${order.orderCode}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Pilih aksi yang ingin dilakukan:',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: AppSpacings.md),
            // Approve button - only for pending orders
            if (order.status == 'pending') ...[
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _approveOrder(order);
                },
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Setujui Pesanan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: AppSpacings.sm),
            ],
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _showAssignDriverDialog(order);
              },
              icon: const Icon(Icons.person_add),
              label: const Text('Assign Driver'),
            ),
            const SizedBox(height: AppSpacings.sm),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _createWaybill(order);
              },
              icon: const Icon(Icons.description),
              label: const Text('Buat Waybill'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void _showAssignDriverDialog(Order order) async {
    final shouldRefresh = await showDialog<bool>(
      context: context,
      builder: (context) => AssignDriverDialog(order: order),
    );

    if (shouldRefresh == true) {
      _fetchOrders(); // Refresh orders after successful assignment
      _fetchDashboardSummary(); // Refresh dashboard stats
    }
  }

  Future<void> _approveOrder(Order order) async {
    final result = await _orderRepository.approveOrder(order.id);

    if (!mounted) return;

    result
        .onSuccess((updatedOrder) async {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pesanan berhasil disetujui'),
              backgroundColor: AppColors.success,
            ),
          );

          // Refresh orders list and dashboard stats
          await _fetchOrders();
          await _fetchDashboardSummary();
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

  Future<void> _createWaybill(Order order) async {
    final result = await _waybillRepository.createWaybill(order.id);

    if (!mounted) return;

    result
        .onSuccess((waybill) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Surat jalan berhasil dibuat'),
              backgroundColor: AppColors.success,
            ),
          );

          // Navigate to waybill detail
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WaybillDetailScreen(waybillId: waybill.id),
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
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange[700]!;
      case 'confirmed':
        return Colors.blue[700]!;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Dashboard Admin', style: AppTextStyles.headlineMedium),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _isLoading ? null : _fetchOrders,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: _handleLogout,
            tooltip: 'Keluar',
          ),
        ],
      ),
      body: _isLoading && _orders.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                await _fetchDashboardSummary();
                await _fetchOrders();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppSpacings.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Subtitle
                    Text(
                      'Ringkasan operasional Cangkang Sawit',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacings.lg),

                    // KPI Cards Grid (2x2)
                    _buildKPIGrid(),
                    const SizedBox(height: AppSpacings.lg),

                    // Chart Placeholder
                    const ChartPlaceholder(),
                    const SizedBox(height: AppSpacings.lg),

                    // Recent Orders Section
                    _buildRecentOrdersSection(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildKPIGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: AppSpacings.md,
      mainAxisSpacing: AppSpacings.md,
      childAspectRatio: 1.1,
      children: [
        StatCard(
          icon: Icons.shopping_bag_rounded,
          iconColor: Colors.blue[700]!,
          title: 'Total Pesanan',
          value: '$_totalOrders',
          subtitle: 'Semua pesanan',
          onTap: () => _setStatusFilter(null),
        ),
        StatCard(
          icon: Icons.pending_actions_rounded,
          iconColor: Colors.orange[700]!,
          title: 'Pending',
          value: '$_pending',
          subtitle: 'Menunggu',
          onTap: () => _setStatusFilter('pending'),
        ),
        StatCard(
          icon: Icons.local_shipping_rounded,
          iconColor: Colors.purple[700]!,
          title: 'Dalam Pengiriman',
          value: '$_onDelivery',
          subtitle: 'Sedang proses',
          onTap: () => _setStatusFilter('on_delivery'),
        ),
        StatCard(
          icon: Icons.check_circle_rounded,
          iconColor: Colors.green[700]!,
          title: 'Selesai',
          value: '$_completed',
          subtitle: 'Berhasil dikirim',
          onTap: () => _setStatusFilter('completed'),
        ),
      ],
    );
  }

  Widget _buildRecentOrdersSection() {
    // Use filtered orders or all orders
    final displayOrders = _filteredOrders.take(10).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _statusFilter == null
                      ? 'Pesanan Terbaru'
                      : 'Pesanan Terfilter',
                  style: AppTextStyles.titleLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (_statusFilter != null) ...[
                  const SizedBox(height: 4),
                  TextButton.icon(
                    onPressed: () => _setStatusFilter(null),
                    icon: const Icon(Icons.clear, size: 16),
                    label: const Text('Hapus Filter'),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ],
            ),
            if (displayOrders.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacings.sm,
                  vertical: AppSpacings.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${displayOrders.length}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacings.md),

        if (displayOrders.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacings.xl),
              child: Column(
                children: [
                  Icon(
                    Icons.inbox_outlined,
                    size: 64,
                    color: AppColors.textTertiary,
                  ),
                  const SizedBox(height: AppSpacings.md),
                  Text(
                    _statusFilter == null
                        ? 'Belum ada pesanan'
                        : 'Tidak ada pesanan dengan filter ini',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: displayOrders.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacings.sm),
            itemBuilder: (context, index) {
              final order = displayOrders[index];
              return OrderListItem(
                title: order.orderCode,
                subtitle:
                    '${order.mitraName ?? "Mitra"} • ${order.totalWeight} ton',
                status: order.statusDisplay,
                statusColor: _getStatusColor(order.status),
                onTap: () async {
                  bool? result;

                  // Show appropriate bottom sheet based on order status
                  if (order.status == 'pending') {
                    // Pending orders → Approve bottom sheet
                    result = await showModalBottomSheet<bool>(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(24),
                        ),
                      ),
                      builder: (context) => DraggableScrollableSheet(
                        initialChildSize: 0.7,
                        minChildSize: 0.5,
                        maxChildSize: 0.9,
                        expand: false,
                        builder: (context, scrollController) =>
                            AdminOrderConfirmBottomSheet(
                              order: order,
                              scrollController: scrollController,
                            ),
                      ),
                    );
                  } else if (order.status == 'confirmed' &&
                      order.driverId == null) {
                    // Confirmed without driver → Assign driver bottom sheet
                    result = await showModalBottomSheet<bool>(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(24),
                        ),
                      ),
                      builder: (context) => DraggableScrollableSheet(
                        initialChildSize: 0.7,
                        minChildSize: 0.5,
                        maxChildSize: 0.9,
                        expand: false,
                        builder: (context, scrollController) =>
                            AssignDriverBottomSheet(
                              order: order,
                              scrollController: scrollController,
                            ),
                      ),
                    );
                  } else if (order.status == 'confirmed' &&
                      order.driverId != null) {
                    // Confirmed with driver → Create waybill bottom sheet
                    result = await showModalBottomSheet<bool>(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(24),
                        ),
                      ),
                      builder: (context) => DraggableScrollableSheet(
                        initialChildSize: 0.7,
                        minChildSize: 0.5,
                        maxChildSize: 0.9,
                        expand: false,
                        builder: (context, scrollController) =>
                            CreateWaybillBottomSheet(
                              order: order,
                              scrollController: scrollController,
                            ),
                      ),
                    );
                  } else {
                    // Other statuses → Navigate to detail screen
                    result = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AdminOrderDetailScreen(orderId: order.id),
                      ),
                    );
                  }

                  // Refresh if action was successful
                  if (result == true) {
                    _fetchOrders();
                    _fetchDashboardSummary();
                  }
                },
              );
            },
          ),
      ],
    );
  }
}
