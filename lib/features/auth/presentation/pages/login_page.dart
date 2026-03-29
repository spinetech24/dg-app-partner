import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../providers/auth_providers.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  String get _fullPhone => '+91${_phoneController.text.trim()}';

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final success = await ref.read(otpProvider.notifier).sendOtp(_fullPhone);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      context.push(AppConstants.otpRoute, extra: _fullPhone);
    } else {
      final error = ref.read(otpProvider).errorMessage ?? 'Failed to send OTP';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      final authService = ref.read(authServiceProvider);
      final response = await authService.signInWithGoogle();
      if (!mounted) return;
      if (response?.user != null) {
        context.go(AppConstants.dashboardRoute);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Google Sign-In failed: $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithApple() async {
    final authService = ref.read(authServiceProvider);
    await authService.signInWithApple();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.navyBlue,
        body: Column(
          children: [
            // ── Navy Hero Section ──────────────────────────────────────────
            Expanded(
              flex: 5,
              child: _HeroSection(),
            ),

            // ── White Card Section ─────────────────────────────────────────
            Expanded(
              flex: 6,
              child: _FormCard(
                formKey: _formKey,
                phoneController: _phoneController,
                isLoading: _isLoading,
                onSendOtp: _sendOtp,
                onGoogle: _signInWithGoogle,
                onApple: _signInWithApple,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Hero (navy top section) ─────────────────────────────────────────────────

class _HeroSection extends StatelessWidget {
  const _HeroSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.navyBlue, AppColors.navyBlueDark],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Back button
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () => Navigator.maybePop(context),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.15),
                    ),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ).animate().fadeIn(duration: 300.ms),

              const Gap(12),

              // DG circular logo
              _DgLogo()
                  .animate()
                  .fadeIn(delay: 150.ms, duration: 500.ms)
                  .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1)),

              const Gap(16),

              // DEVGRUHA label
              Text(
                'DEVGRUHA',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.85),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 3,
                ),
              ).animate().fadeIn(delay: 280.ms),

              const Gap(4),

              // Saathi headline
              const Text(
                'Saathi',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                  height: 1.1,
                ),
              ).animate().fadeIn(delay: 320.ms).slideY(begin: 0.2, end: 0),

              const Gap(6),

              // Subtitle
              Text(
                'Your Trusted Partner in Devotion',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              ).animate().fadeIn(delay: 380.ms),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── DG Logo ─────────────────────────────────────────────────────────────────

class _DgLogo extends StatelessWidget {
  const _DgLogo();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.navyBlueDark.withOpacity(0.5),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          AppConstants.dgLogoImage,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: Center(
              child: Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [AppColors.navyBlueLight, AppColors.navyBlue],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Center(
                  child: Text(
                    'DG',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── White Form Card ──────────────────────────────────────────────────────────

class _FormCard extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController phoneController;
  final bool isLoading;
  final VoidCallback onSendOtp;
  final VoidCallback onGoogle;
  final VoidCallback onApple;

  const _FormCard({
    required this.formKey,
    required this.phoneController,
    required this.isLoading,
    required this.onSendOtp,
    required this.onGoogle,
    required this.onApple,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.offWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Mobile Number Label ──────────────────────────────────────
              const Text(
                'MOBILE NUMBER',
                style: TextStyle(
                  color: AppColors.textSecondaryLight,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ).animate().fadeIn(delay: 300.ms),

              const Gap(8),

              // ── Phone Input ──────────────────────────────────────────────
              TextFormField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                style: const TextStyle(
                  color: AppColors.charcoal,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: '00000 00000',
                  hintStyle: const TextStyle(
                    color: AppColors.lightGrey,
                    fontSize: 16,
                    letterSpacing: 1,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.borderLight),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.borderLight),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.navyBlue, width: 2),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.error),
                  ),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: 14, right: 10),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Indian flag emoji + code
                        const Text('🇮🇳', style: TextStyle(fontSize: 18)),
                        const Gap(6),
                        const Text(
                          '+91',
                          style: TextStyle(
                            color: AppColors.charcoal,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Gap(10),
                        Container(
                          width: 1,
                          height: 20,
                          color: AppColors.borderLight,
                        ),
                      ],
                    ),
                  ),
                  prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your mobile number';
                  }
                  if (value.length != 10) {
                    return 'Enter a valid 10-digit mobile number';
                  }
                  return null;
                },
              ).animate().fadeIn(delay: 350.ms).slideY(begin: 0.15, end: 0),

              const Gap(16),

              // ── Send OTP Button ──────────────────────────────────────────
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: isLoading
                    ? Container(
                        key: const ValueKey('loading'),
                        height: 52,
                        decoration: BoxDecoration(
                          color: AppColors.navyBlue,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth: 2.5,
                          ),
                        ),
                      )
                    : ElevatedButton(
                        key: const ValueKey('sendOtp'),
                        onPressed: onSendOtp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.navyBlue,
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            letterSpacing: 1.2,
                          ),
                        ),
                        child: const Text('SEND OTP'),
                      ),
              ).animate().fadeIn(delay: 400.ms),

              const Gap(20),

              // ── Register Link ────────────────────────────────────────────
              Center(
                child: RichText(
                  text: TextSpan(
                    text: "Don't have an account? ",
                    style: const TextStyle(
                      color: AppColors.textSecondaryLight,
                      fontSize: 13,
                    ),
                    children: [
                      WidgetSpan(
                        child: GestureDetector(
                          onTap: () {
                            // TODO: navigate to register
                          },
                          child: const Text(
                            'Register as Partner',
                            style: TextStyle(
                              color: AppColors.navyBlue,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: 450.ms),

              const Gap(28),

              // ── Terms ────────────────────────────────────────────────────
              Center(
                child: Text.rich(
                  TextSpan(
                    text: 'By continuing, you agree to our\n',
                    style: TextStyle(
                      color: AppColors.textSecondaryLight.withOpacity(0.7),
                      fontSize: 11,
                      height: 1.6,
                    ),
                    children: [
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: GestureDetector(
                          onTap: () => launchUrl(
                            Uri.parse('https://devgruha.com/terms'),
                            mode: LaunchMode.inAppBrowserView,
                          ),
                          child: const Text(
                            'Terms of Service',
                            style: TextStyle(
                              color: AppColors.navyBlue,
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                              decoration: TextDecoration.underline,
                              decorationColor: AppColors.navyBlue,
                            ),
                          ),
                        ),
                      ),
                      const TextSpan(text: '  and  '),
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: GestureDetector(
                          onTap: () => launchUrl(
                            Uri.parse('https://devgruha.com/privacy'),
                            mode: LaunchMode.inAppBrowserView,
                          ),
                          child: const Text(
                            'Privacy Policy',
                            style: TextStyle(
                              color: AppColors.navyBlue,
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                              decoration: TextDecoration.underline,
                              decorationColor: AppColors.navyBlue,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ).animate().fadeIn(delay: 500.ms),
            ],
          ),
        ),
      ),
    );
  }
}
