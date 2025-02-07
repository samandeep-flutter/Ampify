import 'package:ampify/data/data_models/common/artist_model.dart';
import 'package:ampify/data/data_models/common/other_models.dart';
import 'package:ampify/services/extension_services.dart';
import 'package:equatable/equatable.dart';

class LibraryModel extends Equatable {
  final String? id;
  final String? albumId;
  final String? image;
  final String? name;
  final LibItemType? type;
  final OwnerModel? owner;

  const LibraryModel({
    this.id,
    this.image,
    this.name,
    this.type,
    this.owner,
    this.albumId,
  });

  factory LibraryModel.fromJson(Map<String, dynamic> json) {
    OwnerModel? owner;
    String? images;
    String? type;
    if (json['type'] == 'playlist') {
      owner = OwnerModel.fromJson(json['owner']);
      type = json['type'];
    } else {
      final artist = List<Artist>.from(json['artists']?.map((e) {
            return Artist.fromJson(e);
          }) ??
          []);
      if (json['type'] == 'album') {
        owner = OwnerModel(id: artist.first.id, name: artist.asString);
        type = json['album_type'];
      } else {
        owner = OwnerModel(id: artist.first.id, name: artist.asString);
        type = json['type'];
      }
    }

    if (json['type'] == 'track') {
      images = json['album']?['images'];
    } else {
      if (json['images'] is String) {
        images = json['images'];
      } else {
        images = (json['images'] as List?)?.first['url'];
      }
    }

    return LibraryModel(
      id: json['id'],
      albumId: json['album']?['id'],
      image: images,
      name: json['name'],
      type: LibItemType.values.firstWhere((e) => e.name == type),
      owner: owner,
    );
  }

  @override
  List<Object?> get props => [id, image, name, type, owner, albumId];
}

enum LibItemType { playlist, album, track, single, compilation }
