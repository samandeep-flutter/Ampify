import 'package:ampify/data/utils/exports.dart';
import 'package:equatable/equatable.dart';

class Artist extends Equatable {
  final int? followers;
  final List<String>? genres;
  final String? href;
  final String? id;
  final String? image;
  final String? name;
  final int? popularity;
  final String? type;
  final String? uri;

  const Artist({
    this.followers,
    this.genres,
    this.href,
    this.id,
    this.image,
    this.name,
    this.popularity,
    this.type,
    this.uri,
  });

  factory Artist.fromJson(Map<String, dynamic> json) {
    return Artist(
        followers: json['followers']?['total'],
        genres: json['genres']?.cast<String>(),
        href: json['href'],
        id: json['id'],
        image: (json['images'] as List?)?.firstElement?['url'],
        name: json['name'],
        popularity: json['popularity'],
        type: json['type'],
        uri: json['uri']);
  }

  Map<String, dynamic> toJson() => {
        'followers': followers,
        'genres': genres,
        'href': href,
        'id': id,
        'images': image,
        'name': name,
        'popularity': popularity,
        'type': type,
        'uri': uri,
      };

  @override
  List<Object?> get props =>
      [followers, genres, href, id, image, name, popularity, type, uri];
}
