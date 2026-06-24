import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/download_type.dart';
import '../bloc/downloader_bloc.dart';
import '../bloc/downloader_state.dart';
import '../utils/downloader_utils.dart';
import '../widgets/sidebar_widget.dart';
import '../widgets/task_card_widget.dart';

class DownloaderPage extends StatefulWidget {
  const DownloaderPage({super.key});

  @override
  State<DownloaderPage> createState() => _DownloaderPageState();
}

class _DownloaderPageState extends State<DownloaderPage> {
  final _urlController = TextEditingController();
  final _pathController = TextEditingController();
  DownloadType _selectedType = DownloadType.mp4;
  String _activeDownloadUrl = '';

  @override
  void initState() {
    super.initState();
    _pathController.text = DownloaderUtils.getDefaultDownloadsDirectory();
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
    return SidebarWidget(
      theme: theme,
      isHorizontal: isHorizontal,
      urlController: _urlController,
      pathController: _pathController,
      selectedType: _selectedType,
      onTypeChanged: (type) => setState(() => _selectedType = type),
      onDownloadStarted: (url) => setState(() => _activeDownloadUrl = url),
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
                  child: TaskCardWidget(
                    state: state,
                    theme: theme,
                    activeDownloadUrl: _activeDownloadUrl,
                    outputPath: _pathController.text.trim(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
