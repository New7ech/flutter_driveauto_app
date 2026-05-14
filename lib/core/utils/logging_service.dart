/// DriveAuto — logging_service.dart
/// Rôle : Service centralisé de logging structuré pour debugging et monitoring
/// Auteur : DriveAuto Team

import 'package:flutter/foundation.dart';

enum LogLevel { debug, info, warning, error }

class LoggingService {
  static final LoggingService _instance = LoggingService._internal();

  factory LoggingService() => _instance;

  LoggingService._internal();

  /// Logs un message avec un niveau de sévérité
  static void log(
    String message, {
    LogLevel level = LogLevel.info,
    String? tag,
    dynamic error,
    StackTrace? stackTrace,
  }) {
    if (!kDebugMode) return;

    final timestamp = DateTime.now().toIso8601String();
    final tagStr = tag != null ? '[$tag]' : '';
    final levelStr = level.name.toUpperCase().padRight(7);

    final formattedMessage = '$timestamp $levelStr $tagStr $message';

    switch (level) {
      case LogLevel.debug:
        debugPrint(formattedMessage);
      case LogLevel.info:
        debugPrint(formattedMessage);
      case LogLevel.warning:
        debugPrint('⚠️  $formattedMessage');
      case LogLevel.error:
        debugPrint('❌ $formattedMessage');
        if (error != null) {
          debugPrint('Error: $error');
        }
        if (stackTrace != null) {
          debugPrintStack(stackTrace: stackTrace);
        }
    }
  }

  /// Convenience methods
  static void debug(String message, {String? tag}) =>
      log(message, level: LogLevel.debug, tag: tag);

  static void info(String message, {String? tag}) =>
      log(message, level: LogLevel.info, tag: tag);

  static void warning(String message, {String? tag}) =>
      log(message, level: LogLevel.warning, tag: tag);

  static void error(
    String message, {
    String? tag,
    dynamic error,
    StackTrace? stackTrace,
  }) =>
      log(
        message,
        level: LogLevel.error,
        tag: tag,
        error: error,
        stackTrace: stackTrace,
      );
}
