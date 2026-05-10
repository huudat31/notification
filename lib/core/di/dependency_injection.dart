import 'package:get/get.dart';
import 'package:notification/core/controllers/settings_controller.dart';
import 'package:notification/features/auth/presentation/bindings/auth_binding.dart';
import 'package:notification/data/datasources/local_data_source.dart';
import 'package:notification/data/datasources/remote_data_source.dart';
import 'package:notification/data/repositories/notification_repository.dart';
import 'package:notification/features/notifications/domain/usecases/sync_queue_usecase.dart';
import 'package:notification/services/connectivity_service.dart';
import 'package:notification/services/fcm_service.dart';
import 'package:notification/services/sync_service.dart';

class DependencyInjection {
  static void initCore() {
    Get.put<SettingsController>(SettingsController(), permanent: true);

    Get.put<ConnectivityService>(ConnectivityService(), permanent: true);
    Get.put<FcmService>(FcmService(), permanent: true);

    AuthBinding().dependencies();

    Get.put<NotificationLocalDataSource>(
      NotificationLocalDataSourceImpl(),
      permanent: true,
    );
    Get.put<NotificationRemoteDataSource>(
      NotificationRemoteDataSourceImpl(),
      permanent: true,
    );

    Get.put<NotificationRepository>(
      NotificationRepository(
        remote: Get.find<NotificationRemoteDataSource>(),
        local: Get.find<NotificationLocalDataSource>(),
        connectivity: Get.find<ConnectivityService>(),
      ),
      permanent: true,
    );

    Get.put<SyncQueueUseCase>(
      SyncQueueUseCase(
        local: Get.find<NotificationLocalDataSource>(),
        remote: Get.find<NotificationRemoteDataSource>(),
      ),
      permanent: true,
    );

    Get.put<SyncService>(
      SyncService(
        connectivity: Get.find<ConnectivityService>(),
        syncQueueUseCase: Get.find<SyncQueueUseCase>(),
      ),
      permanent: true,
    );
  }
}
