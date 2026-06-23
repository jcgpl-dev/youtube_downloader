import '../../../../core/utils/cmd_runner.dart';
import '../../domain/entities/download_type.dart';
import '../../domain/entities/download_status.dart';
import '../models/download_progress_model.dart';

abstract class YtdlpLocalDataSource {
  Stream<DownloadStatus> streamDownload({
    required String url,
    required String outputPath,
    required DownloadType type,
  });
}

class YtdlpLocalDataSourceImpl implements YtdlpLocalDataSource {
  final CmdRunner cmdRunner;

  YtdlpLocalDataSourceImpl(this.cmdRunner);

  @override
  Stream<DownloadStatus> streamDownload({
    required String url,
    required String outputPath,
    required DownloadType type,
  }) async* {
    final List<String> arguments = [];

    if (type == DownloadType.mp3) {
      arguments.addAll(['-x', '--audio-format', 'mp3', '--audio-quality', '0']);
    } else {
      arguments.addAll([
        '-f',
        'bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best',
      ]);
    }

    arguments.addAll(['-o', '$outputPath/%(title)s.%(ext)s', '--newline', url]);

    yield const DownloadStatus(
      state: DownloadStatusState.initial,
      progress: 0.0,
    );

    double lastProgress = 0.0;

    try {
      final lineStream = cmdRunner.runCommandStream(
        command: 'yt-dlp',
        arguments: arguments,
      );

      await for (final line in lineStream) {
        final status = DownloadProgressModel.parseLine(line);
        if (status != null) {
          if (status.state == DownloadStatusState.failure) {
            yield status;
            return;
          }

          lastProgress = status.progress;
          yield status;
        }
      }

      yield const DownloadStatus(
        state: DownloadStatusState.success,
        progress: 1.0,
      );
    } catch (e) {
      yield DownloadStatus(
        state: DownloadStatusState.failure,
        errorMessage: e.toString(),
      );
    }
  }
}
