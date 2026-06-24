import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/download_type.dart';
import '../bloc/downloader_bloc.dart';
import '../bloc/downloader_event.dart';
import '../bloc/downloader_state.dart';

class SidebarWidget extends StatelessWidget {
  final ThemeData theme;
  final bool isHorizontal;
  final TextEditingController urlController;
  final TextEditingController pathController;
  final DownloadType selectedType;
  final ValueChanged<DownloadType> onTypeChanged;
  final ValueChanged<String> onDownloadStarted;

  const SidebarWidget({
    super.key,
    required this.theme,
    required this.isHorizontal,
    required this.urlController,
    required this.pathController,
    required this.selectedType,
    required this.onTypeChanged,
    required this.onDownloadStarted,
  });

  @override
  Widget build(BuildContext context) {
    final formatSelector = SegmentedButton<DownloadType>(
      style: SegmentedButton.styleFrom(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),
      segments: const [
        ButtonSegment(
          value: DownloadType.mp4,
          label: Text('VIDEO (MP4)'),
          icon: Icon(Icons.movie_outlined),
        ),
        ButtonSegment(
          value: DownloadType.mp3,
          label: Text('AUDIO (MP3)'),
          icon: Icon(Icons.audiotrack_outlined),
        ),
      ],
      selected: {selectedType},
      onSelectionChanged: (set) => onTypeChanged(set.first),
    );

    return Container(
      width: isHorizontal ? 320 : double.infinity,
      color: theme.colorScheme.surfaceContainerLow,
      padding: const EdgeInsets.all(24.0),
      child: Flex(
        direction: isHorizontal ? Axis.vertical : Axis.horizontal,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.video_library_rounded,
                color: theme.colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'MEDIA LOADER',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          if (isHorizontal)
            const SizedBox(height: 32)
          else
            const SizedBox(width: 32),
          if (isHorizontal) ...[
            Text(
              'FORMAT PRESET',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
            const SizedBox(height: 8),
          ],
          formatSelector,
          if (isHorizontal)
            const SizedBox(height: 24)
          else
            const SizedBox(width: 24),
          if (isHorizontal) ...[
            Text(
              'OUTPUT TARGET',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
            const SizedBox(height: 8),
          ],
          Expanded(
            flex: isHorizontal ? 0 : 1,
            child: TextField(
              controller: pathController,
              style: theme.textTheme.bodyMedium,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.folder_open_rounded, size: 20),
                filled: true,
                fillColor: theme.colorScheme.surface,
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.zero,
                ),
              ),
            ),
          ),
          if (isHorizontal) const Spacer() else const SizedBox(width: 16),
          BlocBuilder<DownloaderBloc, DownloaderState>(
            builder: (context, state) {
              final isLoading = state is DownloadLoading;
              return SizedBox(
                width: isHorizontal ? double.infinity : 160,
                height: 48,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  icon: isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.download_rounded),
                  label: Text(isLoading ? 'RUNNING...' : 'FETCH MEDIA'),
                  onPressed: isLoading || urlController.text.trim().isEmpty
                      ? null
                      : () {
                          final targetUrl = urlController.text.trim();
                          onDownloadStarted(targetUrl);
                          context.read<DownloaderBloc>().add(
                            StartDownloadEvent(
                              url: targetUrl,
                              outputPath: pathController.text.trim(),
                              type: selectedType,
                            ),
                          );
                          urlController.clear();
                        },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
