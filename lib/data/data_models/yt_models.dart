import 'package:ampify/data/utils/exports.dart';

class MyHomeSection {
  final String title;
  final LibItemType type;
  final List<MyHomeDetailed> contents;

  MyHomeSection(
      {required this.title, required this.type, required this.contents});

  factory MyHomeSection.fromYT(HomeSection section) {
    final first = section.contents.firstOrNull;

    return MyHomeSection(
      title: section.title,
      type: first is PlaylistDetailed
          ? LibItemType.playlist
          : first is AlbumDetailed
              ? LibItemType.album
              : LibItemType.unknown,
      contents: List<MyHomeDetailed>.from(
          section.contents.map((e) => MyHomeDetailed.fromYT(e))),
    );
  }
}

class MyHomeDetailed {
  final String id;
  final String title;
  final ArtistBasic artist;
  final LibItemType type;
  final List<ThumbnailFull> thumbnails;

  MyHomeDetailed({
    required this.id,
    required this.title,
    required this.artist,
    required this.type,
    required this.thumbnails,
  });

  factory MyHomeDetailed.fromYT(dynamic item) {
    final pl = item is PlaylistDetailed;
    return MyHomeDetailed(
      id: pl ? _pl(item).playlistId : _al(item).albumId,
      title: pl ? _pl(item).name : _al(item).name,
      artist: pl ? _pl(item).artist : _al(item).artist,
      type: pl ? LibItemType.playlist : LibItemType.album,
      thumbnails: pl ? _pl(item).thumbnails : _al(item).thumbnails,
    );
  }
  static PlaylistDetailed _pl(dynamic playlist) {
    return playlist as PlaylistDetailed;
  }

  static AlbumDetailed _al(dynamic playlist) {
    return playlist as AlbumDetailed;
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
