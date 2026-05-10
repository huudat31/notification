abstract class ApiConstants {
  static const String notificationBaseUrl = 'http://172.16.88.92:8088';

  static const int connectTimeout = 15000;
  static const int receiveTimeout = 15000;
  static const int sendTimeout = 15000;

  static const String apiVersion = 'v1';

  static const int defaultPageLimit = 20;
  static const int maxCacheItems = 50;

  static const int notificationPageSize = 10;

  static const String loginWithGoogle = '/api/auth/google';
  static const String authLogin = '/api/auth/login';
  static const String authRegister = '/api/auth/register';

  static const String refreshToken = '/auth/refresh';

  static const String notificationGetAll = '/api/notification/me';

  static const String notificationGetPaged = '/api/notification/me';

  static const String notificationGetUnread = '/api/notification/user/unread';

  static const String notificationUnreadCount =
      '/api/notification/user/unread-count';

  static const String notificationMarkRead = '/api/notification/{id}/read';

  static const String notificationMarkAllRead = '/api/notification/read-all';

  static const String notificationUpdateSetting = '/api/preferences/setting';
  static const String notificationLogout = '/api/auth/device/logout';

  static const String channelEmail = 'email';
  static const String channelPush = 'push';
  static const String channelSms = 'sms';

  static const String notificationGetRead = '/api/notification/user/read';

  static const String notificationDelete = '/api/notification/delete/{id}';

  static String buildGetAllUrl() => '$notificationBaseUrl$notificationGetAll';

  static String buildGetReadUrl() => '$notificationBaseUrl$notificationGetRead';

  static String buildDeleteUrl(String id) =>
      '$notificationBaseUrl/api/notification/delete/$id';

  static String buildGetPagedUrl(int page) =>
      '$notificationBaseUrl$notificationGetPaged?page=$page&size=$notificationPageSize';

  static String buildMarkReadUrl(String id) =>
      '$notificationBaseUrl/api/notification/$id/read';

  static String buildUnreadCountUrl() =>
      '$notificationBaseUrl$notificationUnreadCount';

  static String buildLogoutUrl() => '$notificationBaseUrl$notificationLogout';
}
