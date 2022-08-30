import 'package:claps_api_client/claps_api_client.dart' as api_client;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:videos_repository/videos_repository.dart';

part 'home_cubit.freezed.dart';
part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._videosRepository) : super(const HomeState());

  final VideosRepository _videosRepository;

  void currentItemIndexChanged(int value) {
    emit(
      state.copyWith(currentItemIndex: value),
    );
  }

  Future<void> getVideos() async {
    emit(state.copyWith(status: const HomeStatus.loading()));
    try {
      await _videosRepository.getVideos();
    } on api_client.VideoFeedRequestException {
      emit(
        state.copyWith(
          status: const HomeStatus.failure('Error requesting the video feed'),
        ),
      );
    } on api_client.VideoFeedNotFoundException {
      emit(
        state.copyWith(
          status: const HomeStatus.failure('Video feed not found'),
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: const HomeStatus.failure(
            'Something went wrong, please try again',
          ),
        ),
      );
    }
  }
}
