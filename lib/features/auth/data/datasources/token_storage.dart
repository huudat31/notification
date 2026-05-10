import 'dart:async';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';
import '../models/auth_tokens.dart';

class TokenStorage {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  static const _keyPayload = 'auth_payload_v2';
  static const _currentSchemaVersion = '2.0';

  AuthTokens? _cache;
  bool _isInitialized = false;

  Future<void> _writeLock = Future.value();

  TokenStorage();
  Future<void> init() async {
    if (_isInitialized) return;

    try {
      final raw = await _storage.read(key: _keyPayload);
      if (raw == null) {
        _cache = null;
        _isInitialized = true;
        return;
      }

      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final schema = decoded['schema'] as String?;

      if (schema != _currentSchemaVersion) {
        await _clearDisk();
        _cache = null;
        _isInitialized = true;
        return;
      }

      final tokenJson = decoded['tokens'] as Map<String, dynamic>;
      _cache = AuthTokens.fromJson(tokenJson);
      _isInitialized = true;
    } catch (e, st) {
      await _clearDisk();
      _cache = null;
      _isInitialized = true;
    }
  }

  AuthTokens? read() {
    if (!_isInitialized) {
      return null;
    }
    return _cache;
  }

  Future<AuthTokens?> readAsync() async {
    if (!_isInitialized) await init();
    return _cache;
  }

  Future<bool> write(AuthTokens tokens) async {
    _cache = tokens;
    _isInitialized = true;
    final completer = Completer<bool>();
    _writeLock = _writeLock.then((_) async {
      try {
        final payload = jsonEncode({
          'schema': _currentSchemaVersion,
          'tokens': tokens.toJson(),
        });
        await _storage.write(key: _keyPayload, value: payload);
        completer.complete(true);
      } catch (e, st) {
        completer.complete(false);
      }
    });

    return completer.future;
  }

  Future<void> clear() async {
    _cache = null;
    _isInitialized = true;

    final completer = Completer<void>();
    _writeLock = _writeLock.then((_) async {
      try {
        await _clearDisk();
      } catch (e) {
      } finally {
        completer.complete();
      }
    });

    return completer.future;
  }

  // --- Facade Methods ---

  Future<bool> saveTokens(dynamic response) async {
    AuthTokens tokens;
    if (response is AuthTokens) {
      tokens = response;
    } else {
      try {
        final map = response.toJson() as Map<String, dynamic>;
        // Backend returns camelCase: accessToken, refreshToken, tokenType
        // AuthTokens.fromApi() expects: access_token, refresh_token
        tokens = AuthTokens.fromApi({
          'access_token': map['accessToken'] ?? map['access_token'],
          'refresh_token': map['refreshToken'] ?? map['refresh_token'],
        });
      } catch (e) {
        return false;
      }
    }
    return write(tokens);
  }

  String? getAccessToken() {
    return read()?.accessToken;
  }

  String? getRefreshToken() {
    return read()?.refreshToken;
  }

  Future<void> clearTokens() async {
    await clear();
  }

  Future<void> _clearDisk() async {
    try {
      await _storage.delete(key: _keyPayload);
    } catch (e) {}
  }
}
