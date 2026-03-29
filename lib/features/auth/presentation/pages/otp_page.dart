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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final defaultPinTheme = PinTheme(
      width: 52,
      height: 60,
      textStyle: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: AppColors.navyBlue, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.navyBlue.withOpacity(0.15),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Gap(32),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.navyBlue.withOpacity(0.10),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.sms_rounded,
                  size: 40,
                  color: AppColors.navyBlue,
                ),
              )
                  .animate()
                  .fadeIn(duration: 400.ms)
                  .scale(begin: const Offset(0.8, 0.8)),

              const Gap(24),

              Text(
                'Verify Your Number',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              )
                  .animate()
                  .fadeIn(delay: 100.ms, duration: 400.ms),

              const Gap(8),

              Text(
                'We sent a 6-digit OTP to\n${widget.phoneNumber}',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                      height: 1.5,
                    ),
              )
                  .animate()
                  .fadeIn(delay: 150.ms, duration: 400.ms),

              const Gap(36),

              Pinput(
                controller: _pinController,
                length: 6,
                defaultPinTheme: defaultPinTheme,
                focusedPinTheme: focusedPinTheme,
                onCompleted: _verify,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              )
                  .animate()
                  .fadeIn(delay: 200.ms, duration: 400.ms)
                  .slideY(begin: 0.2, end: 0),

              const Gap(32),

              if (_isVerifying)
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(AppColors.navyBlue),
                )
              else
                ElevatedButton(
                  onPressed: () => _verify(_pinController.text),
                  child: const Text('Verify OTP'),
                ),

              const Gap(24),

              GestureDetector(
                onTap: _resendSeconds == 0 ? _resendOtp : null,
                child: RichText(
                  text: TextSpan(
                    text: "Didn't receive the OTP? ",
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                    children: [
                      TextSpan(
                        text: _resendSeconds > 0
                            ? 'Resend in ${_resendSeconds}s'
                            : 'Resend OTP',
                        style: TextStyle(
                          color: _resendSeconds > 0
                              ? (isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight)
                              : AppColors.navyBlue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              )
                  .animate()
                  .fadeIn(delay: 300.ms, duration: 400.ms),
            ],
          ),
        ),
      ),
    );
  }
}
