import '../../domain/entities/download_status.dart';

class DownloadProgressModel {
  static final RegExp _progressRegex = RegExp(
    r'\[download\]\s+(\d+\.\d+)%\s+of\s+(\d+\.\d+\w+)\s+at\s+(\d+\.\d+\w+\/s)\s+ETA\s+(\d+:\d+)',
  );
  static final RegExp _errorRegex = RegExp(r'ERROR:|ExtractError:');

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
      final totalSizeStr = match.group(2);
      final speedStr = match.group(3);
      final etaStr = match.group(4);

      if (progressStr != null) {
        final progressValue = double.parse(progressStr) / 100.0;

        String? downloadedSizeStr;
        if (totalSizeStr != null) {
          final sizeMetric = _parseSizeMetric(totalSizeStr);
          if (sizeMetric != null) {
            final downloadedRaw = sizeMetric.value * progressValue;
            downloadedSizeStr =
                '${downloadedRaw.toStringAsFixed(1)}${sizeMetric.unit}';
          }
        }

        return DownloadStatus(
          state: DownloadStatusState.downloading,
          progress: progressValue,
          totalSize: totalSizeStr,
          downloadedSize: downloadedSizeStr,
          speed: speedStr,
          eta: etaStr,
        );
      }
    }

    return null;
  }

  static _SizeMetric? _parseSizeMetric(String sizeStr) {
    final match = RegExp(r'(\d+\.\d+)(\w+)').firstMatch(sizeStr);
    if (match != null) {
      return _SizeMetric(
        value: double.tryParse(match.group(1) ?? '') ?? 0.0,
        unit: match.group(2) ?? '',
      );
    }
    return null;
  }
}

class _SizeMetric {
  final double value;
  final String unit;
  _SizeMetric({required this.value, required this.unit});
}
