import 'dart:async';
import 'package:dio/dio.dart';

import '../../../features/auth/data/datasources/token_storage.dart';
import '../token_refresher.dart';

class AuthInterceptor extends Interceptor {
  final TokenStorage _storage;
  final TokenRefresher _refresher;

  AuthInterceptor(this._storage, this._refresher);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (options.extra['skipAuth'] == true) {
      return handler.next(options);
    }

    final tokens = _storage.read();
    if (tokens == null) {
      return handler.next(options);
    }

    if (tokens.isAccessNearExpiry && !tokens.isRefreshExpired) {
      unawaited(
        _refresher.refresh().catchError((e) {
          return null;
        }),
      );
    }

    options.headers['Authorization'] = 'Bearer ${tokens.accessToken}';
    handler.next(options);
  }
}
