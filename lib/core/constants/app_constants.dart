import 'package:flutter/foundation.dart';

class AppConstants {
  AppConstants._();

  // App
  static const String appName = 'DevGruha Partner';
  static const String appVersion = '1.0.0';

  // Supabase — fill these in from .env / your Supabase project settings
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://auth.devgruha.com',
  );
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImlvbWhybHVuYWt6YmRhdGF1dnpiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQ2NzIwODEsImV4cCI6MjA3MDI0ODA4MX0.uHbRx7RQa86xGa77Byyug8rdvKa5FymhfmzDY_sGtQs',
  );

  // Assets
  static const String loginHeroImage = 'assets/images/login_hero.png';
  static const String googleLogoImage = 'assets/images/google_logo.png';
  static const String dgLogoImage = 'assets/images/dg_logo.png';

  // Phone
  static const String defaultCountryCode = '+91';

  // Google OAuth — Web Client ID (same for both debug & release)
  static const String googleWebClientId =
      '199478054991-uq7c9rh0e14qmg64mbo3ilg2qogls2kv.apps.googleusercontent.com';

  // Android Client ID — switches based on build mode
  // Debug uses debug keystore SHA-1, Release uses production keystore SHA-1
  static const String _googleAndroidClientIdDebug =
      '199478054991-do11s6u18feosjshtr479f1s6i0avrri.apps.googleusercontent.com'; // ← paste debug client ID here
  static const String _googleAndroidClientIdRelease =
      '199478054991-shntj6t9ae36eg28ca5pqfvlmnslhj9u.apps.googleusercontent.com';

  static String get googleAndroidClientId =>
      kDebugMode ? _googleAndroidClientIdDebug : _googleAndroidClientIdRelease;

  // Routes
  static const String splashRoute = '/';
  static const String loginRoute = '/login';
  static const String otpRoute = '/otp';
  static const String dashboardRoute = '/dashboard';
  static const String registerRoute = '/register';
  static const String settingsRoute = '/settings';
}
