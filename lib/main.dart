import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/theme/app_theme.dart';
import 'services/api_client.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';

void main() async {
  // Pastikan Flutter binding sudah diinisialisasi
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Indonesian locale for date formatting
  await initializeDateFormatting('id_ID', null);
  Intl.defaultLocale = 'id_ID';

  // Inisialisasi SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  runApp(MyApp(prefs: prefs));
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;

  MyApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Cangkang Sawit',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: _router,
    );
  }

  // GoRouter configuration
  late final GoRouter _router = GoRouter(
    initialLocation: '/login',
    redirect: (context, state) async {
      final apiClient = ApiClient();
      final token = await apiClient.getToken();
      final role = await apiClient.getRole();

      final isLoginRoute = state.matchedLocation == '/login';
      final hasToken = token != null && token.isNotEmpty;

      // If no token and not on login page, redirect to login
      if (!hasToken && !isLoginRoute) {
        return '/login';
      }

      // If has token and on login page, redirect based on role
      if (hasToken && isLoginRoute && role != null) {
        return '/home';
      }

      // No redirect needed
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/home',
        builder: (context, state) {
          return FutureBuilder<String?>(
            future: ApiClient().getRole(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              final role = snapshot.data ?? 'user';
              return HomeScreen(role: role);
            },
          );
        },
      ),
      // Legacy routes for backward compatibility
      GoRoute(
        path: '/mitra/orders',
        builder: (context, state) => const HomeScreen(role: 'mitra'),
      ),
      GoRoute(
        path: '/admin/orders',
        builder: (context, state) => const HomeScreen(role: 'admin'),
      ),
      GoRoute(
        path: '/driver/tasks',
        builder: (context, state) => const HomeScreen(role: 'driver'),
      ),
    ],
  );
}
