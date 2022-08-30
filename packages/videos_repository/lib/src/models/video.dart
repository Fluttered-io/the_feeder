import 'package:claps_api_client/claps_api_client.dart' as api_client;
import 'package:freezed_annotation/freezed_annotation.dart';

part 'video.freezed.dart';

@freezed
class Video with _$Video {
  const factory Video({required String url}) = _Video;

  factory Video.fromApi(api_client.Video video) => Video(url: video.url);
}
