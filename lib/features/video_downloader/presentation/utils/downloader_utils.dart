import 'dart:io';
import 'package:flutter/foundation.dart';

class DownloaderUtils {
  /// Opens the Windows File Explorer pointing explicitly to the target directory.
  static Future<void> openFolder(String path) async {
    if (!Platform.isWindows) return;

    final normalizedPath = path.replaceAll('/', '\\');

    try {
      final directory = Directory(normalizedPath);
      if (await directory.exists()) {
        await Process.run('explorer.exe', [normalizedPath]);
      } else {
        debugPrint('Directory does not exist: $normalizedPath');
      }
    } catch (e) {
      debugPrint('Failed to open Windows Explorer: $e');
    }
  }

  /// Finds or generates the nested custom default download target folder structure.
  static String getDefaultDownloadsDirectory() {
    final String home =
        Platform.environment['USERPROFILE'] ??
        Platform.environment['HOME'] ??
        '';

    if (home.isNotEmpty) {
      final baseDownloadsDir = Directory('$home/Downloads');

      if (baseDownloadsDir.existsSync()) {
        final customTargetDir = Directory(
          '${baseDownloadsDir.path}/Youtube Downloads',
        );

        try {
          customTargetDir.createSync(recursive: true);
          return customTargetDir.path;
        } catch (e) {
          return baseDownloadsDir.path;
        }
      }
    }
    return '.';
  }

  /// Extracts the standard YouTube 11-character video ID using Regex patterns.
  static String? extractVideoId(String url) {
    if (url.isEmpty) return null;
    final regExp = RegExp(
      r'(?:https?:\/\/)?(?:www\.)?(?:youtube\.com\/(?:[^\/\n\s]+\/\S+\/|(?:v|e(?:mbed)?)\/|\S*?[?&]v=)|youtu\.be\/)([a-zA-Z0-9_-]{11})',
    );
    final match = regExp.firstMatch(url);
    return match?.group(1);
  }

  /// Constructs the high-quality video thumbnail network endpoint asset target.
  static String? getThumbnailUrl(String url) {
    final videoId = extractVideoId(url);
    if (videoId == null) return null;
    return 'https://img.youtube.com/vi/$videoId/hqdefault.jpg';
  }
}
