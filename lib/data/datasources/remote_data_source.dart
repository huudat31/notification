import '../../core/constants/api_constants.dart';
import 'package:get/get.dart';
import '../../core/network/dio_client.dart';

import '../models/notification_model.dart';
import 'package:dio/dio.dart';

abstract class NotificationRemoteDataSource {
  Future<NotificationPage> getNotifications({
    String? cursor,
    int limit = ApiConstants.defaultPageLimit,
  });

  Future<NotificationPage> getUnreadNotifications({
    String? cursor,
    int limit = ApiConstants.defaultPageLimit,
  });

  Future<NotificationPage> getFilteredNotifications({
    bool? read,
    String? channel,
    String? cursor,
    int limit = ApiConstants.defaultPageLimit,
  });

  Future<NotificationPage> getReadNotifications({
    String? cursor,
    int limit = ApiConstants.defaultPageLimit,
  });

  Future<void> markAsRead(String id);
  Future<void> markAllAsRead();
  Future<void> deleteNotification(String id);
  Future<int> getUnreadCount();

  Future<void> updateSetting({
    required String channel,
    required bool isEnabled,
  });
  Future<Map<String, dynamic>> getSettings();
}

class NotificationPage {
  final List<NotificationModel> items;
  final String? nextCursor;
  final bool hasMore;

  const NotificationPage({
    required this.items,
    required this.nextCursor,
    required this.hasMore,
  });
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final Dio _dio;

  NotificationRemoteDataSourceImpl({Dio? dio})
    : _dio = dio ?? _createNotificationDio();

  static Dio _createNotificationDio() {
    final original = Get.find<DioClient>().authDio;
    final newDio = Dio(
      original.options.copyWith(baseUrl: ApiConstants.notificationBaseUrl),
    );
    newDio.interceptors.addAll(original.interceptors);
    return newDio;
  }

  @override
  Future<NotificationPage> getNotifications({
    String? cursor,
    int limit = ApiConstants.defaultPageLimit,
  }) async {
    final pageNum = cursor != null ? int.tryParse(cursor) ?? 0 : 0;
    final response = await _dio.get(
      ApiConstants.notificationGetAll,
      queryParameters: {'size': limit, 'page': pageNum},
    );
    return _parsePage(response.data, pageNum);
  }

  @override
  Future<NotificationPage> getUnreadNotifications({
    String? cursor,
    int limit = ApiConstants.defaultPageLimit,
  }) async {
    final pageNum = cursor != null ? int.tryParse(cursor) ?? 0 : 0;
    final response = await _dio.get(
      ApiConstants.notificationGetUnread,
      queryParameters: {'size': limit, 'page': pageNum},
    );
    return _parsePage(response.data, pageNum);
  }

  @override
  Future<NotificationPage> getFilteredNotifications({
    bool? read,
    String? channel,
    String? cursor,
    int limit = ApiConstants.defaultPageLimit,
  }) async {
    final pageNum = cursor != null ? int.tryParse(cursor) ?? 0 : 0;
    final response = await _dio.get(
      ApiConstants.notificationGetAll,
      queryParameters: {
        'size': limit,
        'page': pageNum,
        if (read != null) 'read': read,
        if (channel != null) 'channel': channel,
      },
    );
    return _parsePage(response.data, pageNum);
  }

  @override
  Future<NotificationPage> getReadNotifications({
    String? cursor,
    int limit = ApiConstants.defaultPageLimit,
  }) async {
    final pageNum = cursor != null ? int.tryParse(cursor) ?? 0 : 0;
    final response = await _dio.get(
      ApiConstants.notificationGetRead,
      queryParameters: {'size': limit, 'page': pageNum},
    );
    return _parsePage(response.data, pageNum);
  }

  NotificationPage _parsePage(dynamic responseData, int currentPage) {
    final data = responseData as Map<String, dynamic>;
    final rawList = (data['content'] as List<dynamic>?) ?? [];

    final items = rawList
        .cast<Map<String, dynamic>>()
        .map(NotificationModel.fromJson)
        .toList();

    final isLast = (data['last'] as bool?) ?? true;

    return NotificationPage(
      items: items,
      nextCursor: isLast ? null : (currentPage + 1).toString(),
      hasMore: !isLast,
    );
  }

  @override
  Future<void> markAsRead(String id) async {
    await _dio.patch(ApiConstants.notificationMarkRead.replaceAll('{id}', id));
  }

  @override
  Future<void> markAllAsRead() async {
    await _dio.patch(ApiConstants.notificationMarkAllRead);
  }

  @override
  Future<void> deleteNotification(String id) async {
    await _dio.delete(ApiConstants.notificationDelete.replaceAll('{id}', id));
  }

  @override
  Future<int> getUnreadCount() async {
    final response = await _dio.get(ApiConstants.notificationUnreadCount);
    if (response.data is int) return response.data as int;
    if (response.data is String)
      return int.tryParse(response.data as String) ?? 0;
    if (response.data is Map) return (response.data['count'] as int?) ?? 0;
    return 0;
  }

  @override
  Future<void> updateSetting({
    required String channel,
    required bool isEnabled,
  }) async {
    await _dio.patch(
      ApiConstants.notificationUpdateSetting,
      queryParameters: {'channel': channel, 'isEnabled': isEnabled},
    );
  }

  @override
  Future<Map<String, dynamic>> getSettings() async {
    final response = await _dio.get(ApiConstants.notificationUpdateSetting);
    final data = response.data;
    if (data is Map<String, dynamic>) return data;
    return {};
  }
}
