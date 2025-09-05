import 'package:ampify/data/data_models/common/album_model.dart';
import 'package:ampify/data/data_models/common/artist_model.dart';
import 'package:ampify/data/data_models/common/other_models.dart';
import 'package:ampify/data/data_models/common/tracks_model.dart';
import 'package:ampify/services/extension_services.dart';
import 'package:equatable/equatable.dart';

class LibraryModel extends Equatable {
  final String? id;
  final String? name;
  final String? image;
  final String? albumId;
  final LibItemType? type;
  final OwnerModel? owner;
  final String? uri;

  /// only available for library albums.
  final DateTime? addedAt;

  /// only available in playlists.
  final String? snapId;

  const LibraryModel({
    this.id,
    this.image,
    this.name,
    this.type,
    this.owner,
    this.addedAt,
    this.albumId,
    this.snapId,
    this.uri,
  });

  factory LibraryModel.fromJson(Map<String, dynamic> json) {
    OwnerModel? owner;
    String? images;
    String? type;

    // get owner and type respectively
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

    // get image url respectively.
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
      owner: owner,
      image: images,
      name: json['name'],
      albumId: json['album']?['id'],
      type: LibItemType.values.firstWhere((e) => e.name == type),
      addedAt: DateTime.tryParse(json['added_at'] ?? ''),
      snapId: json['snapshot_id'],
      uri: json['uri'],
    );
  }

  Track get asTrack {
    final artists = owner?.name?.split(',') ?? [];
    return Track(
      id: id,
      name: name,
      type: type?.name,
      album: Album(image: image, id: albumId),
      artists: List<Artist>.from(
        artists.map((e) => Artist(name: e)),
      ),
      uri: uri,
    );
  }

  @override
  List<Object?> get props => [
        id,
        image,
        name,
        type,
        owner,
        albumId,
        uri,
        snapId,
        addedAt,
      ];
}

enum LibItemType { playlist, album, track, single, compilation }
