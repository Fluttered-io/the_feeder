import 'package:claps_api_client/claps_api_client.dart' as api_client;
import 'package:videos_repository/videos_repository.dart';

class VideosRepository {
  VideosRepository(api_client.ClapsApiClient clapsApiClient)
      : _apiClient = clapsApiClient;

  final api_client.ClapsApiClient _apiClient;

  Future<List<Video>> getVideos() async {
    final videos = await _apiClient.fetchVideosMainFeed();
    return videos.map(Video.fromApi).toList();
  }
}
