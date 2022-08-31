import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:the_feeder/home/home.dart';
import 'package:video_player/video_player.dart';

/// Enum to track the current state of manual dragging or animation
enum DragState {
  idle,
  dragging,
  animatingForward,
  animatingBackward,
  animatingToCancel,
}

class Feed extends StatefulWidget {
  const Feed({super.key});

  /// The amount of screen that has to be scrolled to animate the item to the
  /// next or previous position.
  static const double swipePositionThreshold = 0.2;

  /// It will override the [swipePositionThreshold] if the item is dragged
  /// quickly.
  static const double swipeVelocityThreshold = 1000;

  static const Duration animationDuration = Duration(milliseconds: 400);

  @override
  State<Feed> createState() => _FeedState();
}

class _FeedState extends State<Feed> with SingleTickerProviderStateMixin {
  late Size _containerSize;
  late double _currentItemOffset;
  late double _dragStartPosition;
  late DragState _dragState;
  late Animation<double> _animation;
  late AnimationController _animationController;
  late VideoPlayerController _previousVideoController;
  late VideoPlayerController _currentVideoController;
  late VideoPlayerController _nextVideoController;

  /// Internal index for tracking desired controller target page index
  int _targetIndex = -1;

  @override
  void initState() {
    _currentItemOffset = 0;
    _dragStartPosition = 0;
    _dragState = DragState.idle;
    _animationController = AnimationController(
      vsync: this,
      duration: Feed.animationDuration,
    );
    _previousVideoController = VideoPlayerController.network('');
    _currentVideoController = VideoPlayerController.network('');
    _nextVideoController = VideoPlayerController.network('');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        _containerSize = constraints.biggest;
        return BlocConsumer<HomeCubit, HomeState>(
          listenWhen: (previous, current) => current.status != previous.status,
          buildWhen: (previous, current) => current.status != previous.status,
          listener: (BuildContext context, HomeState state) {
            final currentItemIndex = state.currentItemIndex;
            if (state.status.isSuccess) {
              _currentVideoController = VideoPlayerController.network(
                state.videos[currentItemIndex].url,
              );
              if (currentItemIndex < state.videos.length - 1) {
                _nextVideoController = VideoPlayerController.network(
                  state.videos[currentItemIndex + 1].url,
                );
              }
              _currentVideoController.initialize().then((_) {
                _currentVideoController
                  ..setLooping(true)
                  ..play();
                setState(() {});
              });
              _nextVideoController.initialize().then((_) {
                _nextVideoController.setLooping(true);
                setState(() {});
              });
            }
          },
          builder: (BuildContext context, HomeState state) {
            return state.status.isSuccess
                ? MultiBlocListener(
                    listeners: [
                      BlocListener<HomeCubit, HomeState>(
                        listenWhen: (previous, current) =>
                            current.currentItemIndex >
                            previous.currentItemIndex,
                        listener: (BuildContext context, HomeState state) {
                          final currentItemIndex = state.currentItemIndex;
                          if (currentItemIndex > 0) {
                            _previousVideoController =
                                VideoPlayerController.network(
                              state.videos[currentItemIndex - 1].url,
                            );
                            _previousVideoController.initialize().then((_) {
                              _previousVideoController.setLooping(true);
                              setState(() {});
                            });
                          }
                          _currentVideoController.dispose();
                          _currentVideoController = _nextVideoController
                            ..play();
                          _nextVideoController = VideoPlayerController.network(
                            state.videos[currentItemIndex + 1].url,
                          )..initialize().then((_) {
                              _nextVideoController.setLooping(true);
                              setState(() {});
                            });
                        },
                      ),
                      BlocListener<HomeCubit, HomeState>(
                        listenWhen: (previous, current) =>
                            current.currentItemIndex <
                            previous.currentItemIndex,
                        listener: (BuildContext context, HomeState state) {
                          final currentItemIndex = state.currentItemIndex;
                          if (currentItemIndex < state.videos.length - 1) {
                            _nextVideoController =
                                VideoPlayerController.network(
                              state.videos[currentItemIndex + 1].url,
                            );
                            _nextVideoController.initialize().then((_) {
                              _nextVideoController.setLooping(true);
                              setState(() {});
                            });
                          }
                          _currentVideoController.dispose();
                          _currentVideoController = _previousVideoController
                            ..play();
                          _previousVideoController =
                              VideoPlayerController.network(
                            state.videos[currentItemIndex - 1].url,
                          )..initialize().then((_) {
                                  _previousVideoController.setLooping(true);
                                  setState(() {});
                                });
                        },
                      ),
                    ],
                    child: BlocBuilder<HomeCubit, HomeState>(
                      buildWhen: (previous, current) =>
                          current.currentItemIndex != previous.currentItemIndex,
                      builder: (context, state) {
                        return Stack(
                          children: <Widget>[
                            _buildPreviousItem(state.currentItemIndex - 1),
                            _buildCurrentItem(
                              index: state.currentItemIndex,
                              videosListLength: state.videos.length,
                            ),
                            _buildNextItem(
                              index: state.currentItemIndex + 1,
                              videosListLength: state.videos.length,
                            ),
                          ],
                        );
                      },
                    ),
                  )
                : const Center(child: CircularProgressIndicator());
          },
        );
      },
    );
  }

  Widget _buildPreviousItem(int index) {
    if (index < 0) return Container();
    return Positioned(
      bottom: _containerSize.height - _currentItemOffset,
      child: SizedBox.fromSize(
        size: _containerSize,
        child: VideoCard(controller: _previousVideoController),
      ),
    );
  }

  Widget _buildCurrentItem({
    required int index,
    required int videosListLength,
  }) {
    return Positioned(
      top: _currentItemOffset,
      child: GestureDetector(
        child: SizedBox.fromSize(
          size: _containerSize,
          child: VideoCard(controller: _currentVideoController),
        ),
        onVerticalDragStart: (DragStartDetails details) {
          setState(() {
            _dragState = DragState.dragging;
            _dragStartPosition = details.localPosition.dy;
          });
        },
        onVerticalDragUpdate: (DragUpdateDetails details) {
          final positiveDragThresholdMet = _currentItemOffset <
              -_containerSize.height * Feed.swipePositionThreshold;
          final negativeDragThresholdMet = _currentItemOffset >
              _containerSize.height * Feed.swipePositionThreshold;
          setState(() {
            _currentItemOffset = details.localPosition.dy - _dragStartPosition;
          });
        },
        onVerticalDragEnd: (DragEndDetails details) {
          final positiveDragThresholdMet = _currentItemOffset <
                  -_containerSize.height * Feed.swipePositionThreshold ||
              details.primaryVelocity! < -Feed.swipeVelocityThreshold;

          final negativeDragThresholdMet = _currentItemOffset >
                  _containerSize.height * Feed.swipePositionThreshold ||
              details.primaryVelocity! > Feed.swipeVelocityThreshold;

          DragState _state;
          // If the length of scroll goes beyond the point of no return
          // or if a small flick was faster than the velocity threshold
          if (positiveDragThresholdMet && index < videosListLength - 1) {
            // build animation, set state to animate forward
            // Animate to next card
            _state = DragState.animatingForward;
          } else if (negativeDragThresholdMet) {
            if (index == 0) {
              _state = DragState.animatingToCancel;
            } else {
              _state = DragState.animatingBackward;
            }
          } else if (positiveDragThresholdMet &&
              index == videosListLength - 1) {
            _state = DragState.animatingToCancel;
          } else {
            _state = DragState.animatingToCancel;
          }
          setState(() {
            _dragState = _state;
          });
          _createAnimation();
        },
      ),
    );
  }

  Widget _buildNextItem({
    required int index,
    required int videosListLength,
  }) {
    if (index >= videosListLength) return Container();
    return Positioned(
      top: _containerSize.height + _currentItemOffset,
      child: SizedBox.fromSize(
        size: _containerSize,
        child: VideoCard(controller: _nextVideoController),
      ),
    );
  }

  /// Animation co-ordinating function - tracks all types of animations
  /// including releases from drag events and controller animation requests
  void _createAnimation() {
    double _end;
    switch (_dragState) {
      case DragState.animatingForward:
        _end = -_containerSize.height;
        break;
      case DragState.animatingBackward:
        _end = _containerSize.height;
        break;
      case DragState.animatingToCancel:
      case DragState.idle:
      case DragState.dragging:
        _end = 0;
        break;
    }
    _animation = Tween<double>(begin: _currentItemOffset, end: _end)
        .animate(_animationController)
      ..addListener(_animationListener)
      ..addStatusListener(_animationStatusListener);
    _animationController.forward();
  }

  /// Keep track of instantaneous card position offsets
  void _animationListener() {
    setState(() {
      _currentItemOffset = _animation.value;
    });
  }

  void _animationStatusListener(AnimationStatus _status) {
    switch (_status) {
      case AnimationStatus.completed:
        // change the card index if required,
        // change the offset back to zero,
        // change the drag state back to idle
        final isAnimationComplete = _status != AnimationStatus.dismissed &&
            _status != AnimationStatus.forward;
        var newCardIndex = context.read<HomeCubit>().state.currentItemIndex;

        if (_dragState == DragState.animatingForward) {
          newCardIndex++;
        } else if (_dragState == DragState.animatingBackward) {
          newCardIndex--;
        }

        if (isAnimationComplete) {
          context.read<HomeCubit>().currentItemIndexChanged(newCardIndex);
          setState(() {
            _dragState = DragState.idle;
            _currentItemOffset = 0;
          });

          // Clean up all listeners including itself to ensure future
          // animations behave as they should
          _animation.removeListener(_animationListener);
          _animationController.reset();
          _animation.removeStatusListener(_animationStatusListener);

          // check if we need to keep animated after this one is complete
          if (_targetIndex != -1 && newCardIndex != _targetIndex) {
            _animateToPosition(_targetIndex);
          } else {
            setState(() {
              _targetIndex = -1;
            });
          }
        }
        break;
      default:
    }
  }

  /// Implementation used by [Controller] to goto the given page [targetPage]
  /// with an animation. This uses the existing animation settings including
  /// the duration per scroll.
  /// This function is called per page (ie multiple times if starting position
  /// and [targetPage] are not adjacent pages.
  void _animateToPosition(int targetPage) {
    // Check if further animations are required to reach [targetPage]
    if (targetPage == -1) {
      return;
    }
    final state = context.read<HomeCubit>().state;
    final index = state.currentItemIndex;
    if (targetPage > index && index != state.videos.length - 1) {
      setState(() {
        _dragState = DragState.animatingForward;
        _targetIndex = targetPage;
      });
      _createAnimation();
    } else if (targetPage < index && index != 0) {
      setState(() {
        _dragState = DragState.animatingBackward;
        _targetIndex = targetPage;
      });
      _createAnimation();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _previousVideoController.dispose();
    _currentVideoController.dispose();
    _nextVideoController.dispose();
    super.dispose();
  }
}
