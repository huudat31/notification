import 'dart:async';
import 'package:get/get.dart' hide Response;

import 'package:dio/dio.dart';
import 'auth_state.dart';
import 'package:notification/core/network/token_refresher.dart';
import '../../data/datasources/token_storage.dart';
import '../../data/models/auth_tokens.dart';
import '../../data/services/auth_service.dart';
import '../../../../services/fcm_service.dart';
import '../../../../core/constants/api_constants.dart';

class AuthController extends GetxController {
  final TokenStorage _storage;
  final TokenRefresher _refresher;
  final Dio _publicDio;
  final AuthService _authService;
  final FcmService _fcmService;

  final Rx<AuthState> state = Rx<AuthState>(AuthState.bootstrapping());
  final RxBool isProcessing = false.obs;

  bool _isAppReady = false;

  bool _isLoggingOut = false;

  late final StreamSubscription _logoutSub;
  late final StreamSubscription _tokensSub;

  AuthController(
    this._storage,
    this._refresher,
    this._publicDio,
    this._authService,
    this._fcmService,
  );

  @override
  void onInit() {
    super.onInit();

    _logoutSub = _refresher.onForceLogout.listen((reason) {
      _executeLogout(reason: reason);
    });

    _tokensSub = _refresher.onTokensRefreshed.listen((newTokens) {
      final current = state.value;
      if (current is Authenticated) {
        state.value = current.copyWith(tokens: newTokens);
      }
    });

    ever<AuthState>(state, _onStateChanged);
  }

  @override
  void onReady() {
    super.onReady();
    _isAppReady = true;
    _onStateChanged(state.value);
  }

  void _onStateChanged(AuthState s) {
    if (!_isAppReady) return;
    if (s is Bootstrapping) return;

    if (s is Unauthenticated && Get.currentRoute != '/login') {
      Get.offAllNamed('/login');
    }
  }

  void bootstrap() {
    final tokens = _storage.read();

    if (tokens == null || tokens.isRefreshExpired) {
      state.value = const Unauthenticated();
    } else {
      state.value = Authenticated(tokens);
    }
  }

  Future<void> onAppResumed() async {
    final current = state.value;
    if (current is! Authenticated) return;

    if (current.tokens.isRefreshExpired) {
      await _executeLogout(reason: LogoutReason.refreshExpired);
      return;
    }

    if (current.tokens.isAccessNearExpiry) {
      unawaited(
        _refresher.refresh().catchError((e) {
          return null;
        }),
      );
    }
  }

  Future<void> login(String username, String password) async {
    if (isProcessing.value) return;
    isProcessing.value = true;

    try {
      final response = await _publicDio.post(
        ApiConstants.authLogin,
        data: {'username': username, 'password': password},
      );

      final tokens = AuthTokens.fromApi(response.data);
      await _storage.write(tokens);
      state.value = Authenticated(tokens);
      Get.offAllNamed('/notifications');
    } on DioException catch (e) {
      rethrow;
    } finally {
      isProcessing.value = false;
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    if (isProcessing.value) return;
    isProcessing.value = true;

    try {
      final response = await _publicDio.post(
        ApiConstants.authRegister,
        data: {'name': name, 'email': email, 'password': password},
      );

      final tokens = AuthTokens.fromApi(response.data);
      await _storage.write(tokens);

      state.value = Authenticated(tokens);
      await _syncFcmToken();
      Get.offAllNamed('/notifications');
    } on DioException catch (e) {
      rethrow;
    } finally {
      isProcessing.value = false;
    }
  }

  Future<void> loginWithGoogle() async {
    if (isProcessing.value) return;
    isProcessing.value = true;
    try {
      final tokens = await _authService.loginWithGoogle();
      state.value = Authenticated(tokens);
      await _syncFcmToken();
      Get.offAllNamed('/notifications');
    } catch (e) {
      Get.snackbar('login_failed'.tr, e.toString());
    } finally {
      isProcessing.value = false;
    }
  }

  Future<void> loginWithFacebook() async {
    if (isProcessing.value) return;
    isProcessing.value = true;
    try {
      // AuthService handles Facebook sign-in, device info, API call, and saves tokens
      final tokens = await _authService.loginWithFacebook();
      state.value = Authenticated(tokens);
      await _syncFcmToken();
      Get.offAllNamed('/notifications');
    } catch (e) {
      // Don't show error for user-cancelled flow
      if (!e.toString().contains('cancelled')) {
        Get.snackbar('login_failed'.tr, e.toString());
      }
    } finally {
      isProcessing.value = false;
    }
  }

  Future<void> _syncFcmToken() async {
    try {
      final token = await _fcmService.getToken();
      if (token != null) {}
    } catch (e) {}
  }

  Future<void> logout() async {
    if (isProcessing.value) return;
    isProcessing.value = true;
    try {
      await _executeLogout(reason: LogoutReason.userInitiated);
    } finally {
      isProcessing.value = false;
    }
  }

  Future<void> _executeLogout({required LogoutReason reason}) async {
    if (_isLoggingOut) {
      return;
    }
    _isLoggingOut = true;

    try {
      if (reason == LogoutReason.userInitiated) {
        await _authService.logout();
      }

      await _storage.clear();

      state.value = Unauthenticated(reason: reason);
    } finally {
      _isLoggingOut = false;
    }
  }

  @override
  void onClose() {
    _logoutSub.cancel();
    _tokensSub.cancel();
    super.onClose();
  }
}
