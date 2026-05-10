import 'dart:convert';
import 'package:hive/hive.dart';
import '../../core/constants/hive_constants.dart';
import '../../core/constants/app_constants.dart';

part 'sync_task.g.dart';

@HiveType(typeId: HiveTypeIds.syncTask)
class SyncTask extends HiveObject {
  @HiveField(0)
  late String taskId;
  @HiveField(1)
  late String action;
  @HiveField(2)
  late String payload;
  @HiveField(3)
  late DateTime createdAt;
  @HiveField(4)
  late int retryCount;

  SyncTask();

  factory SyncTask.markRead(String notificationId) {
    return SyncTask()
      ..taskId = _generateId()
      ..action = 'mark_read'
      ..payload = jsonEncode({'notification_id': notificationId})
      ..createdAt = DateTime.now()
      ..retryCount = 0;
  }

  factory SyncTask.markAllRead() {
    return SyncTask()
      ..taskId = _generateId()
      ..action = 'mark_all_read'
      ..payload = jsonEncode({})
      ..createdAt = DateTime.now()
      ..retryCount = 0;
  }

  factory SyncTask.delete(String notificationId) {
    return SyncTask()
      ..taskId = _generateId()
      ..action = 'delete'
      ..payload = jsonEncode({'notification_id': notificationId})
      ..createdAt = DateTime.now()
      ..retryCount = 0;
  }

  Map<String, dynamic> get decodedPayload =>
      jsonDecode(payload) as Map<String, dynamic>;

  bool get hasExceededRetries => retryCount >= AppConstants.maxSyncRetries;

  static String _generateId() =>
      '${DateTime.now().millisecondsSinceEpoch}_${Object().hashCode}';

  @override
  String toString() =>
      'SyncTask(taskId: $taskId, action: $action, retryCount: $retryCount)';
}
