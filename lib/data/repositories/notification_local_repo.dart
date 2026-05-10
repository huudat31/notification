import '../models/notification_model.dart';
import '../datasources/remote_data_source.dart';

abstract class NotificationLocalRepo {
  Future<NotificationPage> getNotifications({String? cursor, int limit});
  Future<NotificationPage> getUnreadNotifications({String? cursor, int limit});
  Future<NotificationPage> getFilteredNotifications({
    bool? read,
    String? channel,
    String? cursor,
    int limit,
  });
  Future<void> markAsRead(String id);
  Future<void> markAllAsRead();
  Future<void> updateSetting({
    required String channel,
    required bool isEnabled,
  });
  Future<Map<String, dynamic>> getSettings();
  List<NotificationModel> getCached();
}
