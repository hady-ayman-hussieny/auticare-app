import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:auticare/features/auth/logic/auth_provider.dart';
import 'package:auticare/core/constants/app_routes.dart';
import 'package:auticare/core/theme/app_colors.dart';
import 'package:auticare/shared/widgets/gradient_button.dart';
import 'package:auticare/shared/widgets/app_text_field.dart';
import 'package:auticare/shared/widgets/feedback_widgets.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _natIdCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  String _role = 'parent';
  bool _obscure = true;
  bool _obscureConfirm = true;
  String _error = '';

  static const _roles = [
    {'value': 'parent', 'label': 'Parent'},
    {'value': 'doctor', 'label': 'Doctor'},
    {'value': 'therapist', 'label': 'Therapist'},
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _natIdCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _error = '');
    final auth = context.read<AuthProvider>();
    try {
      final capitalizedRole = _role == 'parent'
          ? 'Parent'
          : _role == 'doctor'
              ? 'Doctor'
              : 'Therapist';

      await auth.signup({
        'fullName': _nameCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'password': _passCtrl.text,
        'phone': _phoneCtrl.text.trim(),
        'nationalId': _natIdCtrl.text.trim(),
        'role': capitalizedRole,
      });
      if (!mounted) return;
      if (_role == 'doctor' || _role == 'therapist') {
        context.go(AppRoutes.doctorHome);
      } else {
        context.go(AppRoutes.addChild);
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
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradientLight,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.favorite_rounded, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'AutiCare',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Center(
                    child: Text(
                      'Create your account',
                      style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.mutedLight),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Card
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0F172A) : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : AppColors.slate200,
                      ),
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text('Sign Up',
                              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                          const SizedBox(height: 20),

                          ErrorBanner(
                            message: _error,
                            onDismiss: () => setState(() => _error = ''),
                          ),

                          // Role selector
                          Text('I am a…', style: theme.textTheme.labelMedium),
                          const SizedBox(height: 8),
                          Row(
                            children: _roles.map((r) {
                              final selected = _role == r['value'];
                              return Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: GestureDetector(
                                    onTap: () => setState(() => _role = r['value']!),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                      decoration: BoxDecoration(
                                        color: selected
                                            ? AppColors.accentLight.withValues(alpha: 0.12)
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: selected
                                              ? AppColors.accentLight
                                              : AppColors.slate300,
                                          width: selected ? 2 : 1,
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          r['label']!,
                                          style: TextStyle(
                                            color: selected ? AppColors.accentLight : AppColors.slate600,
                                            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 16),

                          AppTextField(
                            label: 'Full name',
                            controller: _nameCtrl,
                            textInputAction: TextInputAction.next,
                            prefixIcon: const Icon(Icons.person_outline_rounded),
                            validator: (v) => v == null || v.trim().isEmpty ? 'Name is required' : null,
                          ),
                          const SizedBox(height: 14),

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
                          const SizedBox(height: 14),

                          AppTextField(
                            label: 'Phone number',
                            hint: '01012345678',
                            controller: _phoneCtrl,
                            keyboardType: TextInputType.phone,
                            textInputAction: TextInputAction.next,
                            prefixIcon: const Icon(Icons.phone_outlined),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return 'Phone number is required';
                              final reg = RegExp(r'^01[0125][0-9]{8}$');
                              if (!reg.hasMatch(v.trim())) {
                                return 'Enter a valid Egyptian mobile number (e.g., 01012345678)';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),

                          AppTextField(
                            label: 'National ID',
                            hint: '14-digit number',
                            controller: _natIdCtrl,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.next,
                            prefixIcon: const Icon(Icons.badge_outlined),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return 'National ID is required';
                              if (v.trim().length != 14 || !RegExp(r'^[0-9]+$').hasMatch(v.trim())) {
                                return 'Enter a valid 14-digit National ID';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),

                          AppTextField(
                            label: 'Password',
                            controller: _passCtrl,
                            obscureText: _obscure,
                            textInputAction: TextInputAction.next,
                            prefixIcon: const Icon(Icons.lock_outline_rounded),
                            suffixIcon: IconButton(
                              icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                              onPressed: () => setState(() => _obscure = !_obscure),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Password is required';
                              if (v.length < 6) return 'At least 6 characters';
                              if (!v.contains(RegExp(r'[A-Z]'))) {
                                return 'Must contain at least one uppercase letter';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),

                          AppTextField(
                            label: 'Confirm password',
                            controller: _confirmCtrl,
                            obscureText: _obscureConfirm,
                            textInputAction: TextInputAction.done,
                            prefixIcon: const Icon(Icons.lock_outline_rounded),
                            suffixIcon: IconButton(
                              icon: Icon(_obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                              onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                            ),
                            validator: (v) {
                              if (v != _passCtrl.text) return 'Passwords do not match';
                              return null;
                            },
                          ),
                          const SizedBox(height: 22),

                          GradientButton(
                            label: 'Create Account',
                            isLoading: auth.loading,
                            onPressed: auth.loading ? null : _submit,
                          ),
                          const SizedBox(height: 16),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Already have an account? ', style: theme.textTheme.bodySmall),
                              GestureDetector(
                                onTap: () => context.go(AppRoutes.login),
                                child: Text(
                                  'Sign In',
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
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
