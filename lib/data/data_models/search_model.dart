import 'package:ampify/data/data_models/common/album_model.dart';
import 'package:ampify/data/data_models/common/artist_model.dart';
import 'package:ampify/data/data_models/common/playlist_model.dart';
import 'package:equatable/equatable.dart';
import 'common/tracks_model.dart';

class SearchModel extends Equatable {
  final TrackModel? tracks;
  final ArtistModel? artists;
  final AlbumModel? albums;
  final PlaylistModel? playlists;

  const SearchModel({this.tracks, this.artists, this.albums, this.playlists});

  factory SearchModel.fromJson(Map<String, dynamic> json) {
    return SearchModel(
        tracks:
            json['tracks'] != null ? TrackModel.fromJson(json['tracks']) : null,
        artists: json['artists'] != null
            ? ArtistModel.fromJson(json['artists'])
            : null,
        albums:
            json['albums'] != null ? AlbumModel.fromJson(json['albums']) : null,
        playlists: json['playlists'] != null
            ? PlaylistModel.fromJson(json['playlists'])
            : null);
  }

  Map<String, dynamic> toJson() => {
        'tracks': tracks?.toJson(),
        'artists': artists?.toJson(),
        'albums': albums?.toJson(),
        'playlists': playlists?.toJson(),
      };

  @override
  List<Object?> get props => [tracks, artists, albums, playlists];
}

class AlbumModel extends Equatable {
  final String? href;
  final int? limit;
  final int? offset;
  final int? total;
  final List<Album>? items;

  const AlbumModel(
      {this.href, this.limit, this.offset, this.total, this.items});

  factory AlbumModel.fromJson(Map<String, dynamic> json) {
    final List<Album> items = [];
    (json['items'] as List?)?.forEach((e) {
      if (e != null) items.add(Album.fromJson(e));
    });
    return AlbumModel(
      href: json['href'],
      limit: json['limit'],
      offset: json['offset'],
      total: json['total'],
      items: items,
    );
  }

  Map<String, dynamic> toJson() => {
        'href': href,
        'limit': limit,
        'offset': offset,
        'total': total,
        'items': items?.map((v) => v.toJson()).toList(),
      };

  @override
  List<Object?> get props => [href, limit, offset, total, items];
}

class ArtistModel extends Equatable {
  final String? href;
  final int? limit;
  final int? offset;
  final int? total;
  final List<Artist>? items;

  const ArtistModel(
      {this.href, this.limit, this.offset, this.total, this.items});

  factory ArtistModel.fromJson(Map<String, dynamic> json) {
    final List<Artist> items = [];
    (json['items'] as List?)?.forEach((e) {
      if (e != null) items.add(Artist.fromJson(e));
    });
    return ArtistModel(
      href: json['href'],
      limit: json['limit'],
      offset: json['offset'],
      total: json['total'],
      items: items,
    );
  }

  Map<String, dynamic> toJson() => {
        'href': href,
        'limit': limit,
        'offset': offset,
        'total': total,
        'items': items?.map((v) => v.toJson()).toList(),
      };

  @override
  List<Object?> get props => [href, limit, offset, total, items];
}

class PlaylistModel extends Equatable {
  final String? href;
  final int? limit;
  final int? offset;
  final int? total;
  final List<Playlist>? items;

  const PlaylistModel(
      {this.href, this.limit, this.offset, this.total, this.items});

  factory PlaylistModel.fromJson(Map<String, dynamic> json) {
    final List<Playlist> items = [];
    (json['items'] as List?)?.forEach((e) {
      if (e != null) items.add(Playlist.fromJson(e));
    });

    return PlaylistModel(
      href: json['href'],
      limit: json['limit'],
      offset: json['offset'],
      total: json['total'],
      items: items,
    );
  }

  Map<String, dynamic> toJson() => {
        'href': href,
        'limit': limit,
        'offset': offset,
        'total': total,
        'items': items?.map((v) => v.toJson()).toList(),
      };

  @override
  List<Object?> get props => [href, limit, offset, total, items];
}

class TrackModel extends Equatable {
  final String? href;
  final int? limit;
  final int? offset;
  final int? total;
  final List<Track>? items;

  const TrackModel(
      {this.href, this.limit, this.offset, this.total, this.items});

  factory TrackModel.fromJson(Map<String, dynamic> json) {
    final List<Track> items = [];
    (json['items'] as List?)?.forEach((e) {
      if (e != null) items.add(Track.fromJson(e));
    });
    return TrackModel(
      href: json['href'],
      limit: json['limit'],
      offset: json['offset'],
      total: json['total'],
      items: items,
    );
  }

  Map<String, dynamic> toJson() => {
        'href': href,
        'limit': limit,
        'offset': offset,
        'total': total,
        'items': items?.map((v) => v.toJson()).toList(),
      };

  @override
  List<Object?> get props => [href, limit, offset, total, items];
}
