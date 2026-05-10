abstract class AppConstants {
  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String settingsKey = 'user_settings';
  static const String socketEvent = 'new_notification';
  static const int maxSyncRetries = 3;
  static const double loadMoreThreshold = 250.0;
  static const int heartbeatIntervalSec = 30;
}
