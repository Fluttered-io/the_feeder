part of 'home_cubit.dart';

@freezed
class HomeState with _$HomeState {
  const factory HomeState({
    @Default(HomeStatus.initial()) HomeStatus status,
    @Default(0) int currentItemIndex,
    @Default([]) List<VideoPlayerController> videos,
  }) = _HomeState;
}

@freezed
class HomeStatus with _$HomeStatus {
  const factory HomeStatus.initial() = Initial;

  const factory HomeStatus.loading() = Loading;

  const factory HomeStatus.success() = Success;

  const factory HomeStatus.failure(String message) = Failure;
}

extension HomeStatusExtension on HomeStatus {
  bool get isInitial => this is Initial;

  bool get isLoading => this is Loading;

  bool get isSuccess => this is Success;

  bool get isFailure => this is Failure;
}
