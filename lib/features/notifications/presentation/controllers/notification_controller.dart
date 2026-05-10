import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:notification/data/models/notification_model.dart';

import '../../domain/usecases/get_notifications_usecase.dart';
import '../../domain/usecases/mark_read_usecase.dart';
import '../../domain/usecases/mark_all_as_read_usecase.dart';
import '../../domain/usecases/delete_notification_usecase.dart';
import '../../domain/usecases/get_unread_count_usecase.dart';
import '../../domain/usecases/update_setting_usecase.dart';
import '../../domain/usecases/get_settings_usecase.dart';

enum TabType { all, unread, read }

class NotificationController extends GetxController
    with WidgetsBindingObserver {
  final GetNotificationsUseCase _getNotificationsUseCase;
  final MarkReadUseCase _markReadUseCase;
  final MarkAllAsReadUseCase _markAllAsReadUseCase;
  final DeleteNotificationUseCase _deleteNotificationUseCase;
  final GetUnreadCountUseCase _getUnreadCountUseCase;
  final UpdateSettingUseCase _updateSettingUseCase;
  final GetSettingsUseCase _getSettingsUseCase;

  NotificationController({
    required GetNotificationsUseCase getNotificationsUseCase,
    required MarkReadUseCase markReadUseCase,
    required MarkAllAsReadUseCase markAllAsReadUseCase,
    required DeleteNotificationUseCase deleteNotificationUseCase,
    required GetUnreadCountUseCase getUnreadCountUseCase,
    required UpdateSettingUseCase updateSettingUseCase,
    required GetSettingsUseCase getSettingsUseCase,
  }) : _getNotificationsUseCase = getNotificationsUseCase,
       _markReadUseCase = markReadUseCase,
       _markAllAsReadUseCase = markAllAsReadUseCase,
       _deleteNotificationUseCase = deleteNotificationUseCase,
       _getUnreadCountUseCase = getUnreadCountUseCase,
       _updateSettingUseCase = updateSettingUseCase,
       _getSettingsUseCase = getSettingsUseCase;

  final notifications = <NotificationModel>[].obs;
  final currentTab = TabType.all.obs;
  final unreadCount = 0.obs;

  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final hasMore = true.obs;
  final errorMessage = Rxn<String>();
  final RxString searchQuery = ''.obs;

  int _currentPage = 0;

  List<NotificationModel> get unreadList =>
      notifications.where((n) => !n.isRead).toList();

  List<NotificationModel> get readList =>
      notifications.where((n) => n.isRead).toList();

  List<NotificationModel> get currentList {
    final query = searchQuery.value.toLowerCase();
    List<NotificationModel> list;

    switch (currentTab.value) {
      case TabType.unread:
        list = unreadList;
        break;
      case TabType.read:
        list = readList;
        break;
      case TabType.all:
      default:
        list = notifications;
        break;
    }

    if (query.isEmpty) return list;

    return list.where((n) {
      final title = n.title.toLowerCase();
      final bodyText = n.body.toLowerCase();
      return title.contains(query) || bodyText.contains(query);
    }).toList();
  }

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _loadCachedThenFetch();
    fetchUnreadCount();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      fetchUnreadCount();
      _fetchPage(isRefresh: true);
    }
  }

  void changeTab(int index) {
    final newTab = TabType.values[index];
    if (currentTab.value == newTab) return;
    currentTab.value = newTab;
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
  }

  @override
  Future<void> refresh() async {
    _currentPage = 0;
    errorMessage.value = null;
    hasMore.value = true;
    await _fetchPage(isRefresh: true);
    await fetchUnreadCount();
  }

  Future<void> loadMore() async {
    if (isLoadingMore.value || !hasMore.value) return;
    if (currentTab.value != TabType.all) return;

    _currentPage++;
    await _fetchPage(isRefresh: false);
  }

  Future<void> fetchUnreadCount() async {
    try {
      unreadCount.value = await _getUnreadCountUseCase.execute();
    } catch (e) {}
  }

  Future<void> onNotificationTap(NotificationModel noti) async {
    if (noti.isRead) {
      Get.toNamed('/notification-detail', arguments: noti);
      return;
    }

    final index = notifications.indexWhere((e) => e.id == noti.id);
    if (index == -1) {
      Get.toNamed('/notification-detail', arguments: noti);
      return;
    }

    final originalNoti = notifications[index];
    final updatedNoti = noti.copyWith(read: true, status: 'read');
    notifications[index] = updatedNoti;
    unreadCount.value = (unreadCount.value - 1).clamp(0, 999999);
    notifications.refresh();

    Get.toNamed('/notification-detail', arguments: updatedNoti);

    _callMarkReadApi(noti.id, index, originalNoti);
  }

  Future<void> _callMarkReadApi(
    String notificationId,
    int originalIndex,
    NotificationModel originalNoti,
  ) async {
    try {
      final result = await _markReadUseCase.execute(notificationId);
      if (result.success) {
      } else {
        _rollbackReadStatus(originalIndex, originalNoti);
      }
    } catch (e) {
      _rollbackReadStatus(originalIndex, originalNoti);
    }
  }

  void _rollbackReadStatus(int index, NotificationModel originalNoti) {
    if (index < notifications.length &&
        notifications[index].id == originalNoti.id) {
      notifications[index] = originalNoti;
      unreadCount.value++;
      notifications.refresh();
    }
  }

  Future<void> deleteNotification(String id) async {
    final index = notifications.indexWhere((e) => e.id == id);
    if (index == -1) return;

    final removedNoti = notifications[index];
    final backupList = List<NotificationModel>.from(notifications);

    notifications.removeAt(index);
    if (!removedNoti.isRead) {
      unreadCount.value = (unreadCount.value - 1).clamp(0, 999999);
    }

    try {
      await _deleteNotificationUseCase.execute(id);
    } catch (e) {
      notifications.assignAll(backupList);
      if (!removedNoti.isRead) {
        unreadCount.value++;
      }
    }
  }

  Future<void> markAllAsRead() async {
    for (var i = 0; i < notifications.length; i++) {
      if (!notifications[i].read) {
        notifications[i] = notifications[i].copyWith(
          read: true,
          status: 'read',
        );
      }
    }
    unreadCount.value = 0;
    notifications.refresh();

    try {
      await _markAllAsReadUseCase.execute();
      await fetchUnreadCount();
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'failed_to_mark_all_read'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      _fetchPage(isRefresh: true);
    }
  }

  void _loadCachedThenFetch() {
    final cached = _getNotificationsUseCase.getCached();
    if (cached.isNotEmpty) {
      notifications.assignAll(cached);
    }
    _fetchPage(isRefresh: true);
  }

  Future<void> _fetchPage({required bool isRefresh}) async {
    if (isRefresh) {
      if (isLoading.value) return;
      isLoading.value = true;
    } else {
      if (isLoadingMore.value) return;
      isLoadingMore.value = true;
    }

    try {
      final result = await _getNotificationsUseCase.execute(
        existing: isRefresh ? [] : notifications.toList(),
        cursor: _currentPage.toString(),
      );

      if (isRefresh) {
        notifications.assignAll(result.notifications);
      } else {
        final newItems = result.notifications
            .where((n) => !notifications.any((existing) => existing.id == n.id))
            .toList();
        notifications.addAll(newItems);
      }

      hasMore.value = result.hasMore;
      errorMessage.value = null;
    } catch (e, st) {
      errorMessage.value = 'error_occurred'.tr;
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  Future<void> updateSetting(String channel, bool isEnabled) async {
    await _updateSettingUseCase.execute(channel: channel, isEnabled: isEnabled);
  }

  Future<Map<String, dynamic>> getSettings() async {
    return await _getSettingsUseCase.execute();
  }
}
