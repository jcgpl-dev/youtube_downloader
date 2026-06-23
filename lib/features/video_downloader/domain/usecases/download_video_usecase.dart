import '../entities/download_type.dart';
import '../repositories/downloader_repository.dart';

class DownloadVideoUseCase {
  final DownloaderRepository repository;

  DownloadVideoUseCase(this.repository);

  Stream<double> call({
    required String url,
    required String outputPath,
    required DownloadType type,
  }) {
    return repository.downloadMedia(
      url: url,
      outputPath: outputPath,
      type: type,
    );
  }
}
