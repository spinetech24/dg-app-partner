import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/auth_service.dart';

// ─── Service Provider ─────────────────────────────────────────────────────────

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(Supabase.instance.client);
});

// ─── Auth State ───────────────────────────────────────────────────────────────

final authStateProvider = StreamProvider<AuthState>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (state) => state.session?.user,
    loading: () => Supabase.instance.client.auth.currentUser,
    error: (_, __) => null,
  );
});

// ─── OTP State Notifier ───────────────────────────────────────────────────────

enum OtpStatus { idle, sendingOtp, otpSent, verifying, success, error }

class OtpNotifierState {
  final OtpStatus status;
  final String? errorMessage;
  final String? phoneNumber;

  const OtpNotifierState({
    this.status = OtpStatus.idle,
    this.errorMessage,
    this.phoneNumber,
  });

  OtpNotifierState copyWith({
    OtpStatus? status,
    String? errorMessage,
    String? phoneNumber,
  }) {
    return OtpNotifierState(
      status: status ?? this.status,
      errorMessage: errorMessage,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }
}

class OtpNotifier extends StateNotifier<OtpNotifierState> {
  final AuthService _authService;

  OtpNotifier(this._authService) : super(const OtpNotifierState());

  Future<bool> sendOtp(String phoneNumber) async {
    state = state.copyWith(status: OtpStatus.sendingOtp, phoneNumber: phoneNumber);
    try {
      await _authService.sendOtp(phoneNumber);
      state = state.copyWith(status: OtpStatus.otpSent);
      return true;
    } catch (e) {
      state = state.copyWith(
        status: OtpStatus.error,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  Future<bool> verifyOtp(String token) async {
    if (state.phoneNumber == null) return false;
    state = state.copyWith(status: OtpStatus.verifying);
    try {
      await _authService.verifyOtp(
        phoneNumber: state.phoneNumber!,
        token: token,
      );
      state = state.copyWith(status: OtpStatus.success);
      return true;
    } catch (e) {
      state = state.copyWith(
        status: OtpStatus.error,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  void reset() => state = const OtpNotifierState();
}

final otpProvider = StateNotifierProvider<OtpNotifier, OtpNotifierState>((ref) {
  return OtpNotifier(ref.watch(authServiceProvider));
});
