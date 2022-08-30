import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:the_feeder/home/cubit/home_cubit.dart';
import 'package:the_feeder/home/home.dart';
import 'package:videos_repository/videos_repository.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static Page<void> page() => const MaterialPage<void>(child: HomePage());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (_) => HomeCubit(context.read<VideosRepository>())..getVideos(),
        child: const Feed(),
      ),
    );
  }
}
