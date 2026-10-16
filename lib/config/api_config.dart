import 'package:flutter/foundation.dart';

/// All API settings live here so the base URL is not repeated around the app.
///
/// You can override the base URL when running the app, for example on a
/// physical device:
/// flutter run --dart-define=API_BASE_URL=http://192.168.1.10:3001
class ApiConfig {
  ApiConfig._();

  static const String _baseUrlFromEnv = String.fromEnvironment('API_BASE_URL');

  static const String androidEmulatorBaseUrl = 'http://10.0.2.2:3001';
  static const String localhostBaseUrl = 'http://localhost:3001';

  static const String customersPath = '/customers';

  static const Duration requestTimeout = Duration(seconds: 10);

  static String get baseUrl {
    if (_baseUrlFromEnv.isNotEmpty) {
      return _baseUrlFromEnv;
    }
    // Android emulator can not reach the host machine using localhost.
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return androidEmulatorBaseUrl;
    }
    return localhostBaseUrl;
  }
}
