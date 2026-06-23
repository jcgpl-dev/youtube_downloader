import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/download_video_usecase.dart';
import 'downloader_event.dart';
import 'downloader_state.dart';

class DownloaderBloc extends Bloc<DownloaderEvent, DownloaderState> {
  final DownloadVideoUseCase downloadVideoUseCase;

  DownloaderBloc({required this.downloadVideoUseCase})
    : super(DownloaderInitial()) {
    on<ResetMediaLoaderEvent>((event, emit) {
      emit(DownloaderInitial());
    });

    on<StartDownloadEvent>((event, emit) async {
      emit(const DownloadLoading(progress: 0.0));

      try {
        final progressStream = downloadVideoUseCase(
          url: event.url,
          outputPath: event.outputPath,
          type: event.type,
        );

        await emit.forEach<double>(
          progressStream,
          onData: (progress) {
            if (progress >= 1.0) return DownloadSuccess();
            return DownloadLoading(progress: progress);
          },
          onError: (error, stackTrace) =>
              DownloadFailure(message: error.toString()),
        );
      } catch (e) {
        emit(DownloadFailure(message: e.toString()));
      }
    });
  }
}
