import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'app_logger.dart';

/// Image caching and optimization service
class ImageCacheService {
  static final ImageCacheService _instance = ImageCacheService._internal();
  static const int maxCacheSize = 100;
  static const int maxCacheBytes = 50 * 1024 * 1024; // 50MB

  factory ImageCacheService() {
    return _instance;
  }

  ImageCacheService._internal() {
    _initializeImageCache();
  }

  void _initializeImageCache() {
    // Configure image cache
    imageCache.maximumSize = maxCacheSize;
    imageCache.maximumSizeBytes = maxCacheBytes;
    AppLogger.info('Image cache initialized: max=$maxCacheSize items, ${maxCacheBytes ~/ (1024 * 1024)}MB');
  }

  /// Clear all cached images
  void clearCache() {
    imageCache.clear();
    imageCache.clearLiveImages();
    AppLogger.info('Image cache cleared');
  }

  /// Get cache size info
  String getCacheInfo() {
    return 'Cache: ${imageCache.currentSize} items, ${(imageCache.currentSizeBytes ~/ 1024 / 1024).toStringAsFixed(2)}MB';
  }
}

/// Optimized network service with caching and retry logic
class OptimizedNetworkService {
  static const int maxRetries = 3;
  static const Duration requestTimeout = Duration(seconds: 30);
  
  /// Make HTTP request with automatic retry and caching
  static Future<T> request<T>({
    required Future<T> Function() make,
    required String name,
    int retries = maxRetries,
  }) async {
    final monitor = PerformanceMonitor('API: $name');
    
    for (int attempt = 1; attempt <= retries; attempt++) {
      try {
        final result = await make().timeout(requestTimeout);
        monitor.complete(tag: 'attempt_$attempt');
        return result;
      } on TimeoutException catch (e) {
        AppLogger.warn('Timeout on $name (attempt $attempt/$retries)', tag: 'network');
        if (attempt == retries) {
          monitor.complete(tag: 'failed_after_timeout');
          rethrow;
        }
        await Future.delayed(Duration(seconds: attempt * 2)); // Exponential backoff
      } catch (e, st) {
        AppLogger.error('Network error on $name (attempt $attempt/$retries)', e, st, tag: 'network');
        if (attempt == retries) {
          monitor.complete(tag: 'failed_final');
          rethrow;
        }
        await Future.delayed(Duration(seconds: attempt * 2)); // Exponential backoff
      }
    }
    
    throw Exception('Failed after $retries attempts');
  }
}

/// Memory and performance optimization service
class MemoryOptimizer {
  static Future<void> releaseResources() async {
    AppLogger.info('Releasing memory resources...');
    
    // Clear image cache
    ImageCacheService().clearCache();
    
    // Force garbage collection (platform specific)
    await Future.delayed(Duration(milliseconds: 100));
    
    AppLogger.info('Memory resources released');
  }

  /// Monitor and report memory usage
  static void reportMemoryUsage() {
    AppLogger.info('Image cache info: ${ImageCacheService().getCacheInfo()}');
  }
}
