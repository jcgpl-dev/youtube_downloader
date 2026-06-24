import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube_downloader/core/presentation/widgets/custom_window_title_bar.dart';
import '../../domain/entities/download_type.dart';
import '../bloc/downloader_bloc.dart';
import '../bloc/downloader_event.dart';
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

  Future<void> _pasteFromClipboard() async {
    final ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data != null && data.text != null) {
      setState(() {
        _urlController.text = data.text!;
      });
    }
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
      pathController: _pathController,
      selectedType: _selectedType,
      onTypeChanged: (type) => setState(() => _selectedType = type),
    );
  }

  Widget _buildMainContent(ThemeData theme) {
    return Column(
      children: [
        const CustomWindowTitleBar(),
        Expanded(
          child: Container(
            color: theme.colorScheme.surface,
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Download Queue', style: theme.textTheme.headlineMedium),

                Text(
                  'Paste a link below to fetch high-definition video assets.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),
                BlocBuilder<DownloaderBloc, DownloaderState>(
                  builder: (context, state) {
                    final isLoading = state is DownloadLoading;
                    final isUrlEmpty = _urlController.text.trim().isEmpty;
                    final isButtonDisabled = isLoading || isUrlEmpty;

                    return Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _urlController,
                            style: theme.textTheme.bodyMedium,
                            onChanged: (_) => setState(() {}),
                            decoration: InputDecoration(
                              hintText: 'Enter YouTube URL...',
                              prefixIcon: const Icon(Icons.link_rounded),
                              suffixIcon: IconButton(
                                icon: const Icon(
                                  Icons.content_paste_rounded,
                                  size: 20,
                                ),
                                tooltip: 'Paste Link',
                                onPressed: _pasteFromClipboard,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          height: 48,
                          child: FilledButton.icon(
                            style:
                                FilledButton.styleFrom(
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.zero,
                                  ),
                                ).copyWith(
                                  // Dynamically swap foreground colors based on internal Button states
                                  foregroundColor:
                                      WidgetStateProperty.resolveWith<Color>((
                                        states,
                                      ) {
                                        if (states.contains(
                                          WidgetState.disabled,
                                        )) {
                                          return const Color(
                                            0xFF7C8596,
                                          ); // textMuted
                                        }
                                        return const Color(
                                          0xFFFFFFFF,
                                        ); // textPrimary
                                      }),
                                  iconColor:
                                      WidgetStateProperty.resolveWith<Color>((
                                        states,
                                      ) {
                                        if (states.contains(
                                          WidgetState.disabled,
                                        )) {
                                          return const Color(
                                            0xFF7C8596,
                                          ); // textMuted
                                        }
                                        return const Color(
                                          0xFFFFFFFF,
                                        ); // textPrimary
                                      }),
                                ),
                            icon: isLoading
                                ? SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      // Track the exact same disabled/enabled state color for the progress bar
                                      color: isButtonDisabled
                                          ? const Color(0xFF7C8596)
                                          : const Color(0xFFFFFFFF),
                                    ),
                                  )
                                : const Icon(Icons.download_rounded),
                            label: Text(
                              isLoading ? 'RUNNING...' : 'DOWNLOAD',
                              style: theme.textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: isButtonDisabled
                                    ? const Color(0xFF7C8596)
                                    : const Color(0xFFFFFFFF),
                              ),
                            ),
                            onPressed: isButtonDisabled
                                ? null
                                : () {
                                    final targetUrl = _urlController.text
                                        .trim();
                                    setState(
                                      () => _activeDownloadUrl = targetUrl,
                                    );

                                    context.read<DownloaderBloc>().add(
                                      StartDownloadEvent(
                                        url: targetUrl,
                                        outputPath: _pathController.text.trim(),
                                        type: _selectedType,
                                      ),
                                    );
                                    _urlController.clear();
                                  },
                          ),
                        ),
                      ],
                    );
                  },
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
          ),
        ),
      ],
    );
  }
}
