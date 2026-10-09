import 'package:flutter/foundation.dart';
import '../config/app_config.dart';

class Logger {
  static void log(String message, {String? tag}) {
    if (kDebugMode && AppConfig.enableApiLogging) {
      final tagStr = tag != null ? '[$tag] ' : '';
      debugPrint('$tagStr$message');
    }
  }

  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      debugPrint('[ERROR] $message');
      if (error != null) debugPrint('Error details: $error');
      if (stackTrace != null) debugPrint('StackTrace: $stackTrace');
    }
  }

  static void info(String message) {
    log(message, tag: 'INFO');
  }

  static void api(String method, String url, {int? statusCode}) {
    log('$method $url ${statusCode != null ? '($statusCode)' : ''}', tag: 'API');
  }
}
