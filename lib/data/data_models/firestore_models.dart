import 'package:ampify/buisness_logic/library_bloc/library_bloc.dart';
import 'package:ampify/data/utils/exports.dart';

class LibResponseModel extends Equatable {
  final SortOrder? sortby;
  final LibItemType? filterSel;
  final DateTime? updatedAt;

  const LibResponseModel({
    required this.sortby,
    required this.filterSel,
    required this.updatedAt,
  });

  factory LibResponseModel.fromJson(Map<String, dynamic>? json) {
    return LibResponseModel(
      sortby: SortOrder.values
          .firstWhereOrNull((e) => e.name == json?['sort_order']),
      filterSel: LibItemType.values
          .firstWhereOrNull((e) => e.id == json?['filter_order']),
      updatedAt: json?['updated_at'],
    );
  }

  Map<String, dynamic> toJson() => {
        'sort_order': sortby,
        'filter_order': filterSel,
        'updated_at': updatedAt,
      };

  @override
  List<Object?> get props => [sortby, filterSel];
}

class LibDbModel extends Equatable {
  final LibraryModel item;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const LibDbModel({
    required this.item,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LibDbModel.fromJson(Map<String, dynamic> json) {
    return LibDbModel(
      item: LibraryModel.fromJson(json['item']),
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  // TODO: add id, updated_at, and created at checks
  // Map<String, dynamic> toJson() => {
  //       'item': item.toJson(),
  //       'created_at': createdAt,
  //       'updated_at': updatedAt ?? createdAt,
  //     };

  @override
  List<Object?> get props => [item, createdAt, updatedAt];
}

class TrackDbModel extends Equatable {
  final String id;
  final DateTime? addedAt;
  final Track item;

  const TrackDbModel({
    required this.id,
    required this.addedAt,
    required this.item,
  });

  factory TrackDbModel.fromJson(Map<String, dynamic> json) {
    return TrackDbModel(
      id: json['id'],
      item: Track.fromJson(json['track']),
      addedAt: json['added_at'],
    );
  }

  Map<String, dynamic> toJson() =>
      {'id': id, 'track': item.toJson(), 'added_at': addedAt};

  @override
  List<Object?> get props => [item, addedAt];
}
