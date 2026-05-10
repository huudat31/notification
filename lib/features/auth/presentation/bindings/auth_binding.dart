import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../../data/datasources/token_storage.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/token_refresher.dart';
import '../../../../core/network/interceptors/secure_logging_interceptor.dart';
import '../../../../core/constants/api_constants.dart';
import '../../data/services/auth_service.dart';
import '../../../../services/fcm_service.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<TokenStorage>(TokenStorage(), permanent: true);

    final publicDio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.notificationBaseUrl,
        connectTimeout: const Duration(
          milliseconds: ApiConstants.connectTimeout,
        ),
        receiveTimeout: const Duration(
          milliseconds: ApiConstants.receiveTimeout,
        ),
        sendTimeout: const Duration(milliseconds: ApiConstants.sendTimeout),
      ),
    );
    publicDio.interceptors.addAll([
      SecureLoggingInterceptor(),
    ]);

    Get.put<TokenRefresher>(
      TokenRefresher(publicDio, Get.find<TokenStorage>()),
      permanent: true,
    );

    Get.put<DioClient>(
      DioClient(
        storage: Get.find<TokenStorage>(),
        refresher: Get.find<TokenRefresher>(),
        publicDioInstance: publicDio,
      ),
      permanent: true,
    );

    Get.put<AuthService>(
      AuthService(publicDio, Get.find<TokenStorage>()),
      permanent: true,
    );

    Get.put<AuthController>(
      AuthController(
        Get.find<TokenStorage>(),
        Get.find<TokenRefresher>(),
        publicDio,
        Get.find<AuthService>(),
        Get.find<FcmService>(),
      ),
      permanent: true,
    );
  }
}
