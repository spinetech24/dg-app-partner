import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../providers/auth_providers.dart';

// ─── Brand colors matching Stitch / login_page.dart ──────────────────────────
const Color _navyDark = Color(0xFF00114A);
const Color _navyMid = Color(0xFF0A2472);
const Color _white70 = Color(0xB3FFFFFF);
const Color _white55 = Color(0x8CFFFFFF);

class OtpPage extends ConsumerStatefulWidget {
  final String phoneNumber;

  const OtpPage({super.key, required this.phoneNumber});

  @override
  ConsumerState<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends ConsumerState<OtpPage> {
  final _pinController = TextEditingController();
  bool _isVerifying = false;
  int _resendSeconds = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  void _startResendTimer() {
    _timer?.cancel();
    setState(() => _resendSeconds = 30);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_resendSeconds == 0) {
        t.cancel();
      } else {
        setState(() => _resendSeconds--);
      }
    });
  }

  @override
  void dispose() {
    _pinController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _verify(String pin) async {
    if (pin.length < 6) return;
    setState(() => _isVerifying = true);

    final success = await ref.read(otpProvider.notifier).verifyOtp(pin);

    if (!mounted) return;
    setState(() => _isVerifying = false);

    if (success) {
      context.go(AppConstants.dashboardRoute);
    } else {
      final error = ref.read(otpProvider).errorMessage ?? 'Invalid OTP';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      _pinController.clear();
    }
  }

  Future<void> _resendOtp() async {
    if (_resendSeconds > 0) return;
    await ref.read(otpProvider.notifier).sendOtp(widget.phoneNumber);
    _startResendTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F5),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ─── Compact Navy Header ──────────────────────────────
            _OtpHeader(phoneNumber: widget.phoneNumber),

            // ─── Floating OTP Card ────────────────────────────────
            Transform.translate(
              offset: const Offset(0, -40),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 40,
                            offset: const Offset(0, 16),
                          ),
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Title
                          const Text(
                            'Verify Your Number',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                              letterSpacing: -0.5,
                            ),
                          )
                              .animate()
                              .fadeIn(delay: 100.ms, duration: 400.ms),

                          const Gap(8),

                          // Subtitle
                          Text(
                            'We sent a 6-digit code to\n${widget.phoneNumber}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF64748B),
                              height: 1.5,
                            ),
                          )
                              .animate()
                              .fadeIn(delay: 160.ms, duration: 400.ms),

                          const Gap(32),

                          // ─── OTP Label ───────────────────────────────
                          const Text(
                            'ENTER OTP',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                              color: Color(0xFF94A3B8),
                            ),
                          )
                              .animate()
                              .fadeIn(delay: 200.ms, duration: 400.ms),

                          const Gap(12),

                          // ─── PIN Input ───────────────────────────────
                          _OtpPinInput(
                            controller: _pinController,
                            onCompleted: _verify,
                          )
                              .animate()
                              .fadeIn(delay: 260.ms, duration: 400.ms)
                              .slideY(begin: 0.15, end: 0),

                          const Gap(28),

                          // ─── Verify Button ───────────────────────────
                          _VerifyButton(
                            isLoading: _isVerifying,
                            onTap: () => _verify(_pinController.text),
                          )
                              .animate()
                              .fadeIn(delay: 320.ms, duration: 400.ms),

                          const Gap(20),

                          // ─── Resend ──────────────────────────────────
                          GestureDetector(
                            onTap: _resendSeconds == 0 ? _resendOtp : null,
                            child: Center(
                              child: RichText(
                                text: TextSpan(
                                  text: "Didn't receive the OTP? ",
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF94A3B8),
                                  ),
                                  children: [
                                    TextSpan(
                                      text: _resendSeconds > 0
                                          ? 'Resend in ${_resendSeconds}s'
                                          : 'Resend OTP',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: _resendSeconds > 0
                                            ? const Color(0xFFCBD5E1)
                                            : _navyMid,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                              .animate()
                              .fadeIn(delay: 380.ms, duration: 400.ms),
                        ],
                      ),
                    ),

                    const Gap(20),

                    // ─── Change number link ───────────────────────────
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: const Text(
                        '← Change number',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF94A3B8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ).animate().fadeIn(delay: 440.ms, duration: 400.ms),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  COMPACT NAVY HEADER (mirrors Hero but lighter / shorter)
// ─────────────────────────────────────────────────────────────────────────────
class _OtpHeader extends StatelessWidget {
  final String phoneNumber;
  const _OtpHeader({required this.phoneNumber});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 20,
        bottom: 72,
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
            top: -24, right: -24,
            child: Container(
              width: 160, height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _navyMid.withValues(alpha: 0.5),
              ),
            ),
          ),

          Column(
            children: [
              // Back button row
              Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 38, height: 38,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                      child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'DEVGRUHA',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 4,
                        color: _white70,
                      ),
                    ),
                  ),
                  const SizedBox(width: 38), // balance
                ],
              ),

              const Gap(24),

              // SMS icon ring
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.12),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 2),
                ),
                child: const Icon(Icons.sms_rounded, size: 36, color: Colors.white),
              )
                  .animate()
                  .fadeIn(duration: 500.ms)
                  .scale(begin: const Offset(0.8, 0.8), curve: Curves.easeOutBack),

              const Gap(16),

              const Text(
                'Saathi',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -1,
                ),
              )
                  .animate()
                  .fadeIn(delay: 200.ms, duration: 400.ms),

              const Gap(6),

              const Text(
                'OTP Verification',
                style: TextStyle(fontSize: 14, color: _white55),
              )
                  .animate()
                  .fadeIn(delay: 280.ms, duration: 400.ms),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  OTP PIN INPUT (6 boxes with navy focus)
// ─────────────────────────────────────────────────────────────────────────────
class _OtpPinInput extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onCompleted;

  const _OtpPinInput({required this.controller, required this.onCompleted});

  @override
  Widget build(BuildContext context) {
    final defaultTheme = PinTheme(
      width: 48,
      height: 56,
      textStyle: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Color(0xFF0F172A),
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
    );

    final focusedTheme = defaultTheme.copyWith(
      decoration: defaultTheme.decoration!.copyWith(
        border: Border.all(color: _navyMid, width: 2),
        boxShadow: [
          BoxShadow(
            color: _navyMid.withValues(alpha: 0.15),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
    );

    final filledTheme = defaultTheme.copyWith(
      decoration: defaultTheme.decoration!.copyWith(
        color: _navyMid.withValues(alpha: 0.06),
        border: Border.all(color: _navyMid.withValues(alpha: 0.3), width: 1.5),
      ),
    );

    return Pinput(
      controller: controller,
      length: 6,
      defaultPinTheme: defaultTheme,
      focusedPinTheme: focusedTheme,
      submittedPinTheme: filledTheme,
      onCompleted: onCompleted,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  VERIFY BUTTON
// ─────────────────────────────────────────────────────────────────────────────
class _VerifyButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onTap;

  const _VerifyButton({required this.isLoading, required this.onTap});

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
                  'VERIFY OTP',
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
