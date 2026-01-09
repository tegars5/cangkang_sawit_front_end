import 'package:flutter/material.dart';
import '../../services/api_client.dart';
import '../../core/theme/app_colors.dart';
import '../products/product_list_screen.dart';
import '../orders/order_list_screen.dart';
import '../admin/admin_dashboard_screen.dart';
import '../driver/driver_orders_screen.dart';

/// Home screen dengan BottomNavigationBar role-based
class HomeScreen extends StatefulWidget {
  final String role;

  const HomeScreen({super.key, required this.role});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // Get screens based on role
  List<Widget> get _screens {
    switch (widget.role.toLowerCase()) {
      case 'admin':
        return [
          const AdminDashboardScreen(),
          const ProductListScreen(),
          const OrderListScreen(),
          const ProfileScreen(),
        ];
      case 'driver':
        return [const DriverOrdersScreen(), const ProfileScreen()];
      case 'mitra':
      case 'user':
      default:
        return [
          const ProductListScreen(),
          const OrderListScreen(),
          const ProfileScreen(),
        ];
    }
  }

  // Get navigation items based on role
  List<BottomNavigationBarItem> get _navItems {
    switch (widget.role.toLowerCase()) {
      case 'admin':
        return const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            activeIcon: Icon(Icons.inventory_2),
            label: 'Produk',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: 'Pesanan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ];
      case 'driver':
        return const [
          BottomNavigationBarItem(
            icon: Icon(Icons.local_shipping_outlined),
            activeIcon: Icon(Icons.local_shipping),
            label: 'Pengiriman',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ];
      case 'mitra':
      case 'user':
      default:
        return const [
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_outlined),
            activeIcon: Icon(Icons.shopping_bag),
            label: 'Produk',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: 'Pesanan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        items: _navItems,
      ),
    );
  }
}

/// Simple Profile Screen
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final apiClient = ApiClient();

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: apiClient.getUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final userData = snapshot.data;
          final name = userData?['name'] ?? 'User';
          final email = userData?['email'] ?? '';
          final role = userData?['role'] ?? '';

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const CircleAvatar(
                radius: 50,
                backgroundColor: AppColors.primary,
                child: Icon(Icons.person, size: 50, color: Colors.white),
              ),
              const SizedBox(height: 16),
              Text(
                name,
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                email,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                _getRoleDisplay(role),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ListTile(
                leading: const Icon(Icons.settings_outlined),
                title: const Text('Pengaturan'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // TODO: Navigate to settings
                },
              ),
              ListTile(
                leading: const Icon(Icons.help_outline),
                title: const Text('Bantuan'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // TODO: Navigate to help
                },
              ),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('Tentang Aplikasi'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // TODO: Show about dialog
                },
              ),
              const Divider(height: 32),
              ListTile(
                leading: const Icon(Icons.logout, color: AppColors.error),
                title: const Text(
                  'Keluar',
                  style: TextStyle(color: AppColors.error),
                ),
                onTap: () async {
                  final shouldLogout = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Konfirmasi'),
                      content: const Text('Apakah Anda yakin ingin keluar?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Batal'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text(
                            'Keluar',
                            style: TextStyle(color: AppColors.error),
                          ),
                        ),
                      ],
                    ),
                  );

                  if (shouldLogout == true && context.mounted) {
                    await apiClient.clearAllData();
                    if (context.mounted) {
                      Navigator.of(
                        context,
                      ).pushNamedAndRemoveUntil('/login', (route) => false);
                    }
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }

  String _getRoleDisplay(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return 'Administrator';
      case 'driver':
        return 'Driver';
      case 'mitra':
      case 'user':
        return 'Mitra';
      default:
        return role;
    }
  }
}
