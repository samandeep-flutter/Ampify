import 'images_models.dart';

class ArtistModel {
  String? href;
  int? limit;
  String? next;
  int? offset;
  dynamic previous;
  int? total;
  List<Artist>? items;

  ArtistModel(
      {this.href,
      this.limit,
      this.next,
      this.offset,
      this.previous,
      this.total,
      this.items});

  ArtistModel.fromJson(Map<String, dynamic> json) {
    href = json['href'];
    limit = json['limit'];
    next = json['next'];
    offset = json['offset'];
    previous = json['previous'];
    total = json['total'];
    if (json['items'] != null) {
      items = <Artist>[];
      json['items'].forEach((v) {
        items!.add(Artist.fromJson(v));
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

class Artist {
  Followers? followers;
  List<String>? genres;
  String? href;
  String? id;
  List<ImagesModel>? images;
  String? name;
  int? popularity;
  String? type;
  String? uri;

  Artist({
    this.followers,
    this.genres,
    this.href,
    this.id,
    this.images,
    this.name,
    this.popularity,
    this.type,
    this.uri,
  });

  Artist.fromJson(Map<String, dynamic> json) {
    followers = json['followers'] != null
        ? Followers.fromJson(json['followers'])
        : null;
    genres = json['genres']?.cast<String>();
    href = json['href'];
    id = json['id'];
    if (json['images'] != null) {
      images = <ImagesModel>[];
      json['images'].forEach((v) {
        images!.add(ImagesModel.fromJson(v));
      });
    }
    name = json['name'];
    popularity = json['popularity'];
    type = json['type'];
    uri = json['uri'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['followers'] = followers?.toJson();
    data['genres'] = genres;
    data['href'] = href;
    data['id'] = id;
    data['images'] = images?.map((v) => v.toJson()).toList();
    data['name'] = name;
    data['popularity'] = popularity;
    data['type'] = type;
    data['uri'] = uri;
    return data;
  }
}

class Followers {
  String? href;
  int? total;

  Followers({this.href, this.total});

  Followers.fromJson(Map<String, dynamic> json) {
    href = json['href'];
    total = json['total'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['href'] = href;
    data['total'] = total;
    return data;
  }
}
