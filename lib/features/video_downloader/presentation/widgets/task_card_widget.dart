import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/download_type.dart';
import '../bloc/downloader_bloc.dart';
import '../bloc/downloader_event.dart';
import '../bloc/downloader_state.dart';
import '../utils/downloader_utils.dart';

class TaskCardWidget extends StatelessWidget {
  final DownloaderState state;
  final ThemeData theme;
  final String activeDownloadUrl;
  final String outputPath;

  const TaskCardWidget({
    super.key,
    required this.state,
    required this.theme,
    required this.activeDownloadUrl,
    required this.outputPath,
  });

  @override
  Widget build(BuildContext context) {
    String title = 'PREPARING STREAM...';
    Widget statusIndicator = const SizedBox.shrink();
    double progressValue = 0.0;
    Color cardColor = theme.colorScheme.surfaceContainerHigh;

    String? eta;
    String? speed;
    String? sizeString;

    if (state is DownloadLoading) {
      final loadingState = state as DownloadLoading;
      title = loadingState.type == DownloadType.mp3
          ? 'Extracting Audio Resource...'
          : 'Downloading High-Res Video...';
      progressValue = loadingState.progress;

      eta = loadingState.eta;
      speed = loadingState.speed;
      if (loadingState.downloadedSize != null &&
          loadingState.totalSize != null) {
        sizeString =
            '${loadingState.downloadedSize} / ${loadingState.totalSize}';
      }

      statusIndicator = Text(
        '${(loadingState.progress * 100).toStringAsFixed(1)}%',
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.primary,
        ),
      );
    } else if (state is DownloadSuccess) {
      title = 'DOWNLOAD COMPLETE';
      progressValue = 1.0;
      cardColor = Colors.green.withOpacity(0.04);

      statusIndicator = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: 'Show in Folder',
            icon: Icon(
              Platform.isMacOS
                  ? Icons.folder_shared_outlined
                  : Icons.folder_open_sharp,
              color: theme.colorScheme.primary,
            ),
            onPressed: () => DownloaderUtils.openFolder(outputPath),
          ),
          const SizedBox(width: 4),
          IconButton(
            tooltip: 'Clear Task',
            icon: const Icon(Icons.clear_sharp, color: Colors.green),
            onPressed: () => context.read<DownloaderBloc>().add(
              const ResetMediaLoaderEvent(),
            ),
          ),
        ],
      );
    } else if (state is DownloadFailure) {
      final failureState = state as DownloadFailure;
      title = 'TASK EXECUTION FAILED';
      cardColor = theme.colorScheme.errorContainer.withOpacity(0.15);
      statusIndicator = IconButton(
        icon: const Icon(Icons.refresh_sharp, color: Colors.red),
        onPressed: () =>
            context.read<DownloaderBloc>().add(const ResetMediaLoaderEvent()),
      );
    }

    final thumbnailUrl = DownloaderUtils.getThumbnailUrl(activeDownloadUrl);

    return Container(
      key: ValueKey(state.runtimeType),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.zero,
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 140,
                height: 80,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  border: Border.all(color: theme.colorScheme.outlineVariant),
                ),
                child: thumbnailUrl != null
                    ? Image.network(
                        thumbnailUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Icon(
                              Icons.play_circle_outline_rounded,
                              color: theme.colorScheme.outline,
                              size: 28,
                            ),
                          );
                        },
                      )
                    : Center(
                        child: Icon(
                          Icons.video_file_outlined,
                          color: theme.colorScheme.outline,
                          size: 28,
                        ),
                      ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.link_rounded,
                          size: 14,
                          color: theme.colorScheme.outline,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            activeDownloadUrl,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.outline,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              statusIndicator,
            ],
          ),
          const SizedBox(height: 20),
          if (state is! DownloadFailure) ...[
            LinearProgressIndicator(
              value: progressValue,
              minHeight: 4,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(
                state is DownloadSuccess
                    ? Colors.green
                    : theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  sizeString ??
                      (state is DownloadSuccess ? 'Finished' : '-- / --'),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (state is DownloadLoading)
                  Row(
                    children: [
                      Icon(
                        Icons.speed_rounded,
                        size: 14,
                        color: theme.colorScheme.outline,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        speed ?? '0.00MiB/s',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.timer_outlined,
                        size: 14,
                        color: theme.colorScheme.outline,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        eta != null ? 'ETA $eta' : 'Estimating...',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ] else ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: theme.colorScheme.errorContainer.withOpacity(0.3),
              child: Text(
                (state as DownloadFailure).message,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
