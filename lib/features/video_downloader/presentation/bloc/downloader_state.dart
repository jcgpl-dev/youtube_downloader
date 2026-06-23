import '../../domain/entities/download_type.dart';

abstract class DownloaderState {
  const DownloaderState();
}

class DownloaderInitial extends DownloaderState {}

class DownloadLoading extends DownloaderState {
  final double progress;
  final DownloadType type;

  const DownloadLoading({required this.progress, required this.type});
}

class DownloadSuccess extends DownloaderState {
  final DownloadType type;
  const DownloadSuccess({required this.type});
}

class DownloadFailure extends DownloaderState {
  final String message;
  const DownloadFailure({required this.message});
}
