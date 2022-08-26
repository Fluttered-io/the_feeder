import 'package:flutter/material.dart';

class VideoCard extends StatelessWidget {
  const VideoCard({
    super.key,
    required this.index,
    required this.backgroundColor,
  });

  final int index;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: backgroundColor,
      child: Center(
        child: Text(
          '$index',
          key: Key('$index-text'),
          style: const TextStyle(fontSize: 48, color: Colors.white),
        ),
      ),
    );
  }
}
