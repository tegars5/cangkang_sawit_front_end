import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'services/api_client.dart';
import 'screens/auth/login_screen.dart';
import 'screens/mitra/orders_screen.dart';
import 'screens/admin/admin_orders_screen.dart';
import 'screens/driver/driver_tasks_screen.dart';

void main() async {
  // Pastikan Flutter binding sudah diinisialisasi
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  runApp(MyApp(prefs: prefs));
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;

  const MyApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cangkang Sawit',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,

      // Routes
      routes: {
        '/login': (context) => const LoginScreen(),
        '/mitra/orders': (context) => const MitraOrdersScreen(),
        '/admin/orders': (context) => const AdminOrdersScreen(),
        '/driver/tasks': (context) => const DriverTasksScreen(),
      },

      // Initial route berdasarkan token
      home: FutureBuilder<Widget>(
        future: _determineInitialScreen(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          return snapshot.data ?? const LoginScreen();
        },
      ),
    );
  }

  // Tentukan screen awal berdasarkan token dan role
  Future<Widget> _determineInitialScreen() async {
    final apiClient = ApiClient();
    final token = await apiClient.getToken();

    // Jika tidak ada token, tampilkan login screen
    if (token == null || token.isEmpty) {
      return const LoginScreen();
    }

    // Jika ada token, cek role dan arahkan ke screen yang sesuai
    final role = await apiClient.getRole();

    switch (role) {
      case 'mitra':
        return const MitraOrdersScreen();
      case 'admin':
        return const AdminOrdersScreen();
      case 'driver':
        return const DriverTasksScreen();
      default:
        // Jika role tidak dikenali, arahkan ke login
        return const LoginScreen();
    }
  }
}
