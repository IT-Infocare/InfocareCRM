import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String get appName => dotenv.env['APP_NAME'] ?? 'InfocareCRM';
  static String get appEnv => dotenv.env['APP_ENV'] ?? 'development';
  static String get apiBaseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://localhost:3000/api';
  static int get apiTimeoutSeconds =>
      int.tryParse(dotenv.env['API_TIMEOUT_SECONDS'] ?? '30') ?? 30;

  static String get supabaseUrl =>
      dotenv.env['SUPABASE_URL'] ?? 'https://hqijrtdyvtaclifrbuuc.supabase.co';
  static String get supabasePublishableKey =>
      dotenv.env['SUPABASE_PUBLISHABLE_KEY'] ??
      'sb_publishable_PLLzTvDBomit6CvtkO-EiA_KQZxKtD4';

  static String get defaultCurrency => dotenv.env['DEFAULT_CURRENCY'] ?? 'AED';
  static double get defaultVatPercent =>
      double.tryParse(dotenv.env['DEFAULT_VAT_PERCENT'] ?? '5') ?? 5.0;
  static String get defaultBranch => dotenv.env['DEFAULT_BRANCH'] ?? 'Dubai';

  static List<String> get supportedBranches {
    final raw = dotenv.env['SUPPORTED_BRANCHES'] ?? 'Dubai,RAK,Kerala';
    return raw.split(',').map((e) => e.trim()).toList();
  }

  static bool get enableApiLogging =>
      (dotenv.env['ENABLE_API_LOGGING'] ?? 'true').toLowerCase() == 'true';
  static bool get enableMockData =>
      (dotenv.env['ENABLE_MOCK_DATA'] ?? 'true').toLowerCase() == 'true';
}
