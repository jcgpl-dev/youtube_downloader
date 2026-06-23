import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/download_type.dart';
import '../bloc/downloader_bloc.dart';
import '../bloc/downloader_event.dart';
import '../bloc/downloader_state.dart';

class DownloaderPage extends StatefulWidget {
  const DownloaderPage({super.key});

  @override
  State<DownloaderPage> createState() => _DownloaderPageState();
}

class _DownloaderPageState extends State<DownloaderPage> {
  final _urlController = TextEditingController();
  final _pathController = TextEditingController();
  DownloadType _selectedType = DownloadType.mp4;
  String _activeDownloadUrl =
      ''; // Tracks the active running download URL independent of input text field

  @override
  void initState() {
    super.initState();
    _pathController.text = _getDefaultDownloadsDirectory();
  }

  String _getDefaultDownloadsDirectory() {
    final String home =
        Platform.environment['USERPROFILE'] ??
        Platform.environment['HOME'] ??
        '';
    if (home.isNotEmpty) {
      final downloadPath = Directory('$home/Downloads');
      if (downloadPath.existsSync()) return downloadPath.path;
    }
    return '.';
  }

  @override
  void dispose() {
    _urlController.dispose();
    _pathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool isCompact = constraints.maxWidth < 800;

          if (isCompact) {
            return Column(
              children: [
                _buildSidebar(theme, isHorizontal: false),
                Expanded(child: _buildMainContent(theme)),
              ],
            );
          }

          return Row(
            children: [
              _buildSidebar(theme, isHorizontal: true),
              Expanded(child: _buildMainContent(theme)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSidebar(ThemeData theme, {required bool isHorizontal}) {
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
      selected: {_selectedType},
      onSelectionChanged: (set) => setState(() => _selectedType = set.first),
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
              controller: _pathController,
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
                  onPressed: isLoading || _urlController.text.trim().isEmpty
                      ? null
                      : () {
                          final targetUrl = _urlController.text.trim();
                          setState(() {
                            _activeDownloadUrl = targetUrl;
                          });
                          context.read<DownloaderBloc>().add(
                            StartDownloadEvent(
                              url: targetUrl,
                              outputPath: _pathController.text.trim(),
                              type: _selectedType,
                            ),
                          );
                          _urlController
                              .clear(); // Safe to wipe the input element instantly!
                        },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(ThemeData theme) {
    return Container(
      color: theme.colorScheme.surface,
      padding: const EdgeInsets.all(40.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Download Queue',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Paste a link below to fetch high-definition video assets.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _urlController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Enter YouTube URL...',
              prefixIcon: const Icon(Icons.link_rounded),
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHigh.withOpacity(
                0.5,
              ),
              border: const OutlineInputBorder(borderRadius: BorderRadius.zero),
            ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: BlocBuilder<DownloaderBloc, DownloaderState>(
              builder: (context, state) {
                if (state is DownloaderInitial) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.arrow_downward_rounded,
                          size: 36,
                          color: theme.colorScheme.outlineVariant,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No active tasks running',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 150),
                  child: _buildTaskCard(context, state, theme),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(
    BuildContext context,
    DownloaderState state,
    ThemeData theme,
  ) {
    String title = 'PREPARING STREAM...';
    Widget statusIndicator = const SizedBox.shrink();
    double progressValue = 0.0;
    Color cardColor = theme.colorScheme.surfaceContainerHigh;

    if (state is DownloadLoading) {
      title = _selectedType == DownloadType.mp3
          ? 'EXTRACTING AUDIO CONTEXT'
          : 'DOWNLOADING MEDIA RESOURCE';
      progressValue = state.progress;
      statusIndicator = Text(
        '${(state.progress * 100).toStringAsFixed(1)}%',
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      );
    } else if (state is DownloadSuccess) {
      title = 'DOWNLOAD COMPLETE';
      progressValue = 1.0;
      cardColor = Colors.green.withOpacity(0.05);
      statusIndicator = IconButton(
        icon: const Icon(Icons.clear_sharp, color: Colors.green),
        onPressed: () =>
            context.read<DownloaderBloc>().add(const ResetMediaLoaderEvent()),
      );
    } else if (state is DownloadFailure) {
      title = 'TASK EXECUTION FAILED';
      cardColor = theme.colorScheme.errorContainer.withOpacity(0.2);
      statusIndicator = IconButton(
        icon: const Icon(Icons.refresh_sharp, color: Colors.red),
        onPressed: () =>
            context.read<DownloaderBloc>().add(const ResetMediaLoaderEvent()),
      );
    }

    return Container(
      key: ValueKey(state.runtimeType),
      padding: const EdgeInsets.all(24),
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
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withOpacity(0.4),
                  borderRadius: BorderRadius.zero,
                ),
                child: Icon(
                  _selectedType == DownloadType.mp3
                      ? Icons.audiotrack_sharp
                      : Icons.movie_sharp,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _activeDownloadUrl,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              statusIndicator,
            ],
          ),
          const SizedBox(height: 24),
          if (state is! DownloadFailure) ...[
            LinearProgressIndicator(
              value: state is DownloadSuccess ? 1.0 : progressValue,
              minHeight: 4,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.zero,
            ),
          ] else ...[
            Text(
              (state).message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
