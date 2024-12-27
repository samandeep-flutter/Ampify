import 'package:ampify/data/data_models/album_model.dart';
import 'package:ampify/data/data_models/artist_model.dart';
import 'package:equatable/equatable.dart';

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
        items: (json['items'] as List?)?.map((v) {
          return Track.fromJson(v);
        }).toList());
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['href'] = href;
    data['limit'] = limit;
    data['next'] = next;
    data['offset'] = offset;
    data['previous'] = previous;
    data['total'] = total;
    if (items != null) {
      data['items'] = items!.map((v) => v.toJson()).toList();
    }
    return data;
  }

  @override
  List<Object?> get props =>
      [href, limit, next, offset, previous, total, items];
}

class Track extends Equatable {
  final Album? album;
  final List<Artist>? artists;
  final int? discNumber;
  final int? durationMs;
  final bool? explicit;
  final String? href;
  final String? id;
  final bool? isLocal;
  final bool? isPlayable;
  final String? name;
  final int? popularity;
  final String? previewUrl;
  final int? trackNumber;
  final String? type;
  final String? uri;

  const Track(
      {this.album,
      this.artists,
      this.discNumber,
      this.durationMs,
      this.explicit,
      this.href,
      this.id,
      this.isLocal,
      this.isPlayable,
      this.name,
      this.popularity,
      this.previewUrl,
      this.trackNumber,
      this.type,
      this.uri});

  factory Track.fromJson(Map<String, dynamic> json) {
    return Track(
      album: json['album'] != null ? Album.fromJson(json['album']) : null,
      artists: (json['artists'] as List?)?.map((v) {
        return Artist.fromJson(v);
      }).toList(),
      discNumber: json['disc_number'],
      durationMs: json['duration_ms'],
      explicit: json['explicit'],
      href: json['href'],
      id: json['id'],
      isLocal: json['is_local'],
      isPlayable: json['is_playable'],
      name: json['name'],
      popularity: json['popularity'],
      previewUrl: json['preview_url'],
      trackNumber: json['track_number'],
      type: json['type'],
      uri: json['uri'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['album'] = album?.toJson();
    data['artists'] = artists?.map((v) => v.toJson()).toList();
    data['disc_number'] = discNumber;
    data['duration_ms'] = durationMs;
    data['explicit'] = explicit;
    data['href'] = href;
    data['id'] = id;
    data['is_local'] = isLocal;
    data['is_playable'] = isPlayable;
    data['name'] = name;
    data['popularity'] = popularity;
    data['preview_url'] = previewUrl;
    data['track_number'] = trackNumber;
    data['type'] = type;
    data['uri'] = uri;
    return data;
  }

  @override
  List<Object?> get props => [
        album,
        artists,
        discNumber,
        durationMs,
        explicit,
        href,
        id,
        isLocal,
        isPlayable,
        name,
        popularity,
        previewUrl,
        trackNumber,
        type,
        uri,
      ];
}
