import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static const String appName = String.fromEnvironment('APP_NAME', defaultValue: 'InfocareCRM');
  static const String appEnv = String.fromEnvironment('APP_ENV', defaultValue: 'production');
  static String get apiBaseUrl {
    String url = '';
    const fromEnv = String.fromEnvironment('API_BASE_URL');
    if (fromEnv.isNotEmpty) {
      url = fromEnv.trim();
    } else {
      try {
        if (dotenv.isInitialized) {
          final envVal = dotenv.maybeGet('API_BASE_URL');
          if (envVal != null && envVal.trim().isNotEmpty) {
            url = envVal.trim();
          }
        }
      } catch (_) {}
    }
    if (url.isEmpty) {
      url = 'https://infocarecrm.onrender.com/api';
    }
    if (url.endsWith('/')) {
      url = url.substring(0, url.length - 1);
    }
    if (!url.endsWith('/api')) {
      url = '$url/api';
    }
    return url;
  }
  static const int apiTimeoutSeconds = int.fromEnvironment('API_TIMEOUT_SECONDS', defaultValue: 30);

  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://hqijrtdyvtaclifrbuuc.supabase.co',
  );
  static const String supabasePublishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
    defaultValue: 'sb_publishable_PLLzTvDBomit6CvtkO-EiA_KQZxKtD4',
  );

  static const String defaultCurrency = String.fromEnvironment('DEFAULT_CURRENCY', defaultValue: 'AED');
  static const double defaultVatPercent = 5.0;
  static const String defaultBranch = String.fromEnvironment('DEFAULT_BRANCH', defaultValue: 'Dubai');

  static List<String> get supportedBranches {
    const raw = String.fromEnvironment('SUPPORTED_BRANCHES', defaultValue: 'Dubai,RAK,Sharjah');
    return raw.split(',').map((e) => e.trim()).toList();
  }

  static const bool enableApiLogging = bool.fromEnvironment('ENABLE_API_LOGGING', defaultValue: true);
  static const bool enableMockData = bool.fromEnvironment('ENABLE_MOCK_DATA', defaultValue: false);
}
