import 'package:json_annotation/json_annotation.dart';

part 'video.g.dart';

@JsonSerializable()
class Video {
  factory Video.fromJson(Map<String, dynamic> json) => _$VideoFromJson(json);
  const Video({
    required this.id,
    required this.title,
    required this.url,
    required this.userId,
    required this.userNick,
    required this.userPhoto,
    required this.tribeNick,
    required this.tribePhoto,
    required this.claps,
    required this.views,
    required this.userName,
    required this.uploaded,
    required this.userCompany,
    required this.userIsVerified,
    required this.userRole,
    required this.userClapped,
    required this.userBookmarked,
    required this.userSeen,
    required this.userSeenScore,
    required this.tags,
  });

  final String id;
  final String? title;
  final String url;
  final String? userId;
  final String? userNick;
  final String? userPhoto;
  final String? tribeNick;
  final String? tribePhoto;
  final int? claps;
  final int? views;
  final String? userName;
  final String? uploaded;
  final String? userCompany;
  final bool? userIsVerified;
  final String? userRole;
  final bool? userClapped;
  final bool? userBookmarked;
  final bool? userSeen;
  final int? userSeenScore;
  final List<String>? tags;

  Map<String, dynamic> toJson() => _$VideoToJson(this);
}
