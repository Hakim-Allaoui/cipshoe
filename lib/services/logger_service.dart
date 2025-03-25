import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

enum LogLevel {
  info,
  debug,
  warning,
  error,
  success,
}

class LoggerService {
  static final DateFormat _timeFormat = DateFormat('HH:mm:ss.SSS');

  static void log(String message,
      {LogLevel level = LogLevel.info, String? tag}) {
    if (!kDebugMode) return;

    final time = _timeFormat.format(DateTime.now());
    final tagInfo = tag != null ? '[$tag]' : '';
    final emoji = _getEmojiForLevel(level);
    final colorCode = _getColorCodeForLevel(level);
    final resetCode = '\x1B[0m';

    // Format: [TIME] EMOJI [TAG] MESSAGE
    print('$colorCode[$time] $emoji $tagInfo $message$resetCode');
  }

  static String _getEmojiForLevel(LogLevel level) {
    switch (level) {
      case LogLevel.info:
        return '🔵';
      case LogLevel.debug:
        return '🔍';
      case LogLevel.warning:
        return '⚠️';
      case LogLevel.error:
        return '🔴';
      case LogLevel.success:
        return '✅';
    }
  }

  static String _getColorCodeForLevel(LogLevel level) {
    switch (level) {
      case LogLevel.info:
        return '\x1B[34m'; // Blue
      case LogLevel.debug:
        return '\x1B[36m'; // Cyan
      case LogLevel.warning:
        return '\x1B[33m'; // Yellow
      case LogLevel.error:
        return '\x1B[31m'; // Red
      case LogLevel.success:
        return '\x1B[32m'; // Green
    }
  }
}
