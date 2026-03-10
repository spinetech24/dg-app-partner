import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _client;

  AuthService(this._client);

  // ─── Phone / OTP ──────────────────────────────────────────────────────────

  Future<void> sendOtp(String phoneNumber) async {
    await _client.auth.signInWithOtp(phone: phoneNumber);
  }

  Future<AuthResponse> verifyOtp({
    required String phoneNumber,
    required String token,
  }) async {
    return _client.auth.verifyOTP(
      phone: phoneNumber,
      token: token,
      type: OtpType.sms,
    );
  }

  // ─── Google Sign-In ───────────────────────────────────────────────────────

  Future<bool> signInWithGoogle() async {
    return _client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'com.devgruha.partner://login-callback/',
    );
  }

  // ─── Apple Sign-In ────────────────────────────────────────────────────────

  Future<bool> signInWithApple() async {
    return _client.auth.signInWithOAuth(
      OAuthProvider.apple,
      redirectTo: 'com.devgruha.partner://login-callback/',
    );
  }

  // ─── Session ──────────────────────────────────────────────────────────────

  Session? get currentSession => _client.auth.currentSession;

  User? get currentUser => _client.auth.currentUser;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}
