import '../../domain/entities/download_type.dart';
import '../../domain/entities/download_status.dart';
import '../../domain/repositories/downloader_repository.dart';
import '../datasources/ytdlp_local_datasource.dart';

class DownloaderRepositoryImpl implements DownloaderRepository {
  final YtdlpLocalDataSource localDataSource;

  DownloaderRepositoryImpl(this.localDataSource);

  @override
  Stream<DownloadStatus> downloadMedia({
    required String url,
    required String outputPath,
    required DownloadType type,
  }) {
    return localDataSource.streamDownload(
      url: url,
      outputPath: outputPath,
      type: type,
    );
  }
}
