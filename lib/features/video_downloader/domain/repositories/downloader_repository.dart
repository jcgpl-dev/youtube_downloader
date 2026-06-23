import '../entities/download_type.dart';
import '../entities/download_status.dart';

abstract class DownloaderRepository {
  Stream<DownloadStatus> downloadMedia({
    required String url,
    required String outputPath,
    required DownloadType type,
  });
}
