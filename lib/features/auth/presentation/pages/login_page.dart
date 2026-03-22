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
import '../widgets/social_auth_button.dart';

// ─── Brand colors matching Stitch design ─────────────────────────────────────
const Color _navyDark = Color(0xFF00114A);
const Color _navyMid = Color(0xFF0A2472);
const Color _white70 = Color(0xB3FFFFFF);
const Color _white55 = Color(0x8CFFFFFF);

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
    return Scaffold(
      // No system chrome — we own the full immersive screen
      backgroundColor: const Color(0xFFF8F7F5),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // ─── Immersive Hero Section ─────────────────────────
              _HeroSection(),

              // ─── Floating Card + Footer ─────────────────────────
              _LoginCard(
                phoneController: _phoneController,
                isLoading: _isLoading,
                onSendOtp: _sendOtp,
                onGoogleSignIn: _signInWithGoogle,
                onAppleSignIn: _signInWithApple,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  HERO SECTION
// ─────────────────────────────────────────────────────────────────────────────
class _HeroSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      // Note: no fixed height — let SafeArea + padding drive it naturally
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 24,
        bottom: 80,
        left: 24,
        right: 24,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_navyMid, _navyDark],
        ),
      ),
      child: Stack(
        children: [
          // Decorative blobs
          Positioned(
            top: -24,
            right: -24,
            child: _Blob(color: _navyMid.withValues(alpha: 0.5), size: 200),
          ),
          Positioned(
            bottom: -24,
            left: -24,
            child: _Blob(color: Colors.white.withValues(alpha: 0.05), size: 200),
          ),

          // Content
          Column(
            children: [
              // Back button
              Align(
                alignment: Alignment.centerLeft,
                child: _NavBackButton(),
              ),

              const Gap(32),

              // DG Logo ring
              _LogoRing()
                  .animate()
                  .fadeIn(duration: 600.ms)
                  .scale(begin: const Offset(0.85, 0.85), curve: Curves.easeOutBack),

              const Gap(24),

              // "DEVGRUHA" small caps
              const Text(
                'DEVGRUHA',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 5,
                  color: _white70,
                ),
              )
                  .animate()
                  .fadeIn(delay: 200.ms, duration: 500.ms)
                  .slideY(begin: 0.3, end: 0),

              const Gap(8),

              // "Saathi" hero title
              const Text(
                'Saathi',
                style: TextStyle(
                  fontSize: 50,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -1.5,
                  height: 1.1,
                ),
              )
                  .animate()
                  .fadeIn(delay: 280.ms, duration: 500.ms)
                  .slideY(begin: 0.2, end: 0),

              const Gap(10),

              // Tagline
              const Text(
                'Your Trusted Partner in Devotion',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: _white55,
                  height: 1.5,
                ),
              )
                  .animate()
                  .fadeIn(delay: 360.ms, duration: 400.ms),
            ],
          ),
        ],
      ),
    );
  }
}

// Decorative translucent blob
class _Blob extends StatelessWidget {
  final Color color;
  final double size;

  const _Blob({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}

// Back button
class _NavBackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.maybePop(context),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.1),
        ),
        child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
      ),
    );
  }
}

