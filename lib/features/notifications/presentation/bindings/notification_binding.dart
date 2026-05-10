import 'package:get/get.dart';
import 'package:notification/data/repositories/notification_repository.dart';
import 'package:notification/features/notifications/domain/usecases/get_filtered_notifications_usecase.dart';
import 'package:notification/features/notifications/domain/usecases/get_unread_notifications_usecase.dart';
import 'package:notification/services/fcm_service.dart';
import '../../domain/usecases/get_notifications_usecase.dart';
import '../../domain/usecases/mark_read_usecase.dart';
import '../../domain/usecases/mark_all_as_read_usecase.dart';
import '../../domain/usecases/delete_notification_usecase.dart';
import '../../domain/usecases/get_unread_count_usecase.dart';
import '../../domain/usecases/update_setting_usecase.dart';
import '../../domain/usecases/get_settings_usecase.dart';
import '../controllers/notification_controller.dart';
import '../controllers/notification_settings_controller.dart';

class NotificationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GetNotificationsUseCase>(
      () => GetNotificationsUseCase(Get.find<NotificationRepository>()),
    );
    Get.lazyPut<GetUnreadNotificationsUseCase>(
      () => GetUnreadNotificationsUseCase(Get.find<NotificationRepository>()),
    );
    Get.lazyPut<GetFilteredNotificationsUseCase>(
      () => GetFilteredNotificationsUseCase(Get.find<NotificationRepository>()),
    );
    Get.lazyPut<MarkReadUseCase>(
      () => MarkReadUseCase(Get.find<NotificationRepository>()),
    );
    Get.lazyPut<MarkAllAsReadUseCase>(
      () => MarkAllAsReadUseCase(Get.find<NotificationRepository>()),
    );
    Get.lazyPut<DeleteNotificationUseCase>(
      () => DeleteNotificationUseCase(Get.find<NotificationRepository>()),
    );
    Get.lazyPut<GetUnreadCountUseCase>(
      () => GetUnreadCountUseCase(Get.find<NotificationRepository>()),
    );
    Get.lazyPut<UpdateSettingUseCase>(
      () => UpdateSettingUseCase(Get.find<NotificationRepository>()),
    );
    Get.lazyPut<GetSettingsUseCase>(
      () => GetSettingsUseCase(Get.find<NotificationRepository>()),
    );

    Get.lazyPut<NotificationController>(
      () => NotificationController(
        getNotificationsUseCase: Get.find<GetNotificationsUseCase>(),
        markReadUseCase: Get.find<MarkReadUseCase>(),
        markAllAsReadUseCase: Get.find<MarkAllAsReadUseCase>(),
        deleteNotificationUseCase: Get.find<DeleteNotificationUseCase>(),
        getUnreadCountUseCase: Get.find<GetUnreadCountUseCase>(),
        updateSettingUseCase: Get.find<UpdateSettingUseCase>(),
        getSettingsUseCase: Get.find<GetSettingsUseCase>(),
      ),
    );

    Get.lazyPut<NotificationSettingsController>(
      () => NotificationSettingsController(
        updateSettingUseCase: Get.find<UpdateSettingUseCase>(),
        getSettingsUseCase: Get.find<GetSettingsUseCase>(),
      ),
    );
  }
}
