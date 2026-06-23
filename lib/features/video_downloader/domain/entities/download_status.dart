enum DownloadStatusState { initial, downloading, success, failure }

class DownloadStatus {
  final DownloadStatusState state;
  final double progress;
  final String? errorMessage;

  const DownloadStatus({
    required this.state,
    this.progress = 0.0,
    this.errorMessage,
  });
}
