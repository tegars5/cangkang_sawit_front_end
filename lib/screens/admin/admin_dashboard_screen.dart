import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'admin_orders_screen.dart';
import 'admin_products_screen.dart';
import 'admin_overview_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    // We instantiate screens here to pass the callback.
    // Ideally use a list initialized in initState if maintaining state is critical,
    // but for simple switching this works.
    final List<Widget> screens = [
      AdminOverviewScreen(
        onTabSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      const AdminOrdersScreen(), // Note: We might need to pass params here later
      const AdminProductsScreen(),
    ];

    return Scaffold(
      body: screens[_currentIndex], // Use the local list
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_outlined),
            activeIcon: Icon(Icons.shopping_bag),
            label: 'Pesanan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            activeIcon: Icon(Icons.inventory_2),
            label: 'Produk',
          ),
        ],
      ),
    );
  }
}
