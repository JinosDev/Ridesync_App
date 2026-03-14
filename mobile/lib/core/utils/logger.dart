import 'package:flutter/foundation.dart';

/// Dev-mode console logger. Silent in release builds.
class AppLogger {
  AppLogger._();

  static void info(String message, [Object? data]) {
    if (kDebugMode) {
      debugPrint('[INFO] $message${data != null ? ' | $data' : ''}');
    }
  }

  static void warn(String message, [Object? data]) {
    if (kDebugMode) {
      debugPrint('[WARN] $message${data != null ? ' | $data' : ''}');
    }
  }

  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      debugPrint('[ERROR] $message${error != null ? ' | $error' : ''}');
      if (stackTrace != null) debugPrint(stackTrace.toString());
    }
  }
}
