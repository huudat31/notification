import 'package:dio/dio.dart';

import 'package:notification/features/auth/data/datasources/token_storage.dart';
import 'package:notification/features/auth/data/models/auth_tokens.dart';
import '../token_refresher.dart';

class RefreshOn401Interceptor extends QueuedInterceptor {
  final TokenStorage _storage;
  final TokenRefresher _refresher;
  final Dio _dio;

  RefreshOn401Interceptor(this._dio, this._refresher, this._storage);

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    if (err.requestOptions.extra['retried'] == true) {
      return handler.next(err);
    }

    final currentStorageToken = _storage.read()?.accessToken;
    final requestToken = err.requestOptions.headers['Authorization']
        ?.toString()
        .replaceFirst('Bearer ', '');

    final AuthTokens? newTokens;
    if (currentStorageToken != null &&
        requestToken != null &&
        currentStorageToken != requestToken) {
      newTokens = _storage.read();
    } else {
      newTokens = await _refresher.refresh();
    }

    if (newTokens == null) {
      return handler.next(err);
    }

    final opts = err.requestOptions;
    opts.headers['Authorization'] = 'Bearer ${newTokens.accessToken}';
    opts.extra['retried'] = true;

    try {
      final response = await _dio.fetch(opts);
      return handler.resolve(response);
    } on DioException catch (retryErr) {
      return handler.next(retryErr);
    }
  }
}
