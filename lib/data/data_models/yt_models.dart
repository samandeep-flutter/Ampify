import 'package:ampify/data/utils/exports.dart';

class MyHomeSection {
  final String title;
  final List<PlaylistDetailed> contents;

  MyHomeSection({required this.title, required this.contents});

  factory MyHomeSection.fromYT(HomeSection section) {
    return MyHomeSection(
      title: section.title,
      contents: List<PlaylistDetailed>.from(section.contents),
    );
  }
}

class SongDetails {
  final Uri uri;
  final Duration duration;

  SongDetails(this.uri, {required this.duration});
}

class SongYtDetails {
  final String videoId;
  final Duration duration;

  SongYtDetails(this.videoId, {required this.duration});

  factory SongYtDetails.fromJson(Map<String, dynamic> json) {
    return SongYtDetails(json['videoId'],
        duration: Duration(seconds: json['duration'] ?? 0));
  }

  Map<String, dynamic> toJson() =>
      {'videoId': videoId, 'duration': duration.inSeconds};
}

class QuerySong {
  final String title;
  final Iterable<String> artists;

  QuerySong(this.title, this.artists);

  String get text => '$title ${artists.first}';
}
