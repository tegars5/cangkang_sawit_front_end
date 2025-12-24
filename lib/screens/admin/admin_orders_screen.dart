import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacings.dart';
import '../../core/utils/result.dart';
import '../../core/widgets/stat_card.dart';
import '../../core/widgets/order_list_item.dart';
import '../../repositories/order_repository.dart';
import '../../repositories/auth_repository.dart';
import '../../models/order.dart';
import 'assign_driver_dialog.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  final _orderRepository = OrderRepository();
  final _authRepository = AuthRepository();
  List<Order> _orders = [];
  bool _isLoading = false;
  int _totalOrders = 0;
  int _onDelivery = 0;
  int _completed = 0;

  @override
  void initState() {
    super.initState();
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
            _calculateStats();
          });
        })
        .onFailure((failure) {
          setState(() {
            _isLoading = false;
          });
        });
  }

  void _calculateStats() {
    _totalOrders = _orders.length;
    _onDelivery = _orders.where((o) => o.status == 'on_delivery').length;
    _completed = _orders.where((o) => o.status == 'completed').length;
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
                // TODO: Implement waybill creation
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Fitur waybill akan segera ditambahkan'),
                  ),
                );
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
    }
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
              onRefresh: _fetchOrders,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppSpacings.screenPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatisticsSection(),
                    const SizedBox(height: AppSpacings.xl),
                    _buildRecentOrdersSection(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatisticsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Ringkasan', style: AppTextStyles.headlineMedium),
        const SizedBox(height: AppSpacings.md),
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 600) {
              return Column(
                children: [
                  StatCard(
                    icon: Icons.shopping_bag_rounded,
                    title: 'Total Pesanan',
                    value: '$_totalOrders',
                    subtitle: 'Semua pesanan',
                  ),
                  const SizedBox(height: AppSpacings.sm),
                  StatCard(
                    icon: Icons.local_shipping_rounded,
                    title: 'Dalam Pengiriman',
                    value: '$_onDelivery',
                    subtitle: 'Sedang proses',
                    iconColor: Colors.orange[700],
                    iconBackgroundColor: Colors.orange[50],
                  ),
                  const SizedBox(height: AppSpacings.sm),
                  StatCard(
                    icon: Icons.check_circle_rounded,
                    title: 'Selesai',
                    value: '$_completed',
                    subtitle: 'Berhasil dikirim',
                    iconColor: Colors.green[700],
                    iconBackgroundColor: Colors.green[50],
                  ),
                ],
              );
            } else {
              return Row(
                children: [
                  Expanded(
                    child: StatCard(
                      icon: Icons.shopping_bag_rounded,
                      title: 'Total Pesanan',
                      value: '$_totalOrders',
                      subtitle: 'Semua pesanan',
                    ),
                  ),
                  const SizedBox(width: AppSpacings.sm),
                  Expanded(
                    child: StatCard(
                      icon: Icons.local_shipping_rounded,
                      title: 'Dalam Pengiriman',
                      value: '$_onDelivery',
                      subtitle: 'Sedang proses',
                      iconColor: Colors.orange[700],
                      iconBackgroundColor: Colors.orange[50],
                    ),
                  ),
                  const SizedBox(width: AppSpacings.sm),
                  Expanded(
                    child: StatCard(
                      icon: Icons.check_circle_rounded,
                      title: 'Selesai',
                      value: '$_completed',
                      subtitle: 'Berhasil dikirim',
                      iconColor: Colors.green[700],
                      iconBackgroundColor: Colors.green[50],
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildRecentOrdersSection() {
    if (_orders.isEmpty && !_isLoading) {
      return Center(
        child: Text('Belum ada pesanan', style: AppTextStyles.bodyMedium),
      );
    }

    // Show latest 10 orders
    final recentOrders = _orders.take(10).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Pesanan Terbaru', style: AppTextStyles.headlineMedium),
            Text(
              '${recentOrders.length} dari $_totalOrders',
              style: AppTextStyles.bodyMedium,
            ),
          ],
        ),
        const SizedBox(height: AppSpacings.md),
        ...recentOrders.map(
          (order) => OrderListItem(
            title: order.orderCode,
            subtitle:
                '${order.mitraName ?? "Mitra"} • ${order.totalWeight} ton',
            status: order.statusDisplay,
            statusColor: _getStatusColor(order.status),
            onTap: () => _showOrderActions(order),
          ),
        ),
      ],
    );
  }
}
