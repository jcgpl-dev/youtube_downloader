import '../../domain/entities/download_type.dart';

abstract class DownloaderState {
  const DownloaderState();
}

class DownloaderInitial extends DownloaderState {}

class DownloadLoading extends DownloaderState {
  final double progress;
  final DownloadType type;
  final String? downloadedSize;
  final String? totalSize;
  final String? speed;
  final String? eta;

  const DownloadLoading({
    required this.progress,
    required this.type,
    this.downloadedSize,
    this.totalSize,
    this.speed,
    this.eta,
  });
}

class DownloadSuccess extends DownloaderState {
  final DownloadType type;
  const DownloadSuccess(this.type);
}

class DownloadFailure extends DownloaderState {
  final String message;
  const DownloadFailure(this.message);
}
