enum DownloadStatusState { initial, downloading, success, failure }

class DownloadStatus {
  final DownloadStatusState state;
  final double progress;
  final String? downloadedSize;
  final String? totalSize;
  final String? speed;
  final String? eta;
  final String? errorMessage;

  const DownloadStatus({
    required this.state,
    this.progress = 0.0,
    this.downloadedSize,
    this.totalSize,
    this.speed,
    this.eta,
    this.errorMessage,
  });
}
