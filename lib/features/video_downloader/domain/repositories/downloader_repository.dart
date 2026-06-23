import '../../domain/entities/download_type.dart';

abstract class DownloaderRepository {
  Stream<double> downloadMedia({
    required String url,
    required String outputPath,
    required DownloadType type,
  });
}
