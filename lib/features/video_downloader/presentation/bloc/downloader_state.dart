abstract class DownloaderState {
  const DownloaderState();
}

class DownloaderInitial extends DownloaderState {}

class DownloadLoading extends DownloaderState {
  final double progress;
  const DownloadLoading({required this.progress});
}

class DownloadSuccess extends DownloaderState {}

class DownloadFailure extends DownloaderState {
  final String message;
  const DownloadFailure({required this.message});
}
