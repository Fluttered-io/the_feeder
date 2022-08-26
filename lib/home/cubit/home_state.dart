part of 'home_cubit.dart';

@freezed
class HomeState with _$HomeState {
  factory HomeState({
    required HomeStatus status,
    required int currentItemIndex,
  }) = _HomeState;

  const HomeState._();

  factory HomeState.initial() {
    return HomeState(
      status: const HomeStatus.initial(),
      currentItemIndex: 0,
    );
  }
}

@freezed
class HomeStatus with _$HomeStatus {
  const factory HomeStatus.initial() = Initial;

  const factory HomeStatus.loading() = Loading;

  const factory HomeStatus.success() = Success;

  const factory HomeStatus.failure(Error error) = Failure;
}

extension HomeStatusExtension on HomeStatus {
  bool get isInitial => this is Initial;

  bool get isLoading => this is Loading;

  bool get isSuccess => this is Success;

  bool get isFailure => this is Failure;
}
