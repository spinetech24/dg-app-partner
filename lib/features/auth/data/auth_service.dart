import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constants/app_constants.dart';

class AuthService {
  final SupabaseClient _client;

  AuthService(this._client);

  // ─── Phone / OTP ──────────────────────────────────────────────────────────

  Future<void> sendOtp(String phoneNumber) async {
    await _client.auth.signInWithOtp(
      phone: phoneNumber,
    );
  }

  Future<AuthResponse> verifyOtp({
    required String phoneNumber,
    required String token,
  }) async {
    return await _client.auth.verifyOTP(
      phone: phoneNumber,
      token: token,
      type: OtpType.sms,
    );
  }

  // ─── Google Sign-In (Native) ──────────────────────────────────────────────

  Future<AuthResponse?> signInWithGoogle() async {
    // For Android, we only need the serverClientId (Web Client ID) to get the idToken for Supabase.
    // Specifying an Android clientId often leads to ApiException 10 if there are SHA-1 mismatches.
    final GoogleSignIn googleSignIn = GoogleSignIn(
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
