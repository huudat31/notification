import 'package:flutter/foundation.dart';

class Logger {
  static void d(String tag, String message) {
    if (kDebugMode) {
      debugPrint('[$tag] $message');
    }
  }

  static void e(String tag, String message, [Object? error, StackTrace? st]) {
    if (kDebugMode) {
      debugPrint('[ERROR][$tag] $message');
      if (error != null) {
        if (error.runtimeType.toString() == 'DioException') {
          final dynamic dioError = error;
          try {
            debugPrint(
              '  DioError: [${dioError.response?.statusCode}] ${dioError.requestOptions?.path}',
            );
          } catch (_) {
            debugPrint('  Error: $error');
          }
        } else {
          debugPrint('  Error: $error');
        }
      }
      if (st != null) debugPrint('  StackTrace: $st');
    }
  }

  static void w(String tag, String message) {
    if (kDebugMode) {
      debugPrint('[WARN][$tag] $message');
    }
  }
}
