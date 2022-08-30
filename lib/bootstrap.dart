import 'dart:async';
import 'dart:developer';

import 'package:claps_api_client/claps_api_client.dart';
import 'package:flutter/material.dart';
import 'package:the_feeder/app/app.dart';
import 'package:uuid/uuid.dart';
import 'package:videos_repository/videos_repository.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterError.onError = (details) {
    log(details.exceptionAsString(), stackTrace: details.stack);
  };
  final clapsApiClient = ClapsApiClient(uid: const Uuid().v1());
  final videosRepository = VideosRepository(clapsApiClient);

  await runZonedGuarded(
    () async => runApp(App(videosRepository: videosRepository)),
    (error, stackTrace) => log(error.toString(), stackTrace: stackTrace),
  );
}
