import 'dart:convert';

import 'package:claps_api_client/claps_api_client.dart';
import 'package:http/http.dart' as http;

/// Exception thrown if the video feed request fails.
class VideoFeedRequestException implements Exception {}

/// Exception thrown if the video feed is not found.
class VideoFeedNotFoundException implements Exception {}

/// {@template claps_api_client}
/// Dart API Client which wraps part of the [Claps API](https://docs.api.claps.ai/).
/// {@endtemplate}
class ClapsApiClient {
  /// {@macro claps_api_client}
  ClapsApiClient({http.Client? httpClient, required String uid})
      : _httpClient = httpClient ?? http.Client(),
        headers = <String, String>{
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': 'true',
          'Device-Id': uid,
        };

  static const _baseUrl = 'api.claps.ai';

  final http.Client _httpClient;

  /// Used to authenticate the requests and set the used content type.
  final Map<String, String> headers;

  /// Gets a list of [Video] `/videos/main-feed`.
  Future<List<Video>> fetchVideosMainFeed() async {
    final request = Uri.https(_baseUrl, '/v1/videos/main-feed');
    final response = await _httpClient.get(request, headers: headers);

    if (response.statusCode != 200) {
      throw VideoFeedRequestException();
    }

    final responseJson = jsonDecode(response.body) as List<dynamic>;

    if (responseJson.isEmpty) {
      throw VideoFeedNotFoundException();
    }

    // TODO(Grau): Remove test
    return responseJson
        .map((dynamic json) => Video.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
