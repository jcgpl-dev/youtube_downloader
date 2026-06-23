// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';

import 'core/utils/cmd_runner.dart';
import 'features/video_downloader/data/datasources/ytdlp_local_datasource.dart';
import 'features/video_downloader/data/repositories/downloader_repository_impl.dart';
import 'features/video_downloader/domain/repositories/downloader_repository.dart';
import 'features/video_downloader/domain/usecases/download_video_usecase.dart';
import 'features/video_downloader/presentation/bloc/downloader_bloc.dart';
import 'features/video_downloader/presentation/pages/downloader_page.dart';

final sl = GetIt.instance;

void initDependencyInjection() {
  sl.registerLazySingleton(() => CmdRunner());
  sl.registerLazySingleton<YtdlpLocalDataSource>(
    () => YtdlpLocalDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<DownloaderRepository>(
    () => DownloaderRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => DownloadVideoUseCase(sl()));
  sl.registerFactory(() => DownloaderBloc(downloadVideoUseCase: sl()));
}

void main() {
  initDependencyInjection();
  runApp(const MyApp());

  // Configure bitsdojo_window constraints and display parameters
  doWhenWindowReady(() {
    const initialSize = Size(900, 600);
    appWindow.minSize = const Size(760, 500);
    appWindow.size = initialSize;
    appWindow.alignment = Alignment.center;
    appWindow.title = "Media Loader";
    appWindow.show();
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final baseTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.redAccent,
        brightness:
            Brightness.dark, // Embracing a sleek dark mode for a sharp UI
      ),
    );

    // Custom sharp colors for the system buttons window controls
    final buttonColors = WindowButtonColors(
      iconNormal: baseTheme.colorScheme.onSurface,
      mouseOver: baseTheme.colorScheme.surfaceContainerHigh,
      mouseDown: baseTheme.colorScheme.surfaceContainerHighest,
      iconMouseOver: baseTheme.colorScheme.primary,
      iconMouseDown: baseTheme.colorScheme.primary,
    );

    final closeButtonColors = WindowButtonColors(
      mouseOver: const Color(0xFFD32F2F),
      mouseDown: const Color(0xFFB71C1C),
      iconNormal: baseTheme.colorScheme.onSurface,
      iconMouseOver: Colors.white,
    );

    return MaterialApp(
      title: 'Media Loader',
      debugShowCheckedModeBanner: false,
      theme: baseTheme,
      home: Scaffold(
        body: WindowBorder(
          color: baseTheme.colorScheme.outlineVariant,
          width: 1,
          child: Column(
            children: [
              // Sharp Custom Titlebar
              Container(
                color: baseTheme.colorScheme.surfaceContainerLow,
                height: 32,
                child: MoveWindow(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 12.0),
                        child: Text(
                          'MEDIA LOADER CLI WRAPPER',
                          style: baseTheme.textTheme.labelSmall?.copyWith(
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.w600,
                            color: baseTheme.colorScheme.outline,
                          ),
                        ),
                      ),
                      // Window Navigation controls
                      Row(
                        children: [
                          MinimizeWindowButton(colors: buttonColors),
                          MaximizeWindowButton(colors: buttonColors),
                          CloseWindowButton(colors: closeButtonColors),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // Entire Core Application View underneath
              Expanded(
                child: BlocProvider(
                  create: (_) => sl<DownloaderBloc>(),
                  child: const DownloaderPage(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
