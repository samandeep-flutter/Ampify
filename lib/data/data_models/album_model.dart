import 'package:ampify/data/data_models/artist_model.dart';
import 'images_models.dart';

class AlbumModel {
  String? href;
  int? limit;
  String? next;
  int? offset;
  dynamic previous;
  int? total;
  List<Album>? items;

  AlbumModel(
      {this.href,
      this.limit,
      this.next,
      this.offset,
      this.previous,
      this.total,
      this.items});

  AlbumModel.fromJson(Map<String, dynamic> json) {
    href = json['href'];
    limit = json['limit'];
    next = json['next'];
    offset = json['offset'];
    previous = json['previous'];
    total = json['total'];
    if (json['items'] != null) {
      items = <Album>[];
      json['items'].forEach((v) {
        items!.add(Album.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['href'] = href;
    data['limit'] = limit;
    data['next'] = next;
    data['offset'] = offset;
    data['previous'] = previous;
    data['total'] = total;
    data['items'] = items?.map((v) => v.toJson()).toList();
    return data;
  }
}

class Album {
  String? albumType;
  int? totalTracks;
  String? href;
  String? id;
  List<ImagesModel>? images;
  String? name;
  String? releaseDate;
  String? releaseDatePrecision;
  String? type;
  String? uri;
  List<Artist>? artists;

  Album(
      {this.albumType,
      this.totalTracks,
      this.href,
      this.id,
      this.images,
      this.name,
      this.releaseDate,
      this.releaseDatePrecision,
      this.type,
      this.uri,
      this.artists});

  Album.fromJson(Map<String, dynamic> json) {
    albumType = json['album_type'];
    totalTracks = json['total_tracks'];
    href = json['href'];
    id = json['id'];
    if (json['images'] != null) {
      images = <ImagesModel>[];
      json['images'].forEach((v) {
        images!.add(ImagesModel.fromJson(v));
      });
    }
    name = json['name'];
    releaseDate = json['release_date'];
    releaseDatePrecision = json['release_date_precision'];
    type = json['type'];
    uri = json['uri'];
    if (json['artists'] != null) {
      artists = <Artist>[];
      json['artists'].forEach((v) {
        artists!.add(Artist.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['album_type'] = albumType;
    data['total_tracks'] = totalTracks;
    data['href'] = href;
    data['id'] = id;
    data['images'] = images?.map((v) => v.toJson()).toList();
    data['name'] = name;
    data['release_date'] = releaseDate;
    data['release_date_precision'] = releaseDatePrecision;
    data['type'] = type;
    data['uri'] = uri;
    data['artists'] = artists?.map((v) => v.toJson()).toList();

    return data;
  }
}
