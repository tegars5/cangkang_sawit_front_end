import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacings.dart';
import '../../core/widgets/dashboard_stat_card.dart';
import '../../core/widgets/dashboard_quick_action_button.dart';
import '../../repositories/order_repository.dart';
import '../../core/utils/result.dart';
import 'admin_orders_screen.dart';
// Actually we should use callback or parent tab controller to switch tabs if they are in the same scaffold
// But the user requested navigation. 'onTap -> AdminOrdersScreen'.
// Since AdminDashboardScreen uses a BottomNavigationBar, we might need a way to switch the index of the parent.
// For now, I will assume we can just push screens or better, notify the parent.
// But commonly in flutter bottom nav, we switch index.
// I will implement a callback passing mechanism or use a GlobalKey/Provider if complex.
// Simpler approach: define a callback function 'onTabChange' passed to this screen?
// Or just let it be a separate screen if user wants 'navigasi ke...'.
// The requirement said: "Tetap integrasikan bottom navigation admin yang sudah ada".
// So I will likely need a way to switch the bottom nav tab from this screen.
// I'll make a constructor that accepts a Function(int) onTabSelected.

class AdminOverviewScreen extends StatefulWidget {
  final Function(int) onTabSelected;

  const AdminOverviewScreen({super.key, required this.onTabSelected});

  @override
  State<AdminOverviewScreen> createState() => _AdminOverviewScreenState();
}

class _AdminOverviewScreenState extends State<AdminOverviewScreen> {
  final _orderRepository = OrderRepository();
  bool _isLoading = false;

  // Stats from backend
  int _newOrders = 0;
  int _pendingShipments = 0;
  int _activePartners = 0;
  int _inventoryTons = 0;

  String _lastUpdated = "--:--";

  @override
  void initState() {
    super.initState();
    _fetchSummary();
  }

  Future<void> _fetchSummary() async {
    setState(() {
      _isLoading = true;
    });

    final result = await _orderRepository.getAdminDashboardSummary();

    if (!mounted) return;

    result
        .onSuccess((data) {
          setState(() {
            _newOrders = data['new_orders'] ?? 0;
            _pendingShipments = data['pending_shipments'] ?? 0;
            _activePartners = data['active_partners'] ?? 0;
            _inventoryTons = data['inventory_tons'] ?? 0;

            final now = DateTime.now();
            _lastUpdated =
                "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
            _isLoading = false;
          });
        })
        .onFailure((e) {
          setState(() {
            _isLoading = false;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Gagal memuat data: ${e.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Light greyish background
      appBar: AppBar(
        title: const Text('Fujiyama Biomass'), // Branding Name
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const CircleAvatar(
              backgroundColor: Color(0xFFE0E0E0),
              child: Icon(Icons.person, color: AppColors.textSecondary),
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: _isLoading && _lastUpdated == "--:--"
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchSummary,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacings.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Text(
                      'Welcome back, Admin',
                      style: AppTextStyles.headlineMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Last updated: $_lastUpdated',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                    const SizedBox(height: AppSpacings.xl),

                    // Stat Grid
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 1.1,
                      children: [
                        DashboardStatCard(
                          title: 'New Orders',
                          value: '$_newOrders',
                          icon: Icons.shopping_bag_outlined,
                          iconColor: AppColors.primary,
                          onTap: () {
                            // Navigate to Orders with pending filter
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    AdminOrdersScreen(initialStatus: 'pending'),
                              ),
                            );
                          },
                        ),
                        DashboardStatCard(
                          title: 'Pending Shipments',
                          value: '$_pendingShipments',
                          icon: Icons.local_shipping_outlined,
                          iconColor: Colors.orange,
                          onTap: () {
                            // Navigate to Orders with on_delivery filter
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AdminOrdersScreen(
                                  initialStatus: 'on_delivery',
                                ),
                              ),
                            );
                          },
                        ),
                        DashboardStatCard(
                          title: 'Active Partners',
                          value: '$_activePartners',
                          icon: Icons.people_outline,
                          iconColor: Colors.blue,
                          onTap: () {
                            // Navigate to all orders (partners feature not ready)
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AdminOrdersScreen(),
                              ),
                            );
                          },
                        ),
                        DashboardStatCard(
                          title: 'Inventory (Tons)',
                          value:
                              '$_inventoryTons', // NumberFormat would be nice here
                          icon: Icons.inventory_2_outlined,
                          iconColor: Colors.purple,
                          onTap: () => widget.onTabSelected(2), // Products Tab
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacings.xl),

                    // Quick Actions
                    Text(
                      'Quick Actions',
                      style: AppTextStyles.titleLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacings.md),
                    DashboardQuickActionButton(
                      label: 'Create New Order',
                      icon: Icons.add_circle_outline,
                      isPrimary: true,
                      onTap: () {
                        // Navigate to Create Order Screen
                        // For now, maybe show dummy dialog or navigate if route exists
                      },
                    ),
                    const SizedBox(height: 12),
                    DashboardQuickActionButton(
                      label: 'Manage Products',
                      icon: Icons.category_outlined,
                      onTap: () => widget.onTabSelected(2), // Product Tab
                    ),
                    const SizedBox(height: 12),
                    DashboardQuickActionButton(
                      label: 'View All Shipments',
                      icon: Icons.exit_to_app,
                      onTap: () => widget.onTabSelected(1), // Orders Tab
                    ),

                    const SizedBox(height: AppSpacings.xl),

                    // Order Status Summary
                    Text(
                      'Ringkasan Status',
                      style: AppTextStyles.titleLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacings.md),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _StatusSummaryItem(
                                color: AppColors.primary,
                                label: 'Pesanan Baru',
                                value: '$_newOrders',
                              ),
                              _StatusSummaryItem(
                                color: Colors.orange,
                                label: 'Dalam Pengiriman',
                                value: '$_pendingShipments',
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _StatusSummaryItem(
                                color: Colors.blue,
                                label: 'Mitra Aktif',
                                value: '$_activePartners',
                              ),
                              _StatusSummaryItem(
                                color: Colors.purple,
                                label: 'Stok (Ton)',
                                value: '$_inventoryTons',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacings.xl),

                    // Recent Activity
                    Text(
                      'Recent Activity',
                      style: AppTextStyles.titleLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacings.md),
                    _ActivityItem(
                      icon: Icons.shopping_cart_outlined,
                      color: Colors.green,
                      message: 'New order #1024 placed',
                      time: '2 minutes ago',
                    ),
                    const SizedBox(height: 12),
                    _ActivityItem(
                      icon: Icons.cached_outlined,
                      color: Colors.orange,
                      message: 'Shipment #XYZ updated',
                      time: '15 minutes ago',
                    ),
                    const SizedBox(height: 12),
                    _ActivityItem(
                      icon: Icons.person_add_outlined,
                      color: Colors.blue,
                      message: 'New partner onboarded',
                      time: '1 hour ago',
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }
}

class _StatusSummaryItem extends StatelessWidget {
  final Color color;
  final String label;
  final String value;

  const _StatusSummaryItem({
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.displaySmall.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String message;
  final String time;

  const _ActivityItem({
    required this.icon,
    required this.color,
    required this.message,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  time,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
