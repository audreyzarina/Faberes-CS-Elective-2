/// App-wide constants.
///
/// Fill in your Supabase project values here, or pass them at run time:
/// flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
class AppConfig {
  AppConfig._();

  static const String appName = 'Brew & Leaf';

  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://syivfbvwiosvnfyobxoe.supabase.co',
  );
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'sb_publishable_2CRop3l1FaxvPHny0xLxFw_npSvzQN5',
  );

  /// Deep link used by Google sign-in and email confirmation.
  /// Must be added to Supabase > Authentication > URL Configuration > Redirect URLs
  /// and to the Android/iOS platform config (see README).
  static const String authRedirect = 'io.supabase.brewleaf://login-callback/';

  static const String productBucket = 'product-images';

  /// Products per page (activity requirement: 6-8).
  static const int pageSize = 6;

  static const int maxStock = 32767; // products.stock is int2
}
