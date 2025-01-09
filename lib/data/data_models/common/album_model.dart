import 'package:ampify/data/data_models/common/artist_model.dart';
import 'package:equatable/equatable.dart';
import 'images_models.dart';

class Album extends Equatable {
  final String? albumType;
  final int? totalTracks;
  final String? href;
  final String? id;
  final ImagesModel? image;
  final String? name;
  final String? releaseDate;
  final String? type;
  final String? uri;
  final List<Artist>? artists;

  const Album(
      {this.albumType,
      this.totalTracks,
      this.href,
      this.id,
      this.image,
      this.name,
      this.releaseDate,
      this.type,
      this.uri,
      this.artists});

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      albumType: json['album_type'],
      totalTracks: json['total_tracks'],
      href: json['href'],
      id: json['id'],
      image: (json['images'] as List?)?.isNotEmpty ?? false
          ? ImagesModel.fromJson((json['images'] as List).first)
          : null,
      name: json['name'],
      releaseDate: json['release_date'],
      type: json['type'],
      uri: json['uri'],
      artists: List<Artist>.from(
          json['artists']?.map((e) => Artist.fromJson(e)) ?? []),
    );
  }

  Map<String, dynamic> toJson() => {
        'album_type': albumType,
        'total_tracks': totalTracks,
        'href': href,
        'id': id,
        'images': image?.toJson(),
        'name': name,
        'release_date': releaseDate,
        'type': type,
        'uri': uri,
        'artists': artists?.map((v) => v.toJson()).toList(),
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
      ];
}
