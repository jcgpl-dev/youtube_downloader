// lib/main.dart
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import 'core/presentation/widgets/custom_window_title_bar.dart';
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
    final darkTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.redAccent,
        brightness: Brightness.dark,
      ),
    );

    return MaterialApp(
      title: 'Media Loader',
      debugShowCheckedModeBanner: false,
      theme: darkTheme,
      home: Scaffold(
        body: WindowBorder(
          color: darkTheme.colorScheme.outlineVariant,
          width: 1,
          child: Column(
            children: [
              const CustomWindowTitleBar(),
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
