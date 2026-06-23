class DownloadProgressModel {
  static final RegExp _progressRegex = RegExp(r'\[download\]\s+(\d+\.\d+)%');

  /// Parses raw stdout terminal strings from yt-dlp to find progress percentages.
  static double? parseProgress(String line) {
    final match = _progressRegex.firstMatch(line);
    if (match != null) {
      final progressStr = match.group(1);
      if (progressStr != null) {
        return double.parse(progressStr) / 100.0; // Normalizes to 0.0 - 1.0
      }
    }
    return null;
  }
}
