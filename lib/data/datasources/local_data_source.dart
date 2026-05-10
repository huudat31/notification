import '../../services/hive_service.dart';
import '../models/notification_model.dart';
import '../models/sync_task.dart';

abstract class NotificationLocalDataSource {
  List<NotificationModel> getNotifications();
  Future<void> saveNotifications(List<NotificationModel> items);
  Future<void> updateReadStatus(String id);
  Future<void> deleteNotification(String id);
  Future<void> clearAll();

  // Sync queue
  Future<void> addToSyncQueue(SyncTask task);
  List<SyncTask> getSyncQueue();
  Future<void> removeSyncTask(String taskId);
  Future<void> incrementSyncRetry(String taskId);
}

class NotificationLocalDataSourceImpl implements NotificationLocalDataSource {
  @override
  List<NotificationModel> getNotifications() {
    final items = HiveService.getAllNotifications();

    return items;
  }

  @override
  Future<void> saveNotifications(List<NotificationModel> items) async {
    await HiveService.saveNotifications(items);
  }

  @override
  Future<void> updateReadStatus(String id) async {
    await HiveService.markNotificationAsRead(id);
  }

  @override
  Future<void> deleteNotification(String id) async {
    await HiveService.deleteNotification(id);
  }

  @override
  Future<void> clearAll() async {
    await HiveService.clearNotifications();
  }

  @override
  Future<void> addToSyncQueue(SyncTask task) async {
    await HiveService.addSyncTask(task);
  }

  @override
  List<SyncTask> getSyncQueue() {
    return HiveService.getPendingSyncTasks();
  }

  @override
  Future<void> removeSyncTask(String taskId) async {
    await HiveService.deleteSyncTask(taskId);
  }

  @override
  Future<void> incrementSyncRetry(String taskId) async {
    await HiveService.incrementSyncTaskRetry(taskId);
  }
}
