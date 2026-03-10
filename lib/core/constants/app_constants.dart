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

  // Phone
  static const String defaultCountryCode = '+91';

  // Routes
  static const String splashRoute = '/';
  static const String loginRoute = '/login';
  static const String otpRoute = '/otp';
  static const String dashboardRoute = '/dashboard';
  static const String registerRoute = '/register';
}
