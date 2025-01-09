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
  final String? next;
  final int? offset;
  final dynamic previous;
  final int? total;
  final List<Album>? items;

  const AlbumModel(
      {this.href,
      this.limit,
      this.next,
      this.offset,
      this.previous,
      this.total,
      this.items});

  factory AlbumModel.fromJson(Map<String, dynamic> json) {
    return AlbumModel(
      href: json['href'],
      limit: json['limit'],
      next: json['next'],
      offset: json['offset'],
      previous: json['previous'],
      total: json['total'],
      items:
          List<Album>.from(json['items']?.map((e) => Album.fromJson(e)) ?? []),
    );
  }

  Map<String, dynamic> toJson() => {
        'href': href,
        'limit': limit,
        'next': next,
        'offset': offset,
        'previous': previous,
        'total': total,
        'items': items?.map((v) => v.toJson()).toList(),
      };

  @override
  List<Object?> get props =>
      [href, limit, next, offset, previous, total, items];
}

class ArtistModel extends Equatable {
  final String? href;
  final int? limit;
  final String? next;
  final int? offset;
  final dynamic previous;
  final int? total;
  final List<Artist>? items;

  const ArtistModel(
      {this.href,
      this.limit,
      this.next,
      this.offset,
      this.previous,
      this.total,
      this.items});

  factory ArtistModel.fromJson(Map<String, dynamic> json) {
    return ArtistModel(
      href: json['href'],
      limit: json['limit'],
      next: json['next'],
      offset: json['offset'],
      previous: json['previous'],
      total: json['total'],
      items: List<Artist>.from(
          json['items']?.map((e) => Artist.fromJson(e)) ?? []),
    );
  }

  Map<String, dynamic> toJson() => {
        'href': href,
        'limit': limit,
        'next': next,
        'offset': offset,
        'previous': previous,
        'total': total,
        'items': items?.map((v) => v.toJson()).toList(),
      };

  @override
  List<Object?> get props =>
      [href, limit, next, offset, previous, total, items];
}

class PlaylistModel extends Equatable {
  final String? href;
  final int? limit;
  final String? next;
  final int? offset;
  final dynamic previous;
  final int? total;
  final List<Playlist>? items;

  const PlaylistModel(
      {this.href,
      this.limit,
      this.next,
      this.offset,
      this.previous,
      this.total,
      this.items});

  factory PlaylistModel.fromJson(Map<String, dynamic> json) {
    final List<Playlist> items = [];
    (json['items'] as List?)?.forEach((e) {
      if (e != null) items.add(Playlist.fromJson(e));
    });

    return PlaylistModel(
      href: json['href'],
      limit: json['limit'],
      next: json['next'],
      offset: json['offset'],
      previous: json['previous'],
      total: json['total'],
      items: items,
    );
  }

  Map<String, dynamic> toJson() => {
        'href': href,
        'limit': limit,
        'next': next,
        'offset': offset,
        'previous': previous,
        'total': total,
        'items': items?.map((v) => v.toJson()).toList(),
      };

  @override
  List<Object?> get props =>
      [href, limit, next, offset, previous, total, items];
}

class TrackModel extends Equatable {
  final String? href;
  final int? limit;
  final String? next;
  final int? offset;
  final dynamic previous;
  final int? total;
  final List<Track>? items;

  const TrackModel({
    this.href,
    this.limit,
    this.next,
    this.offset,
    this.previous,
    this.total,
    this.items,
  });

  factory TrackModel.fromJson(Map<String, dynamic> json) {
    return TrackModel(
        href: json['href'],
        limit: json['limit'],
        next: json['next'],
        offset: json['offset'],
        previous: json['previous'],
        total: json['total'],
        items: List<Track>.from(
            json['items']?.map((v) => Track.fromJson(v)) ?? []));
  }

  Map<String, dynamic> toJson() => {
        'href': href,
        'limit': limit,
        'next': next,
        'offset': offset,
        'previous': previous,
        'total': total,
        'items': items?.map((v) => v.toJson()).toList(),
      };

  @override
  List<Object?> get props =>
      [href, limit, next, offset, previous, total, items];
}
