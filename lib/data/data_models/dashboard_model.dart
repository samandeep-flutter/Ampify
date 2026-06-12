import 'package:ampify/data/utils/exports.dart';

class MyHomeSection extends Equatable {
  final String title;
  final LibItemType type;
  final List<MyHomeDetailed> contents;

  const MyHomeSection(
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

  @override
  List<Object?> get props => [title, type, contents];
}

class MyHomeDetailed extends Equatable {
  final String id;
  final String title;
  final ArtistBasic artist;
  final LibItemType type;
  final Thumbnail? thumbnail;

  const MyHomeDetailed({
    required this.id,
    required this.title,
    required this.artist,
    required this.type,
    required this.thumbnail,
  });

  factory MyHomeDetailed.fromYT(dynamic item) {
    final pl = item is PlaylistDetailed;
    return MyHomeDetailed(
      id: pl ? _pl(item).playlistId : _al(item).albumId,
      title: pl ? _pl(item).name : _al(item).name,
      artist: pl ? _pl(item).artist : _al(item).artist,
      type: pl ? LibItemType.playlist : LibItemType.album,
      thumbnail: _thumb(item, pl)?.toThumbnail(),
    );
  }

  static ThumbnailFull? _thumb(dynamic item, bool pl) {
    if (pl) return _pl(item).thumbnails.firstOrNull;
    return _al(item).thumbnails.firstOrNull;
  }

  static PlaylistDetailed _pl(dynamic playlist) => playlist as PlaylistDetailed;
  static AlbumDetailed _al(dynamic playlist) => playlist as AlbumDetailed;

  @override
  List<Object?> get props => [id, title, artist, type, thumbnail];
}
