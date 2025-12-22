import 'dart:convert';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacings.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/icon_container.dart';
import '../../core/widgets/order_list_item.dart';
import '../../core/widgets/primary_button.dart';
import '../../services/api_client.dart';
import '../../models/delivery_order.dart';

class DriverTasksScreen extends StatefulWidget {
  const DriverTasksScreen({super.key});

  @override
  State<DriverTasksScreen> createState() => _DriverTasksScreenState();
}

class _DriverTasksScreenState extends State<DriverTasksScreen> {
  final _apiClient = ApiClient();
  Map<String, dynamic>? _userData;
  List<DeliveryOrder> _tasks = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _fetchTasks();
  }

  Future<void> _loadUserData() async {
    final userData = await _apiClient.getUserData();
    setState(() {
      _userData = userData;
    });
  }

  Future<void> _fetchTasks() async {
    setState(() => _isLoading = true);

    try {
      final response = await _apiClient.get('/driver/orders');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _tasks = data.map((json) => DeliveryOrder.fromJson(json)).toList();
        });
      } else {
        _showError('Gagal memuat tugas');
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

  void _showSuccess(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: AppColors.success),
      );
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

  void _showTaskActions(DeliveryOrder task) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(AppSpacings.screenPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Aksi untuk ${task.orderCode}',
              style: AppTextStyles.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacings.md),
            Text(
              'Tujuan: ${task.destination}',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: AppSpacings.sm),
            Text(
              'Status saat ini: ${task.statusDisplay}',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: AppSpacings.sectionSpacing),
            PrimaryButton(
              text: 'Update Status',
              onPressed: () {
                Navigator.pop(context);
                _showUpdateStatusDialog(task);
              },
            ),
            const SizedBox(height: AppSpacings.sm),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _sendLocation(task);
              },
              icon: const Icon(Icons.location_on),
              label: const Text('Kirim Lokasi'),
            ),
            const SizedBox(height: AppSpacings.sm),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
          ],
        ),
      ),
    );
  }

  void _showUpdateStatusDialog(DeliveryOrder task) {
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
            Text(
              'Pilih status baru untuk ${task.orderCode}:',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: AppSpacings.md),
            ...statuses.map(
              (status) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacings.sm),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _updateTaskStatus(task, status['value']!);
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

  Future<void> _updateTaskStatus(DeliveryOrder task, String newStatus) async {
    try {
      final response = await _apiClient.post(
        '/driver/delivery-orders/${task.id}/status',
        {'status': newStatus},
      );

      if (response.statusCode == 200) {
        _showSuccess('Status berhasil diupdate');
        await _fetchTasks(); // Refresh list
      } else {
        _showError('Gagal update status');
      }
    } catch (e) {
      _showError('Terjadi kesalahan: $e');
    }
  }

  Future<void> _sendLocation(DeliveryOrder task) async {
    try {
      // Using dummy coordinates for now
      // TODO: Get real GPS coordinates
      final response = await _apiClient.post(
        '/driver/delivery-orders/${task.id}/track',
        {'latitude': -6.2088, 'longitude': 106.8456},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showSuccess('Lokasi berhasil dikirim');
      } else {
        _showError('Gagal mengirim lokasi');
      }
    } catch (e) {
      _showError('Terjadi kesalahan: $e');
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
                Text(
                  _userData?['name'] ?? 'Driver',
                  style: AppTextStyles.titleLarge,
                ),
                const SizedBox(height: AppSpacings.xs),
                Text(
                  _userData?['email'] ?? 'driver@example.com',
                  style: AppTextStyles.bodyMedium,
                ),
                const SizedBox(height: AppSpacings.sm),
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
            onTap: () => _showTaskActions(task),
          ),
        ),
      ],
    );
  }
}
