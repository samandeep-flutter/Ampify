import 'package:dart_ytmusic_api/types.dart';
import 'package:equatable/equatable.dart';

class LibraryModel extends Equatable {
  final String id;
  final String name;
  final String? image;
  final LibItemType type;

  /// in case of video or track
  final String? vidID;

  /// only in case of track
  final AlbumBasic? album;

  /// null in case of [type] is [artist]
  final ArtistBasic? artist;

  /// in case of video or track
  final Duration? duration;

  const LibraryModel({
    required this.id,
    this.vidID,
    required this.name,
    required this.image,
    required this.type,
    this.album,
    this.artist,
    this.duration,
  });

  factory LibraryModel.fromYT(SearchResult result) {
    final type = LibItemType.values.firstWhere((e) => e.id == result.type);
    switch (type) {
      case LibItemType.track:
        result as SongDetailed;
        return LibraryModel(
          id: result.videoId,
          name: result.name,
          type: type,
          vidID: result.videoId,
          artist: result.artist,
          album: result.album,
          image: result.thumbnails.firstOrNull?.url,
          duration: result.duration != null
              ? Duration(seconds: result.duration!)
              : null,
        );

      case LibItemType.album:
        result as AlbumDetailed;
        return LibraryModel(
          id: result.albumId,
          name: result.name,
          type: type,
          // vidID: result.playlistId,
          artist: result.artist,
          image: result.thumbnails.firstOrNull?.url,
        );

      case LibItemType.artist:
        result as ArtistDetailed;
        return LibraryModel(
          id: result.artistId,
          name: result.name,
          type: type,
          image: result.thumbnails.firstOrNull?.url,
        );

      case LibItemType.video:
        result as VideoDetailed;
        return LibraryModel(
          id: result.videoId,
          name: result.name,
          type: type,
          vidID: result.videoId,
          artist: result.artist,
          image: result.thumbnails.firstOrNull?.url,
          duration: result.duration != null
              ? Duration(seconds: result.duration!)
              : null,
        );

      case LibItemType.playlist:
        result as PlaylistDetailed;
        return LibraryModel(
          id: result.playlistId,
          name: result.name,
          type: type,
          artist: result.artist,
          image: result.thumbnails.firstOrNull?.url,
        );

      case LibItemType.unknown:
        throw UnimplementedError('Unknown type: ${result.type}');
    }
  }

  @override
  List<Object?> get props =>
      [id, vidID, name, image, album, artist, type, duration];
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
