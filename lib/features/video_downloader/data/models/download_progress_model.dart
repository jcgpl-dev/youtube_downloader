import '../../domain/entities/download_status.dart';

class DownloadProgressModel {
  static final RegExp _progressRegex = RegExp(r'\[download\]\s+(\d+\.\d+)%');
  static final RegExp _errorRegex = RegExp(r'ERROR:|ExtractError:');

  /// Parses raw stdout terminal strings from yt-dlp to map to a [DownloadStatus].
  static DownloadStatus? parseLine(String line) {
    if (_errorRegex.hasMatch(line)) {
      return DownloadStatus(
        state: DownloadStatusState.failure,
        errorMessage: line.replaceFirst(RegExp(r'.*ERROR:\s*'), '').trim(),
      );
    }

    final match = _progressRegex.firstMatch(line);
    if (match != null) {
      final progressStr = match.group(1);
      if (progressStr != null) {
        final progressValue = double.parse(progressStr) / 100.0;
        return DownloadStatus(
          state: DownloadStatusState.downloading,
          progress: progressValue,
        );
      }
    }

    return null;
  }
}
