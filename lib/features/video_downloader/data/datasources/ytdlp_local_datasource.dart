import '../../../../core/utils/cmd_runner.dart';
import '../../domain/entities/download_type.dart';
import '../models/download_progress_model.dart';

abstract class YtdlpLocalDataSource {
  Stream<double> streamDownload({
    required String url,
    required String outputPath,
    required DownloadType type,
  });
}

class YtdlpLocalDataSourceImpl implements YtdlpLocalDataSource {
  final CmdRunner cmdRunner;

  YtdlpLocalDataSourceImpl(this.cmdRunner);

  @override
  Stream<double> streamDownload({
    required String url,
    required String outputPath,
    required DownloadType type,
  }) async* {
    final List<String> arguments = [];

    if (type == DownloadType.mp3) {
      arguments.addAll([
        '-x',
        '--audio-format', 'mp3',
        '--audio-quality', '0', // Best quality VBR
        '-o', '$outputPath/%(title)s.%(ext)s',
        url,
      ]);
    } else {
      arguments.addAll([
        '-f',
        'bv*[ext=mp4][height<=1080]+ba[ext=m4a]/b[ext=mp4]',
        '--merge-output-format',
        'mp4',
        '-o',
        '$outputPath/%(title)s.%(ext)s',
        url,
      ]);
    }

    final outputStream = cmdRunner.runCommandStream(
      command: 'yt-dlp',
      arguments: arguments,
    );

    await for (final line in outputStream) {
      final progress = DownloadProgressModel.parseProgress(line);
      if (progress != null) {
        yield progress;
      }
    }
  }
}
