import 'package:flutter/foundation.dart';
import 'dart:async';

/// Centralized logging and performance monitoring service
class AppLogger {
  static const String _prefix = '[AgriShield]';
  static bool _isDebugMode = kDebugMode;

  /// Log info messages
  static void info(String message, {String? tag}) {
    final logMessage = '${_buildTimestamp()} $_prefix [INFO${_buildTag(tag)}] $message';
    _log(logMessage);
  }

  /// Log warning messages
  static void warn(String message, {String? tag}) {
    final logMessage = '${_buildTimestamp()} $_prefix [WARN${_buildTag(tag)}] $message';
    _log(logMessage);
  }

  /// Log error messages
  static void error(String message, dynamic exception, StackTrace? stackTrace, {String? tag}) {
    final logMessage = '''
${_buildTimestamp()} $_prefix [ERROR${_buildTag(tag)}] $message
Exception: $exception
${stackTrace ?? 'No stack trace'}
''';
    _log(logMessage);
  }

  /// Log debug messages (only in debug mode)
  static void debug(String message, {String? tag}) {
    if (_isDebugMode) {
      final logMessage = '${_buildTimestamp()} $_prefix [DEBUG${_buildTag(tag)}] $message';
      _log(logMessage);
    }
  }

  /// Log performance metrics
  static void performance(String operation, Duration duration, {String? tag}) {
    final ms = duration.inMilliseconds;
    final logMessage = '${_buildTimestamp()} $_prefix [PERF${_buildTag(tag)}] $operation: ${ms}ms';
    _log(logMessage);
    if (ms > 1000) {
      warn('Slow operation: $operation took ${ms}ms', tag: tag);
    }
  }

  static void _log(String message) {
    debugPrint(message);
  }

  static String _buildTimestamp() {
    final now = DateTime.now();
    return '${now.hour}:${now.minute}:${now.second}.${now.millisecond}';
  }

  static String _buildTag(String? tag) => tag != null ? ':$tag' : '';
}

/// Performance monitoring wrapper
class PerformanceMonitor {
  final String operation;
  final DateTime _startTime = DateTime.now();

  PerformanceMonitor(this.operation) {
    AppLogger.debug('Starting: $operation');
  }

  void complete({String? tag}) {
    final duration = DateTime.now().difference(_startTime);
    AppLogger.performance(operation, duration, tag: tag);
  }

  Future<T> trackAsync<T>(Future<T> Function() fn) async {
    try {
      final result = await fn();
      complete();
      return result;
    } catch (e, st) {
      AppLogger.error('Error in $operation', e, st);
      rethrow;
    }
  }
}

/// Global performance tracking
class PerformanceTracker {
  static final Map<String, List<Duration>> _metrics = {};

  static void record(String metric, Duration duration) {
    _metrics.putIfAbsent(metric, () => []).add(duration);
    AppLogger.debug('Recorded $metric: ${duration.inMilliseconds}ms');
  }

  static double getAverageDuration(String metric) {
    final durations = _metrics[metric];
    if (durations == null || durations.isEmpty) return 0;
    final total = durations.fold<int>(0, (sum, d) => sum + d.inMilliseconds);
    return total / durations.length;
  }

  static void printReport() {
    AppLogger.info('=== Performance Report ===');
    _metrics.forEach((metric, durations) {
      final avg = getAverageDuration(metric);
      AppLogger.info('$metric: avg=${avg.toStringAsFixed(2)}ms, count=${durations.length}');
    });
    AppLogger.info('========================');
  }

  static void reset() {
    _metrics.clear();
    AppLogger.info('Performance metrics reset');
  }
}
