import 'dart:convert';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacings.dart';
import '../../core/theme/app_radius.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/icon_container.dart';
import '../../core/widgets/order_list_item.dart';
import '../../services/api_client.dart';
import '../../models/order.dart';
import 'order_detail_screen.dart';
import 'create_order_screen.dart';

class MitraOrdersScreen extends StatefulWidget {
  const MitraOrdersScreen({super.key});

  @override
  State<MitraOrdersScreen> createState() => _MitraOrdersScreenState();
}

class _MitraOrdersScreenState extends State<MitraOrdersScreen> {
  final _apiClient = ApiClient();
  Map<String, dynamic>? _userData;
  List<Order> _orders = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _fetchOrders();
  }

  Future<void> _loadUserData() async {
    final userData = await _apiClient.getUserData();
    setState(() {
      _userData = userData;
    });
  }

  Future<void> _fetchOrders() async {
    setState(() => _isLoading = true);

    try {
      final response = await _apiClient.get('/orders');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _orders = data.map((json) => Order.fromJson(json)).toList();
        });
      } else {
        _showError('Gagal memuat pesanan');
      }
    } catch (e) {
      _showError('Terjadi kesalahan: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: AppColors.error),
      );
    }
  }

  Future<void> _navigateToCreateOrder() async {
    final shouldRefresh = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const CreateOrderScreen()),
    );

    if (shouldRefresh == true) {
      _fetchOrders(); // Refresh orders after creating new order
    }
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _apiClient.clearAllData();
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
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
        title: Text('Pesanan Saya', style: AppTextStyles.headlineMedium),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
            tooltip: 'Logout',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToCreateOrder,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surface,
        icon: const Icon(Icons.add),
        label: const Text('Buat Pesanan'),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchOrders,
        color: AppColors.primary,
        child: _isLoading && _orders.isEmpty
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppSpacings.screenPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildUserInfoCard(),
                    const SizedBox(height: AppSpacings.sectionSpacing),
                    _buildOrdersSection(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildUserInfoCard() {
    return AppCard(
      child: Column(
        children: [
          const IconContainer(icon: Icons.shopping_bag_rounded, iconSize: 56),
          const SizedBox(height: AppSpacings.sectionSpacing),
          Text('Halo, Mitra!', style: AppTextStyles.displayMedium),
          const SizedBox(height: AppSpacings.sm + 4),
          if (_userData != null) ...[
            Text(
              _userData!['name'] ?? 'User',
              style: AppTextStyles.titleLarge.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacings.xs + 2),
            Text(
              _userData!['email'] ?? '',
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOrdersSection() {
    if (_orders.isEmpty && !_isLoading) {
      return Container(
        padding: const EdgeInsets.all(AppSpacings.xl),
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: AppRadius.largeRadius,
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: AppColors.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: AppSpacings.md),
            Text(
              'Belum ada pesanan',
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacings.xs),
            Text(
              'Pesanan Anda akan muncul di sini',
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
            Text('Daftar Pesanan', style: AppTextStyles.headlineMedium),
            Text('${_orders.length} pesanan', style: AppTextStyles.bodyMedium),
          ],
        ),
        const SizedBox(height: AppSpacings.md),
        ..._orders.map(
          (order) => OrderListItem(
            title: order.orderCode,
            subtitle: '${order.destination} • ${order.totalWeight} ton',
            status: order.statusDisplay,
            statusColor: _getStatusColor(order.status),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OrderDetailScreen(order: order),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
