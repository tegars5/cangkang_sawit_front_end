import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacings.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/validators.dart';
import '../../core/utils/result.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/icon_container.dart';
import '../../repositories/auth_repository.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authRepository = AuthRepository();
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

    final result = await _authRepository.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) return;

    result
        .onSuccess((data) async {
          // Extract token and user data
          final token = data['token'] as String;
          final user = data['user'] as Map<String, dynamic>;
          final role = user['role'] as String;

          // Save authentication data
          await _authRepository.saveToken(token);
          await _authRepository.saveRole(role);
          await _authRepository.saveUserData(user);

          if (!mounted) return;

          // Navigate based on role
          switch (role) {
            case 'mitra':
              context.go('/mitra/orders');
              break;
            case 'admin':
              context.go('/admin/orders');
              break;
            case 'driver':
              context.go('/driver/tasks');
              break;
            default:
              _showErrorDialog('Role tidak dikenali: $role');
          }
        })
        .onFailure((failure) {
          _showErrorDialog(failure.message);
        });

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppStrings.loginFailed),
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
              labelText: AppStrings.email,
              hintText: 'nama@email.com',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: Validators.email,
            ),
            const SizedBox(height: AppSpacings.itemSpacing + 4),
            AppTextField(
              controller: _passwordController,
              labelText: AppStrings.password,
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
              validator: Validators.password,
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
