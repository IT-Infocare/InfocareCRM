import 'package:flutter/foundation.dart';

class AppConfig {
  static const String appName = String.fromEnvironment('APP_NAME', defaultValue: 'InfocareCRM');
  static const String appEnv = String.fromEnvironment('APP_ENV', defaultValue: 'production');
  static String get apiBaseUrl {
    const fromEnv = String.fromEnvironment('API_BASE_URL');
    if (fromEnv.isNotEmpty) return fromEnv;
    if (kIsWeb) {
      final host = Uri.base.host;
      if (host == 'localhost' || host == '127.0.0.1') {
        return 'http://localhost:3000/api';
      }
    }
    return 'https://infocarecrm.onrender.com/api';
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
