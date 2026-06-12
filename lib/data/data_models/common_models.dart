import 'package:ampify/data/utils/exports.dart';

class Playlist extends Equatable {
  final String id;
  final String type;
  final String title;
  final MyArtistBasic artist;
  final int videoCount;
  final Thumbnail? thumbnail;

  const Playlist({
    required this.id,
    required this.type,
    required this.title,
    required this.artist,
    required this.videoCount,
    required this.thumbnail,
  });

  factory Playlist.fromYT(PlaylistFull pl) {
    return Playlist(
      id: pl.playlistId,
      type: pl.type,
      title: pl.name,
      artist: MyArtistBasic.fromYT(pl.artist),
      videoCount: pl.videoCount,
      thumbnail: pl.thumbnails.firstOrNull?.toThumbnail(),
    );
  }

  @override
  List<Object?> get props => [id, type, title, artist, videoCount, thumbnail];
}

class MyArtistBasic extends Equatable {
  final String? id;
  final String name;
  final Thumbnail? thumbnail;

  const MyArtistBasic(
      {required this.id, required this.name, required this.thumbnail});
  const MyArtistBasic._({required this.id, required this.name})
      : thumbnail = null;

  factory MyArtistBasic.fromYT(ArtistBasic artist) {
    return MyArtistBasic._(id: artist.artistId, name: artist.name);
  }

  factory MyArtistBasic.fromJson(Map<String, dynamic> json) {
    return MyArtistBasic(
      id: json['id'],
      name: json['name'],
      thumbnail: json['thumbnail'] != null
          ? Thumbnail.fromJson(json['thumbnail'])
          : null,
    );
  }

  Map<String, dynamic> toJson() =>
      {'id': id, 'name': name, 'thumbnail': thumbnail?.toJson()};

  @override
  List<Object?> get props => [id, name, thumbnail];
}

class Album extends Equatable {
  final String id;
  final String title;
  final MyArtistBasic? artist;
  final int? year;
  final Thumbnail? thumbnail;
  final List<Track> tracks;

  const Album({
    required this.id,
    required this.title,
    required this.artist,
    required this.year,
    required this.thumbnail,
    required this.tracks,
  });
  const Album._({required this.id, required this.title})
      : artist = null,
        year = null,
        thumbnail = null,
        tracks = const [];

  factory Album.fromYtFull(AlbumFull al) {
    return Album(
      id: al.albumId,
      title: al.name,
      artist: MyArtistBasic.fromYT(al.artist),
      year: al.year,
      thumbnail: al.thumbnails.firstOrNull?.toThumbnail(),
      tracks: al.songs.map((e) => Track.fromYT(e)).toList(),
      // playlistId: al.playlistId
    );
  }
  factory Album.fromYtBasic(AlbumBasic al) {
    return Album._(id: al.albumId, title: al.name);
  }

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      id: json['id'],
      title: json['title'],
      artist: json['artist'] != null
          ? MyArtistBasic.fromJson(json['artist'])
          : null,
      year: json['year'],
      thumbnail: json['thumbnail'] != null
          ? Thumbnail.fromJson(json['thumbnail'])
          : null,
      tracks: List<Track>.from(
          (json['tracks'] as List? ?? []).map((e) => Track.fromJson(e))),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'artist': artist?.toJson(),
        'year': year,
        'thumbnail': thumbnail?.toJson(),
        'tracks': tracks.map((e) => e.toJson()).toList()
      };

  @override
  List<Object?> get props => [id, title, artist, year, thumbnail, tracks];
}
