/// Values passed at build time with --dart-define-from-file=env.json
abstract final class Env {
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  static const isConfigured = supabaseUrl != '' && supabaseKey != '';
}
