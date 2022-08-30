import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:the_feeder/home/cubit/home_cubit.dart';
import 'package:the_feeder/home/widgets/video_card.dart';

/// Enum to track the current state of manual dragging or animation
enum DragState {
  idle,
  dragging,
  animatingForward,
  animatingBackward,
  animatingToCancel,
}

const colors = [
  Colors.red,
  Colors.green,
  Colors.blue,
];

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
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        _containerSize = constraints.biggest;
        final status = context.select((HomeCubit bloc) => bloc.state.status);

        return status.isSuccess
            ? Stack(
                children: <Widget>[
                  _buildPreviousItem(),
                  _buildCurrentItem(),
                  _buildNextItem(),
                ],
              )
            : const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildPreviousItem() {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (BuildContext context, HomeState state) {
        final index = state.currentItemIndex - 1;
        if (index < 0) return Container();
        return Positioned(
          bottom: _containerSize.height - _currentItemOffset,
          child: SizedBox.fromSize(
            size: _containerSize,
            child: VideoCard(
              index: index,
              backgroundColor: colors[0],
              title: state.videos[index].id,
            ),
          ),
        );
      },
    );
  }

  Widget _buildCurrentItem() {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (BuildContext context, HomeState state) {
        final index = state.currentItemIndex;
        return Positioned(
          top: _currentItemOffset,
          child: GestureDetector(
            child: SizedBox.fromSize(
              size: _containerSize,
              child: VideoCard(
                index: index,
                backgroundColor: colors[1],
                title: state.videos[index].id,
              ),
            ),
            onVerticalDragStart: (DragStartDetails details) {
              setState(() {
                _dragState = DragState.dragging;
                _dragStartPosition = details.localPosition.dy;
              });
            },
            onVerticalDragUpdate: (DragUpdateDetails details) {
              setState(() {
                _currentItemOffset =
                    details.localPosition.dy - _dragStartPosition;
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
              if (positiveDragThresholdMet && index < state.videos.length - 1) {
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
                  index == state.videos.length - 1) {
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
      },
    );
  }

  Widget _buildNextItem() {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (BuildContext context, HomeState state) {
        final index = state.currentItemIndex + 1;
        if (index >= state.videos.length) return Container();
        return Positioned(
          top: _containerSize.height + _currentItemOffset,
          child: SizedBox.fromSize(
            size: _containerSize,
            child: VideoCard(
              index: index,
              backgroundColor: colors[2],
              title: state.videos[index].id,
            ),
          ),
        );
      },
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
}
