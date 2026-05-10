import 'package:hive_flutter/hive_flutter.dart';
import 'package:notification/data/models/notification_model.dart';
import 'package:notification/data/models/sync_task.dart';
import '../core/constants/api_constants.dart';
import '../core/constants/hive_constants.dart';

class HiveService {
  HiveService._();

  static const _schemaVersion = 1;

  static late Box<NotificationModel> _notifBox;
  static late Box<SyncTask> _syncBox;
  static late Box<dynamic> _metaBox;

  static Future<void> openBoxes() async {
    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(HiveTypeIds.notificationModel)) {
      Hive.registerAdapter(NotificationModelAdapter());
    }
    if (!Hive.isAdapterRegistered(HiveTypeIds.syncTask)) {
      Hive.registerAdapter(SyncTaskAdapter());
    }

    await _runMigrations();

    _notifBox = await Hive.openBox<NotificationModel>(HiveBoxes.notifications);
    _syncBox = await Hive.openBox<SyncTask>(HiveBoxes.syncQueue);
  }

  static Future<void> closeAll() async {
    await Hive.close();
  }

  static List<NotificationModel> getAllNotifications() {
    final list = _notifBox.values.toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  static Future<void> saveNotifications(List<NotificationModel> items) async {
    final map = {for (final n in items) n.id: n};
    await _notifBox.putAll(map);
    await _trimToLimit();
  }

  static Future<void> markNotificationAsRead(String id) async {
    final item = _notifBox.get(id);
    if (item != null) {
      item.status = 'read';
      item.read = true;
      await item.save();
    }
  }

  static Future<void> deleteNotification(String id) async {
    await _notifBox.delete(id);
  }

  static Future<void> clearNotifications() async {
    await _notifBox.clear();
  }

  static Future<void> _trimToLimit() async {
    if (_notifBox.length <= ApiConstants.maxCacheItems) return;

    final sorted = getAllNotifications();
    final toDelete = sorted
        .skip(ApiConstants.maxCacheItems)
        .map((n) => n.id)
        .toList();

    await _notifBox.deleteAll(toDelete);
  }

  static Future<void> addSyncTask(SyncTask task) async {
    await _syncBox.put(task.taskId, task);
  }

  static List<SyncTask> getPendingSyncTasks() {
    return _syncBox.values.toList();
  }

  static Future<void> deleteSyncTask(String taskId) async {
    await _syncBox.delete(taskId);
  }

  static Future<void> incrementSyncTaskRetry(String taskId) async {
    final task = _syncBox.get(taskId);
    if (task != null) {
      task.retryCount++;
      await task.save();
    }
  }

  static bool get hasPendingSyncTasks => _syncBox.isNotEmpty;

  static Future<void> _runMigrations() async {
    _metaBox = await Hive.openBox<dynamic>(HiveBoxes.metadata);
    final currentVersion =
        _metaBox.get('schema_version', defaultValue: 0) as int;

    if (currentVersion < 1) {
      await Hive.deleteBoxFromDisk(HiveBoxes.notifications);
    }

    if (currentVersion < _schemaVersion) {
      await _metaBox.put('schema_version', _schemaVersion);
    }
  }
}
