import 'package:dio/dio.dart';
import 'package:notification/features/auth/data/datasources/token_storage.dart';
import '../constants/api_constants.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/refresh_on_401_interceptor.dart';
import 'interceptors/secure_logging_interceptor.dart';
import 'token_refresher.dart';

class DioClient {
  late final Dio publicDio;
  late final Dio authDio;

  DioClient({
    required TokenStorage storage,
    required TokenRefresher refresher,
    required Dio publicDioInstance,
  }) {
    publicDio = publicDioInstance;

    final baseOptions = BaseOptions(
      baseUrl: ApiConstants.notificationBaseUrl,
      connectTimeout: const Duration(milliseconds: ApiConstants.connectTimeout),
      receiveTimeout: const Duration(milliseconds: ApiConstants.receiveTimeout),
      sendTimeout: const Duration(milliseconds: ApiConstants.sendTimeout),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    authDio = Dio(baseOptions);

    authDio.interceptors.addAll([
      AuthInterceptor(storage, refresher),
      RefreshOn401Interceptor(authDio, refresher, storage),
      SecureLoggingInterceptor(),
    ]);
  }
}
