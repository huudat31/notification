import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:notification/core/utils/device_info_util.dart';
import 'package:notification/core/constants/api_constants.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:notification/features/auth/data/datasources/token_storage.dart';
import 'package:notification/features/auth/data/models/auth_tokens.dart';

class AuthService {
  final Dio _dio;
  final TokenStorage _storage;

  AuthService(this._dio, this._storage);

  Future<AuthTokens> loginWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn.instance
          .authenticate();

      if (googleUser == null) {
        throw Exception('User cancelled Google Sign-In');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null || idToken.isEmpty) {
        throw Exception('google_error'.tr);
      }

      final decodedToken = JwtDecoder.decode(idToken);

      final deviceId = await DeviceInfoUtil.getDeviceId();
      final deviceName = await DeviceInfoUtil.getDeviceName();
      final deviceType = DeviceInfoUtil.getDeviceType();
      final fcmToken = await FirebaseMessaging.instance.getToken();

      final requestBody = {
        'idToken': idToken,
        'fcmToken': fcmToken ?? '',
        'deviceId': deviceId,
        'deviceName': deviceName,
        'deviceType': deviceType,
      };

      final response = await _dio.post(
        ApiConstants.loginWithGoogle,
        data: requestBody,
        options: Options(extra: {'skipAuth': true}),
      );

      final data = response.data as Map<String, dynamic>;

      final tokens = AuthTokens.fromApi(data);

      await _storage.write(tokens);

      return tokens;
    } on DioException catch (e) {
      String errorMessage = 'server_error'.tr;
      if (e.response?.data is Map) {
        errorMessage =
            e.response?.data['message'] ??
            e.response?.statusMessage ??
            'auth_error'.tr;
      } else if (e.response?.data is String) {
        errorMessage = e.response?.data;
      }
      throw Exception(errorMessage);
    } catch (e) {
      rethrow;
    }
  }

  Future<AuthTokens> loginWithFacebook() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login();

      if (result.status != LoginStatus.success) {
        if (result.status == LoginStatus.cancelled) {
          throw Exception('User cancelled Facebook Login');
        }
        throw Exception(result.message ?? 'Facebook Login failed');
      }

      final AccessToken accessToken = result.accessToken!;

      final deviceId = await DeviceInfoUtil.getDeviceId();
      final deviceName = await DeviceInfoUtil.getDeviceName();
      final deviceType = DeviceInfoUtil.getDeviceType();
      final fcmToken = await FirebaseMessaging.instance.getToken();

      final response = await _dio.post(
        '/api/auth/facebook',
        data: {
          'accessToken': accessToken.token,
          'fcmToken': fcmToken ?? '',
          'deviceId': deviceId,
          'deviceName': deviceName,
          'deviceType': deviceType,
        },
        options: Options(extra: {'skipAuth': true}),
      );

      final data = response.data as Map<String, dynamic>;
      final tokens = AuthTokens.fromApi(data);

      await _storage.write(tokens);
      return tokens;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'facebook_error'.tr);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      final deviceId = await DeviceInfoUtil.getDeviceId();
      await _dio.post(
        ApiConstants.notificationLogout,
        data: {'deviceId': deviceId},
      );
    } catch (_) {}

    try {
      await GoogleSignIn.instance.signOut();
    } catch (_) {}

    try {
      await FacebookAuth.instance.logOut();
    } catch (_) {}

    try {
      await _storage.clearTokens();
    } catch (_) {}
  }
}
