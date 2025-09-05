import 'package:ampify/data/data_models/common/artist_model.dart';
import 'package:ampify/data/data_models/common/tracks_model.dart';
import 'package:ampify/data/data_models/library_model.dart';
import 'package:equatable/equatable.dart';
import 'other_models.dart';

class Album extends Equatable {
  final String? albumType;
  final int? totalTracks;
  final String? href;
  final String? id;
  final String? image;
  final String? name;
  final String? releaseDate;
  final LibItemType? type;
  final String? uri;
  final List<Artist>? artists;
  final List<Track>? tracks;
  final List<Copyrights>? copyrights;
  final List<String>? genres;
  final String? label;
  final int? popularity;

  const Album({
    this.albumType,
    this.totalTracks,
    this.href,
    this.id,
    this.image,
    this.name,
    this.releaseDate,
    this.type,
    this.uri,
    this.artists,
    this.tracks,
    this.copyrights,
    this.genres,
    this.label,
    this.popularity,
  });

  factory Album.fromJson(Map<String, dynamic> json) {
    final albumImage = (json['images'] as List?)?.isNotEmpty ?? false
        ? (json['images'] as List?)?.first['url']
        : null;

    return Album(
      albumType: json['album_type'],
      totalTracks: json['total_tracks'],
      href: json['href'],
      id: json['id'],
      image: albumImage,
      name: json['name'],
      releaseDate: json['release_date'],
      type: LibItemType.values.firstWhere((e) => e.name == json['type']),
      uri: json['uri'],
      artists: List<Artist>.from(
          json['artists']?.map((e) => Artist.fromJson(e)) ?? []),
      tracks: List<Track>.from(json['tracks']?['items']?.map((e) {
            final album =
                Album(image: albumImage, name: json['name'], id: json['id']);
            return Track.fromJson(e, image: albumImage, album: album);
          }) ??
          []),
      copyrights: List<Copyrights>.from(json['copyrights']?.map((e) {
            return Copyrights.fromJson(e);
          }) ??
          []),
      genres: List<String>.from(json['genres'] ?? []),
      label: json['label'],
      popularity: json['popularity'],
    );
  }

  Map<String, dynamic> toJson() => {
        'album_type': albumType,
        'total_tracks': totalTracks,
        'href': href,
        'id': id,
        'images': image,
        'name': name,
        'release_date': releaseDate,
        'type': type?.name,
        'uri': uri,
        'artists': artists?.map((v) => v.toJson()).toList(),
        'tracks': tracks?.map((e) => e.toJson()),
        'copyrights': copyrights?.map((v) => v.toJson()).toList(),
        'genres': genres,
        'label': label,
        'popularity': popularity,
      };

  @override
  List<Object?> get props => [
        albumType,
        totalTracks,
        href,
        id,
        image,
        name,
        releaseDate,
        type,
        uri,
        artists,
        tracks,
        copyrights,
        genres,
        label,
        popularity
      ];
}
