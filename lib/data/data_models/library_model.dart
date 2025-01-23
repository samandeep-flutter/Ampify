import 'package:ampify/data/data_models/common/artist_model.dart';
import 'package:ampify/data/data_models/common/other_models.dart';
import 'package:equatable/equatable.dart';

class LibraryModel extends Equatable {
  final String? id;
  final ImagesModel? image;
  final String? name;
  final LibItemType? type;
  final String? owner;

  const LibraryModel({this.id, this.image, this.name, this.type, this.owner});

  factory LibraryModel.fromJson(Map<String, dynamic> json) {
    String? owner;
    if (json['type'] == 'playlist') {
      owner = OwnerModel.fromJson(json['owner']).displayName;
    }
    if (json['type'] == 'album') {
      owner = Artist.fromJson((json['artists'] as List?)?.first).name;
    }
    return LibraryModel(
      id: json['id'],
      image: (json['images'] as List?)?.isNotEmpty ?? false
          ? ImagesModel.fromJson((json['images'] as List?)?.first)
          : null,
      name: json['name'],
      type: LibItemType.values.firstWhere((e) => e.name == json['type']),
      owner: owner ?? '',
    );
  }

  @override
  List<Object?> get props => [id, image, name, type, owner];
}

enum LibItemType { playlist, album }
