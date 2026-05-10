import 'package:notification/data/datasources/local_data_source.dart';
import 'package:notification/data/datasources/remote_data_source.dart';
import 'package:notification/data/models/sync_task.dart';

class SyncQueueUseCase {
  final NotificationLocalDataSource _local;
  final NotificationRemoteDataSource _remote;

  SyncQueueUseCase({
    required NotificationLocalDataSource local,
    required NotificationRemoteDataSource remote,
  }) : _local = local,
       _remote = remote;

  Future<void> execute() async {
    final tasks = _local.getSyncQueue();
    if (tasks.isEmpty) return;

    for (final task in tasks) {
      if (task.hasExceededRetries) {
        await _local.removeSyncTask(task.taskId);
        continue;
      }

      try {
        await _executeTask(task);
        await _local.removeSyncTask(task.taskId);
      } catch (e, st) {
        await _local.incrementSyncRetry(task.taskId);
      }
    }
  }

  Future<void> _executeTask(SyncTask task) async {
    final payload = task.decodedPayload;

    switch (task.action) {
      case 'mark_read':
        final id = payload['notification_id'] as String;
        await _remote.markAsRead(id);

      case 'mark_all_read':
        await _remote.markAllAsRead();

      default:
    }
  }
}
