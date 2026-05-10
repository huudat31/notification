import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/controllers/settings_controller.dart';
import '../../../../core/constants/ui_constants.dart';
import '../controllers/notification_controller.dart';
import '../widgets/notification_card.dart';
import '../widgets/shimmer_card.dart';

class NotificationListView extends GetView<NotificationController> {
  const NotificationListView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: _buildAppBar(context),
        body: Column(
          children: [
            _buildSearchBar(context),
            Expanded(child: Obx(() => _buildBody(context))),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(
        'notifications'.tr,
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 24),
      ),
      actions: [
        IconButton(
          tooltip: 'Mark all as read'.tr,
          icon: const Icon(Icons.done_all),
          onPressed: () => controller.markAllAsRead(),
        ),
        IconButton(
          tooltip: 'settings'.tr,
          icon: const Icon(Icons.more_vert),
          onPressed: () => Get.toNamed('/settings'),
        ),
        const SizedBox(width: 8),
      ],
      bottom: TabBar(
        isScrollable: false,
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400),
        onTap: controller.changeTab,
        tabs: [
          Tab(text: 'all'.tr),
          _buildTabWithBadge('unread'.tr, controller.unreadCount),
          Tab(text: 'read'.tr),
        ],
      ),
    );
  }

  Widget _buildTabWithBadge(String label, RxInt count) {
    return Tab(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          Obx(() {
            if (count.value == 0) return const SizedBox.shrink();
            return Container(
              margin: const EdgeInsets.only(left: 6),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Get.theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count.value > 99 ? '99+' : count.value.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }



  Widget _buildBody(BuildContext context) {
    if (controller.isLoading.value && controller.notifications.isEmpty) {
      return _buildShimmerList();
    }

    if (controller.errorMessage.value != null &&
        controller.notifications.isEmpty) {
      return _buildError(context);
    }

    if (!controller.isLoading.value && controller.currentList.isEmpty) {
      return _buildEmpty();
    }

    return _buildList(context);
  }



  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(UiConstants.paddingMd),
      child: TextField(
        onChanged: controller.onSearchChanged,
        decoration: InputDecoration(
          hintText: 'search_placeholder'.tr,
          prefixIcon: const Icon(Icons.search),
          isDense: true,
        ),
      ),
    );
  }

  Widget _buildShimmerList() {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 8,
      itemBuilder: (_, _) => const ShimmerCard(),
    );
  }

  Widget _buildList(BuildContext context) {
    final list = controller.currentList;

    return RefreshIndicator(
      onRefresh: controller.refresh,
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          _onScroll(notification);
          return false;
        },
        child: ListView.builder(
          itemCount: list.length + 1,
          itemBuilder: (context, index) {
            if (index < list.length) {
              return NotificationCard(
                notification: list[index],
                onTap: () => controller.onNotificationTap(list[index]),
                onDelete: () => controller.deleteNotification(list[index].id),
              );
            }
            return _buildListFooter();
          },
        ),
      ),
    );
  }

  void _onScroll(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification) {
      final metrics = notification.metrics;
      if (metrics.maxScrollExtent > 0) {
        if (metrics.pixels / metrics.maxScrollExtent >= 0.75) {
          controller.loadMore();
        }
      }
    }
  }

  Widget _buildListFooter() {
    if (controller.isLoadingMore.value) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    if (!controller.hasMore.value && controller.notifications.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: Text(
            'all_shown'.tr,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildError(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_outlined,
              size: 48,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 12),
            Text(
              controller.errorMessage.value ?? 'error_occurred'.tr,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: controller.refresh,
              child: Text('try_again'.tr),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.notifications_none_outlined,
            size: 56,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 12),
          Text(
            'no_notifications'.tr,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
