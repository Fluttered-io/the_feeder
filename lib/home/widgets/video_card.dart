import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoCard extends StatelessWidget {
  const VideoCard({super.key, required this.controller});

  final VideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return controller.value.isInitialized
            ? ColoredBox(
                color: Colors.black,
                child: AspectRatio(
                  aspectRatio: controller.value.aspectRatio,
                  child: VideoPlayer(controller),
                ),
              )
            : const Center(child: CircularProgressIndicator());
      },
    );
  }
}
