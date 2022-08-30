import 'package:flutter/material.dart';

class VideoCard extends StatelessWidget {
  const VideoCard({
    super.key,
    required this.index,
    required this.backgroundColor,
    required this.title,
  });

  final int index;
  final Color backgroundColor;
  final String title;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: backgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$index',
              key: Key('$index-text'),
              style: const TextStyle(fontSize: 48, color: Colors.white),
            ),
            Text(
              title,
              key: Key('$index-title'),
              style: const TextStyle(fontSize: 24, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
