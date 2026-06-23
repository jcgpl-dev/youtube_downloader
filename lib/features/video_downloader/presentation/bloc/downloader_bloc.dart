import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/download_video_usecase.dart';
import '../../domain/entities/download_status.dart';
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
      emit(DownloadLoading(progress: 0.0, type: event.type));

      try {
        final statusStream = downloadVideoUseCase(
          url: event.url,
          outputPath: event.outputPath,
          type: event.type,
        );

        await emit.forEach<DownloadStatus>(
          statusStream,
          onData: (status) {
            switch (status.state) {
              case DownloadStatusState.initial:
                return DownloadLoading(progress: 0.0, type: event.type);
              case DownloadStatusState.downloading:
                return DownloadLoading(
                  progress: status.progress,
                  type: event.type,
                  downloadedSize: status.downloadedSize,
                  totalSize: status.totalSize,
                  speed: status.speed,
                  eta: status.eta,
                );
              case DownloadStatusState.success:
                return DownloadSuccess(event.type);
              case DownloadStatusState.failure:
                return DownloadFailure(
                  status.errorMessage ?? 'Unknown extraction error.',
                );
            }
          },
          onError: (error, stackTrace) => DownloadFailure(error.toString()),
        );
      } catch (e) {
        emit(DownloadFailure(e.toString()));
      }
    });
  }
}
