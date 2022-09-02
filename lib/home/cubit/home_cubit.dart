import 'package:claps_api_client/claps_api_client.dart' as api_client;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:video_player/video_player.dart';
import 'package:videos_repository/videos_repository.dart';

part 'home_cubit.freezed.dart';
part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._videosRepository) : super(const HomeState());

  final int _initialVideosLoaded = 4;
  final VideosRepository _videosRepository;

  void currentItemIndexChanged(int value) {
    emit(
      state.copyWith(currentItemIndex: value),
    );
  }

  Future<void> getVideos() async {
    emit(state.copyWith(status: const HomeStatus.loading()));
    try {
      final result = await _videosRepository.getVideos();
      final videos = result
          .map((item) => VideoPlayerController.network(item.url))
          .toList();
      for (var i = 0; i < _initialVideosLoaded; i++) {
        await videos[i].initialize();
      }
      emit(
        state.copyWith(
          videos: videos,
          status: const HomeStatus.success(),
        ),
      );
    } on api_client.VideoFeedRequestException {
      const message = 'Error requesting the video feed';
      emit(state.copyWith(status: const HomeStatus.failure(message)));
    } on api_client.VideoFeedNotFoundException {
      const message = 'Video feed not found';
      emit(state.copyWith(status: const HomeStatus.failure(message)));
    } catch (_) {
      const message = 'Something went wrong, please try again';
      emit(state.copyWith(status: const HomeStatus.failure(message)));
    }
  }

  Future<void> getMoreVideos() async {
    try {
      final videos = await _videosRepository.getVideos();
      final newVideos = videos
          .map((item) => VideoPlayerController.network(item.url))
          .toList();
      emit(state.copyWith(videos: [...state.videos, ...newVideos]));
    } on api_client.VideoFeedRequestException {
      const message = 'Error requesting the video feed';
      emit(state.copyWith(status: const HomeStatus.failure(message)));
    } on api_client.VideoFeedNotFoundException {
      const message = 'Video feed not found';
      emit(state.copyWith(status: const HomeStatus.failure(message)));
    } catch (_) {
      const message = 'Something went wrong, please try again';
      emit(state.copyWith(status: const HomeStatus.failure(message)));
    }
  }

  @override
  Future<void> close() {
    for (final video in state.videos) {
      video.dispose();
    }
    return super.close();
  }
}
