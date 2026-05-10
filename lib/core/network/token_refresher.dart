import 'dart:async';
import 'package:dio/dio.dart';

import '../../features/auth/data/datasources/token_storage.dart';
import '../../features/auth/data/models/auth_tokens.dart';

enum LogoutReason {
  userInitiated,
  refreshExpired,
  refreshRejected,
  securityRevoked,
}

class TokenRefresher {
  final Dio _publicDio;
  final TokenStorage _storage;

  Completer<AuthTokens?>? _pendingRefresh;

  final _forceLogoutController = StreamController<LogoutReason>.broadcast();
  Stream<LogoutReason> get onForceLogout => _forceLogoutController.stream;

  final _tokensRefreshedController = StreamController<AuthTokens>.broadcast();
  Stream<AuthTokens> get onTokensRefreshed => _tokensRefreshedController.stream;

  TokenRefresher(this._publicDio, this._storage);

  Future<AuthTokens?> refresh() async {
    if (_pendingRefresh != null) {
      return _pendingRefresh!.future;
    }

    final completer = Completer<AuthTokens?>();
    _pendingRefresh = completer;

    try {
      final result = await _doRefresh();
      completer.complete(result);
      return result;
    } catch (e, st) {
      completer.complete(null);
      return null;
    } finally {
      _pendingRefresh = null;
    }
  }

  Future<AuthTokens?> _doRefresh() async {
    final current = _storage.read();
    if (current == null || current.isRefreshExpired) {
      _emitLogout(LogoutReason.refreshExpired);
      return null;
    }

    final Response response;
    try {
      response = await _publicDio.post(
        '/auth/refresh',
        data: {'refresh_token': current.refreshToken},
        options: Options(
          sendTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
        ),
      );
    } on DioException catch (e) {
      return _handleDioError(e);
    }

    final AuthTokens newTokens;
    try {
      newTokens = AuthTokens.fromApi(response.data);
    } catch (e, st) {
      return null;
    }

    final writeOk = await _storage.write(newTokens);
    if (!writeOk) {}

    if (!_tokensRefreshedController.isClosed) {
      _tokensRefreshedController.add(newTokens);
    }

    return newTokens;
  }

  AuthTokens? _handleDioError(DioException e) {
    if (_isNetworkError(e)) {
      return null;
    }

    final status = e.response?.statusCode;

    if (status == 401 || status == 403) {
      unawaited(_storage.clear());
      _emitLogout(
        status == 403
            ? LogoutReason.securityRevoked
            : LogoutReason.refreshRejected,
      );
      return null;
    }

    if (status != null && status >= 500) {
      return null;
    }

    unawaited(_storage.clear());
    _emitLogout(LogoutReason.refreshRejected);
    return null;
  }

  void _emitLogout(LogoutReason reason) {
    if (!_forceLogoutController.isClosed) {
      _forceLogoutController.add(reason);
    }
  }

  bool _isNetworkError(DioException e) {
    return e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError;
  }

  void dispose() {
    if (_pendingRefresh != null && !_pendingRefresh!.isCompleted) {
      _pendingRefresh!.complete(null);
    }
    _forceLogoutController.close();
    _tokensRefreshedController.close();
  }
}