// Circular DG logo with ring and glow
class _LogoRing extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      height: 140,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.28),
            blurRadius: 40,
            offset: const Offset(0, 12),
          ),
        ],
        border: Border.all(color: Colors.white.withValues(alpha: 0.12), width: 8),
      ),
      child: ClipOval(
        child: Image.asset(
          AppConstants.dgLogoImage,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => Container(
            color: _navyMid,
            child: const Center(
              child: Text(
                'DG',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 36,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  LOGIN CARD (overlaps hero with negative top margin)
// ─────────────────────────────────────────────────────────────────────────────
class _LoginCard extends StatelessWidget {
  final TextEditingController phoneController;
  final bool isLoading;
  final VoidCallback onSendOtp;
  final VoidCallback onGoogleSignIn;
  final VoidCallback onAppleSignIn;

  const _LoginCard({
    required this.phoneController,
    required this.isLoading,
    required this.onSendOtp,
    required this.onGoogleSignIn,
    required this.onAppleSignIn,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -48), // overlap hero
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            // The card itself
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.13),
                    blurRadius: 40,
                    offset: const Offset(0, 16),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ─── Mobile Number label ─────────────────────────
                  const Text(
                    'MOBILE NUMBER',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: Color(0xFF94A3B8),
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 200.ms, duration: 400.ms),

                  const Gap(10),

                  // ─── Phone input ─────────────────────────────────
                  _PhoneInput(controller: phoneController)
                      .animate()
                      .fadeIn(delay: 280.ms, duration: 400.ms)
                      .slideY(begin: 0.15, end: 0),

                  const Gap(20),

                  // ─── SEND OTP button ──────────────────────────────
                  _SendOtpButton(isLoading: isLoading, onTap: onSendOtp)
                      .animate()
                      .fadeIn(delay: 360.ms, duration: 400.ms),

                  const Gap(20),

                  // ─── Register link ────────────────────────────────
                  Center(
                    child: Column(
                      children: [
                        const Text(
                          "Don't have an account?",
                          style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                        ),
                        const Gap(4),
                        GestureDetector(
                          onTap: () {},
                          child: const Text(
                            'Register as Partner',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: _navyMid,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 420.ms, duration: 400.ms),
                ],
              ),
            )
                .animate()
                .fadeIn(delay: 150.ms, duration: 500.ms)
                .slideY(begin: 0.1, end: 0),

            const Gap(16),

            // ─── Or continue with ─────────────────────────────────
            Row(
              children: [
                const Expanded(child: Divider(color: Color(0xFFE2E8F0))),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'Or continue with',
                    style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                  ),
                ),
                const Expanded(child: Divider(color: Color(0xFFE2E8F0))),
              ],
            ).animate().fadeIn(delay: 520.ms, duration: 400.ms),

            const Gap(14),

            // ─── Social auth buttons ──────────────────────────────
            Row(
              children: [
                Expanded(
                  child: SocialAuthButton(
                    label: 'Google',
                    iconWidget: Image.asset(
                      AppConstants.googleLogoImage,
                      width: 22, height: 22,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.g_mobiledata_rounded,
                        size: 24, color: Color(0xFF4285F4),
                      ),
                    ),
                    onTap: onGoogleSignIn,
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: SocialAuthButton(
                    label: 'Apple',
                    iconWidget: const Icon(Icons.apple, size: 24),
                    onTap: onAppleSignIn,
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 580.ms, duration: 400.ms),

            const Gap(24),

            // ─── Terms footer ─────────────────────────────────────
            Text.rich(
              TextSpan(
                text: 'By continuing, you agree to our\n',
                style: const TextStyle(fontSize: 11, color: Color(0xFFB0BAC9), height: 1.7),
                children: [
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: GestureDetector(
                      onTap: () => launchUrl(Uri.parse('https://devgruha.com/terms'),
                          mode: LaunchMode.externalApplication),
                      child: const Text(
                        'Terms of Service',
                        style: TextStyle(
                          fontSize: 11, color: Color(0xFF64748B),
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                          decorationColor: Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ),
                  const TextSpan(text: '  and  '),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: GestureDetector(
                      onTap: () => launchUrl(Uri.parse('https://devgruha.com/privacy'),
                          mode: LaunchMode.externalApplication),
                      child: const Text(
                        'Privacy Policy',
                        style: TextStyle(
                          fontSize: 11, color: Color(0xFF64748B),
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                          decorationColor: Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 640.ms, duration: 400.ms),

            const Gap(32),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  PHONE INPUT WIDGET
// ─────────────────────────────────────────────────────────────────────────────
class _PhoneInput extends StatelessWidget {
  final TextEditingController controller;
  const _PhoneInput({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.phone,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(10),
      ],
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: 2.5,
        color: Color(0xFF1E293B),
      ),
      decoration: InputDecoration(
        hintText: '00000 00000',
        hintStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w400,
          letterSpacing: 2,
          color: Color(0xFFCBD5E1),
        ),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 16, right: 0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🇮🇳', style: TextStyle(fontSize: 20)),
              const Gap(8),
              const Text(
                '+91',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: Color(0xFF374151),
                ),
              ),
              const Gap(10),
              Container(width: 1.5, height: 22, color: const Color(0xFFE2E8F0)),
              const Gap(8),
            ],
          ),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _navyMid, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.error),
        ),
      ),
      validator: (v) {
        if (v == null || v.isEmpty) return 'Please enter your mobile number';
        if (v.length != 10) return 'Enter a valid 10-digit number';
        return null;
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  SEND OTP BUTTON
// ─────────────────────────────────────────────────────────────────────────────
class _SendOtpButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onTap;

  const _SendOtpButton({required this.isLoading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 60,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isLoading
                ? [const Color(0xFF6B7DB3), const Color(0xFF4A5C8E)]
                : [_navyMid, _navyDark],
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: _navyMid.withValues(alpha: 0.35),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text(
                  'SEND OTP',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2.5,
                  ),
                ),
        ),
      ),
    );
  }
}
