import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constants/app_constants.dart';

class AuthService {
  final SupabaseClient _client;

  AuthService(this._client);

  // ─── Phone / OTP ──────────────────────────────────────────────────────────

  Future<void> sendOtp(String phoneNumber) async {
    final response = await _client.functions.invoke(
      'request-mobile-otp',
      body: {'mobile_number': phoneNumber},
    );
    if (response.status != 200) {
      final message = response.data?['error'] ?? 'Failed to send OTP';
      throw Exception(message);
    }
  }

  Future<AuthResponse> verifyOtp({
    required String phoneNumber,
    required String token,
  }) async {
    final response = await _client.functions.invoke(
      'verify-mobile-otp',
      body: {
        'mobile_number': phoneNumber,
        'otp': token,
      },
    );

    // Debug — remove after fixing
    print('🔍 verify-mobile-otp status: ${response.status}');
    print('🔍 verify-mobile-otp data: ${response.data}');

    if (response.status != 200) {
      final message = response.data?['error'] ?? 'Invalid OTP';
      throw Exception(message);
    }
    final data = response.data as Map<String, dynamic>;
    final accessToken = data['access_token'] as String?;
    final refreshToken = data['refresh_token'] as String?;

    print('🔍 access_token: $accessToken');
    print('🔍 refresh_token: $refreshToken');

    if (accessToken == null || refreshToken == null) {
      throw Exception('Session tokens missing from server response');
    }

    return _client.auth.setSession(refreshToken);
  }

  // ─── Google Sign-In (Native) ──────────────────────────────────────────────

  Future<AuthResponse?> signInWithGoogle() async {
    final GoogleSignIn googleSignIn = GoogleSignIn(
      clientId: AppConstants.googleAndroidClientId,
      serverClientId: AppConstants.googleWebClientId,
    );

    final googleUser = await googleSignIn.signIn();
    if (googleUser == null) return null; // user cancelled

    final googleAuth = await googleUser.authentication;
    final idToken = googleAuth.idToken;
    final accessToken = googleAuth.accessToken;

    if (idToken == null) throw Exception('No ID token received from Google');

    return _client.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: accessToken,
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
