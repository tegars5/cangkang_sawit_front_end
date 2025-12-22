import 'dart:convert';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacings.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/icon_container.dart';
import '../../services/api_client.dart';
import '../mitra/orders_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _apiClient = ApiClient();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Panggil API login
      final response = await _apiClient.post('/login', {
        'email': _emailController.text.trim(),
        'password': _passwordController.text,
      });

      if (response.statusCode == 200) {
        // Parse response
        final data = jsonDecode(response.body);

        // Ambil token dan user data
        final token = data['token'] as String;
        final user = data['user'] as Map<String, dynamic>;
        final role = user['role'] as String;

        // Simpan token dan data user
        await _apiClient.setToken(token);
        await _apiClient.setRole(role);
        await _apiClient.setUserData(user);

        if (!mounted) return;

        // Navigate berdasarkan role
        if (role == 'mitra') {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const MitraOrdersScreen()),
          );
        } else if (role == 'admin') {
          Navigator.of(context).pushReplacementNamed('/admin/orders');
        } else if (role == 'driver') {
          Navigator.of(context).pushReplacementNamed('/driver/tasks');
        } else {
          _showErrorDialog('Role tidak dikenali: $role');
        }
      } else {
        // Login gagal
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['message'] ?? 'Login gagal';
        _showErrorDialog(errorMessage);
      }
    } catch (e) {
      _showErrorDialog('Terjadi kesalahan: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Login Gagal'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primaryLight, AppColors.surface],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacings.screenPadding),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildHeader(),
                  const SizedBox(height: AppSpacings.xxl),
                  _buildLoginCard(),
                  const SizedBox(height: AppSpacings.sectionSpacing),
                  _buildInfoText(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        const IconContainer(icon: Icons.eco),
        const SizedBox(height: AppSpacings.sectionSpacing),
        Text('Cangkang Sawit', style: AppTextStyles.displayLarge),
        const SizedBox(height: AppSpacings.sm),
        Text('Sistem Manajemen Logistik', style: AppTextStyles.subtitle),
      ],
    );
  }

  Widget _buildLoginCard() {
    return AppCard(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Masuk ke Akun',
              style: AppTextStyles.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacings.sectionSpacing),
            AppTextField(
              controller: _emailController,
              labelText: 'Email',
              hintText: 'nama@email.com',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Email tidak boleh kosong';
                }
                if (!value.contains('@')) {
                  return 'Email tidak valid';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacings.itemSpacing + 4),
            AppTextField(
              controller: _passwordController,
              labelText: 'Password',
              hintText: 'Masukkan password',
              prefixIcon: Icons.lock_outlined,
              obscureText: _obscurePassword,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: AppColors.textSecondary,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Password tidak boleh kosong';
                }
                if (value.length < 6) {
                  return 'Password minimal 6 karakter';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacings.xl),
            PrimaryButton(
              text: 'Masuk',
              onPressed: _handleLogin,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoText() {
    return Text(
      'Gunakan kredensial yang telah terdaftar di sistem',
      style: AppTextStyles.bodySmall,
      textAlign: TextAlign.center,
    );
  }
}
