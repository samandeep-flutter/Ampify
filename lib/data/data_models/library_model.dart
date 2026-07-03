import 'package:ampify/data/utils/exports.dart';

class LibraryModel extends Equatable {
  final String id;
  final String title;
  final Thumbnail? thumbnail;
  final LibItemType type;

  /// in case of video or track
  final String libId;

  /// in case of playlist or album created with the app
  final String? docId;

  /// only in case of track
  final Album? album;

  /// null in case of [type] is [artist]
  final MyArtistBasic? artist;

  /// in case of video or track
  final Duration? duration;

  const LibraryModel({
    required this.id,
    required this.libId,
    this.docId,
    required this.title,
    required this.thumbnail,
    required this.type,
    this.album,
    this.artist,
    this.duration,
  });
  const LibraryModel.fb({
    required this.id,
    required this.title,
    required this.docId,
    this.type = LibItemType.playlist,
  })  : libId = id,
        thumbnail = null,
        album = null,
        artist = null,
        duration = null;

  factory LibraryModel.fromYT(SearchResult result) {
    final type = LibItemType.values.firstWhere((e) => e.id == result.type);

    switch (type) {
      case LibItemType.track:
        result as SongDetailed;
        return LibraryModel(
          id: result.videoId,
          title: result.name,
          type: type,
          libId: result.videoId,
          artist: MyArtistBasic.fromYT(result.artist),
          album: result.album != null ? Album.fromYtBasic(result.album!) : null,
          thumbnail: result.thumbnails.toThumbnail(),
          duration: result.duration?.toDuration(),
        );

      case LibItemType.video:
        result as VideoDetailed;
        return LibraryModel(
          id: result.videoId,
          title: result.name,
          type: type,
          libId: result.videoId,
          artist: MyArtistBasic.fromYT(result.artist),
          thumbnail: result.thumbnails.toThumbnail(),
          duration: result.duration?.toDuration(),
        );

      case LibItemType.playlist:
        result as PlaylistDetailed;
        return LibraryModel(
          id: result.playlistId,
          title: result.name,
          type: type,
          libId: result.playlistId,
          artist: MyArtistBasic.fromYT(result.artist),
          thumbnail: result.thumbnails.toThumbnail(),
        );

      case LibItemType.album:
        result as AlbumDetailed;
        return LibraryModel(
          id: result.albumId,
          title: result.name,
          type: type,
          libId: result.albumId,
          artist: MyArtistBasic.fromYT(result.artist),
          thumbnail: result.thumbnails.toThumbnail(),
        );

      case LibItemType.artist:
        result as ArtistDetailed;
        return LibraryModel(
          id: result.artistId,
          title: result.name,
          type: type,
          libId: result.artistId,
          thumbnail: result.thumbnails.toThumbnail(),
        );

      case LibItemType.unknown:
        throw UnimplementedError('Unknown type: ${result.type}');
    }
  }

  factory LibraryModel.fromJson(Map<String, dynamic> json) {
    return LibraryModel(
      id: json['id'],
      type: LibItemType.values.firstWhere((e) => e.id == json['type']),
      libId: json['video_id'],
      title: json['title'],
      thumbnail: json['thumbnail'] != null
          ? Thumbnail.fromJson(json['thumbnail'])
          : null,
      album: json['album'] != null ? Album.fromJson(json['album']) : null,
      artist: json['artist'] != null
          ? MyArtistBasic.fromJson(json['artist'])
          : null,
      duration:
          json['duration'] != null ? Duration(seconds: json['duration']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.id,
        'video_id': libId,
        'title': title,
        'thumbnail': thumbnail?.toJson(),
        'album': album?.toJson(),
        'artist': artist?.toJson(),
        'duration': duration?.inSeconds,
      };

  @override
  List<Object?> get props =>
      [id, libId, title, thumbnail, album, artist, type, duration];
}

enum LibItemType {
  playlist._('PLAYLIST'),
  artist._('ARTIST'),
  album._('ALBUM'),
  track._('SONG'),
  video._('VIDEO'),
  unknown._('NA');

  const LibItemType._(this.id);
  final String id;
}

class Thumbnail extends Equatable {
  final String url;
  final int width;
  final int height;
  const Thumbnail(
      {required this.url, required this.width, required this.height});

  factory Thumbnail.fromYT(ThumbnailFull thumbnail) {
    return Thumbnail(
        url: thumbnail.url, width: thumbnail.width, height: thumbnail.height);
  }

  factory Thumbnail.fromJson(Map<String, dynamic> json) {
    return Thumbnail(
        url: json['url'], width: json['width'], height: json['height']);
  }

  Map<String, dynamic> toJson() =>
      {'url': url, 'width': width, 'height': height};

  @override
  List<Object?> get props => [url, width, height];
}
