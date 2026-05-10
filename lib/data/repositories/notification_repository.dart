import '../../core/constants/api_constants.dart';

import '../../services/connectivity_service.dart';
import '../datasources/local_data_source.dart';
import '../datasources/remote_data_source.dart';
import '../models/notification_model.dart';
import '../models/sync_task.dart';
import 'notification_local_repo.dart';
import 'package:get_storage/get_storage.dart';

class NotificationRepository implements NotificationLocalRepo {
  final NotificationRemoteDataSource _remote;
  final NotificationLocalDataSource _local;
  final ConnectivityService _connectivity;

  NotificationRepository({
    required NotificationRemoteDataSource remote,
    required NotificationLocalDataSource local,
    required ConnectivityService connectivity,
  }) : _remote = remote,
       _local = local,
       _connectivity = connectivity;

  @override
  Future<NotificationPage> getNotifications({
    String? cursor,
    int limit = ApiConstants.defaultPageLimit,
  }) async {
    if (!_connectivity.isOnline) {
      return _buildPageFromCache();
    }

    try {
      final page = await _remote.getNotifications(cursor: cursor, limit: limit);
      await _local.saveNotifications(page.items);
      return page;
    } on Exception catch (e) {
      final cached = _local.getNotifications();
      if (cached.isEmpty) rethrow;

      return NotificationPage(items: cached, nextCursor: null, hasMore: false);
    }
  }

  Future<NotificationPage> getUnreadNotifications({
    String? cursor,
    int limit = ApiConstants.defaultPageLimit,
  }) async {
    if (!_connectivity.isOnline) {
      final cached = _local
          .getNotifications()
          .where((n) => n.isUnread)
          .toList();
      return NotificationPage(items: cached, nextCursor: null, hasMore: false);
    }

    try {
      final page = await _remote.getUnreadNotifications(
        cursor: cursor,
        limit: limit,
      );
      await _local.saveNotifications(page.items);
      return page;
    } on Exception catch (e) {
      rethrow;
    }
  }

  Future<NotificationPage> getReadNotifications({
    String? cursor,
    int limit = ApiConstants.defaultPageLimit,
  }) async {
    if (!_connectivity.isOnline) {
      final cached = _local.getNotifications().where((n) => n.read).toList();
      return NotificationPage(items: cached, nextCursor: null, hasMore: false);
    }

    try {
      final page = await _remote.getReadNotifications(
        cursor: cursor,
        limit: limit,
      );
      await _local.saveNotifications(page.items);
      return page;
    } on Exception catch (e) {
      rethrow;
    }
  }

  Future<NotificationPage> getFilteredNotifications({
    bool? read,
    String? channel,
    String? cursor,
    int limit = ApiConstants.defaultPageLimit,
  }) async {
    if (!_connectivity.isOnline) {
      var cached = _local.getNotifications();
      if (read != null) cached = cached.where((n) => n.read == read).toList();
      if (channel != null)
        cached = cached.where((n) => n.channel == channel).toList();
      return NotificationPage(items: cached, nextCursor: null, hasMore: false);
    }

    try {
      final page = await _remote.getFilteredNotifications(
        read: read,
        channel: channel,
        cursor: cursor,
        limit: limit,
      );
      await _local.saveNotifications(page.items);
      return page;
    } on Exception catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> markAsRead(String id) async {
    // MUST update Hive immediately
    await _local.updateReadStatus(id);

    if (!_connectivity.isOnline) {
      await _enqueueMarkRead(id);
      return;
    }

    try {
      await _remote.markAsRead(id);
    } on Exception catch (e) {
      await _enqueueMarkRead(id);
    }
  }

  Future<void> deleteNotification(String id) async {
    // MUST update Hive immediately
    await _local.deleteNotification(id);

    if (!_connectivity.isOnline) {
      await _local.addToSyncQueue(SyncTask.delete(id));
      return;
    }

    try {
      await _remote.deleteNotification(id);
    } on Exception catch (e) {
      await _local.addToSyncQueue(SyncTask.delete(id));
    }
  }

  Future<int> getUnreadCount() async {
    if (!_connectivity.isOnline) {
      return _local.getNotifications().where((n) => !n.read).length;
    }
    try {
      return await _remote.getUnreadCount();
    } catch (e) {
      return _local.getNotifications().where((n) => !n.read).length;
    }
  }

  Future<void> markAllAsRead() async {
    final cached = _local.getNotifications();
    for (var notif in cached) {
      if (!notif.read) {
        await _local.updateReadStatus(notif.id);
      }
    }

    if (!_connectivity.isOnline) {
      await _local.addToSyncQueue(SyncTask.markAllRead());
      return;
    }

    try {
      await _remote.markAllAsRead();
    } on Exception catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateSetting({
    required String channel,
    required bool isEnabled,
  }) async {
    try {
      await _remote.updateSetting(channel: channel, isEnabled: isEnabled);
    } on Exception catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getSettings() async {
    try {
      return await _remote.getSettings();
    } on Exception catch (e) {
      rethrow;
    }
  }

  @override
  List<NotificationModel> getCached() {
    return _local.getNotifications();
  }

  Future<void> _enqueueMarkRead(String id) async {
    await _local.addToSyncQueue(SyncTask.markRead(id));
  }

  NotificationPage _buildPageFromCache() {
    return NotificationPage(
      items: _local.getNotifications(),
      nextCursor: null,
      hasMore: false,
    );
  }
}
