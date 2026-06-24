import 'package:flutter/material.dart';
import 'package:youtube_downloader/core/presentation/widgets/app_brand.dart';
import '../../domain/entities/download_type.dart';

class SidebarWidget extends StatelessWidget {
  final ThemeData theme;
  final bool isHorizontal;
  final TextEditingController pathController;
  final DownloadType selectedType;
  final ValueChanged<DownloadType> onTypeChanged;

  const SidebarWidget({
    super.key,
    required this.theme,
    required this.isHorizontal,
    required this.pathController,
    required this.selectedType,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final formatSelector = SegmentedButton<DownloadType>(
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
      padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 24.0),
      child: Flex(
        direction: isHorizontal ? Axis.vertical : Axis.horizontal,
        crossAxisAlignment: isHorizontal
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          AppBrandWidget(theme: theme),
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
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.folder_open_rounded, size: 20),
              ),
            ),
          ),

          const Spacer(),

          if (isHorizontal) const SizedBox(height: 16),
          Text(
            'Developed by Jesie Gapol',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.outline,
              fontSize: 10,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
