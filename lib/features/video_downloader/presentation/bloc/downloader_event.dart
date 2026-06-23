import '../../domain/entities/download_type.dart';

abstract class DownloaderEvent {
  const DownloaderEvent();
}

class StartDownloadEvent extends DownloaderEvent {
  final String url;
  final String outputPath;
  final DownloadType type;

  const StartDownloadEvent({
    required this.url,
    required this.outputPath,
    required this.type,
  });
}

class ResetMediaLoaderEvent extends DownloaderEvent {
  const ResetMediaLoaderEvent();
}
