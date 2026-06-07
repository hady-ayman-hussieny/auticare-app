import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:auticare/features/auth/logic/auth_provider.dart';
import 'package:auticare/core/constants/app_routes.dart';
import 'package:auticare/core/theme/app_colors.dart';
import 'package:auticare/shared/widgets/gradient_button.dart';
import 'package:auticare/shared/widgets/app_text_field.dart';
import 'package:auticare/shared/widgets/feedback_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  String _error = '';

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _error = '');
    final auth = context.read<AuthProvider>();
    try {
      await auth.login(_emailCtrl.text.trim(), _passCtrl.text);
      if (!mounted) return;
      final role = auth.user?.role ?? 'parent';
      if (role == 'doctor' || role == 'therapist') {
        context.go(AppRoutes.doctorHome);
      } else {
        context.go(AppRoutes.parentHome);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = e.toString().replaceAll('Exception: ', ''));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo & Hero
                  _buildHero(isDark, theme),
                  const SizedBox(height: 32),

                  // Card
                  _buildCard(isDark, theme, auth),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHero(bool isDark, ThemeData theme) {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradientLight,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.orange500.withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              )
            ],
          ),
          child: const Icon(Icons.favorite_rounded, color: Colors.white, size: 36),
        ),
        const SizedBox(height: 16),
        Text(
          'AutiCare',
          style: theme.textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Welcome back — sign in to continue',
          style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.mutedLight),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildCard(bool isDark, ThemeData theme, AuthProvider auth) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : AppColors.slate200,
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: AppColors.slate200.withValues(alpha: 0.8),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                )
              ],
      ),
      padding: const EdgeInsets.all(28),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Sign In',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 24),

            ErrorBanner(
              message: _error,
              onDismiss: () => setState(() => _error = ''),
            ),

            AppTextField(
              label: 'Email address',
              hint: 'you@example.com',
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              prefixIcon: const Icon(Icons.email_outlined),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Email is required';
                if (!v.contains('@')) return 'Enter a valid email';
                return null;
              },
            ),
            const SizedBox(height: 16),

            AppTextField(
              label: 'Password',
              controller: _passCtrl,
              obscureText: _obscure,
              textInputAction: TextInputAction.done,
              prefixIcon: const Icon(Icons.lock_outline_rounded),
              suffixIcon: IconButton(
                icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Password is required';
                if (v.length < 6) return 'At least 6 characters';
                return null;
              },
            ),
            const SizedBox(height: 10),

            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => context.push(AppRoutes.forgotPassword),
                child: const Text('Forgot password?'),
              ),
            ),
            const SizedBox(height: 16),

            GradientButton(
              label: 'Sign In',
              isLoading: auth.loading,
              onPressed: auth.loading ? null : _submit,
            ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Don't have an account? ",
                  style: theme.textTheme.bodySmall,
                ),
                GestureDetector(
                  onTap: () => context.go(AppRoutes.signup),
                  child: Text(
                    'Sign Up',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.accentLight,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
