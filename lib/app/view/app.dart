import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:the_feeder/home/home.dart';
import 'package:videos_repository/videos_repository.dart';

class App extends StatelessWidget {
  const App({super.key, required VideosRepository videosRepository})
      : _videosRepository = videosRepository;

  final VideosRepository _videosRepository;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (_) => _videosRepository,
      child: const _AppView(),
    );
  }
}

class _AppView extends StatelessWidget {
  const _AppView({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: const HomePage(),
    );
  }
}
