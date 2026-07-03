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
  final String id;
  final LibraryModel item;
  final String? owner;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const LibDbModel({
    required this.id,
    required this.item,
    required this.owner,
    required this.createdAt,
    required this.updatedAt,
  });

  LibDbModel.fromLibrary(
    this.item, {
    this.owner,
    required this.id,
  })  : createdAt = DateTime.timestamp(),
        updatedAt = DateTime.timestamp();

  factory LibDbModel.fromJson(Map<String, dynamic> json) {
    return LibDbModel(
      id: json['id'],
      owner: json['owner'],
      item: LibraryModel.fromJson(json['item']),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'owner': owner,
        'item': item.toJson(),
        'created_at': createdAt.toString(),
        'updated_at': updatedAt.toString(),
      };

  @override
  List<Object?> get props => [id, item, owner, createdAt, updatedAt];
}

class TrackDbModel extends Equatable {
  final String docId;
  final String trackId;
  final DateTime? addedAt;
  final Track item;

  const TrackDbModel({
    required this.docId,
    required this.trackId,
    required this.addedAt,
    required this.item,
  });

  TrackDbModel.fromTrack(
    this.item, {
    required this.docId,
  })  : addedAt = DateTime.timestamp(),
        trackId = item.id;

  factory TrackDbModel.fromJson(Map<String, dynamic> json) {
    return TrackDbModel(
      docId: json['doc_id'],
      trackId: json['track_id'],
      item: Track.fromJson(json['track']),
      addedAt: DateTime.parse(json['added_at']),
    );
  }

  Map<String, dynamic> toJson() => {
        'doc_id': docId,
        'track_id': trackId,
        'track': item.toJson(),
        'added_at': addedAt.toString()
      };

  @override
  List<Object?> get props => [docId, trackId, item, addedAt];

  @override
  bool operator ==(Object other) {
    return other is TrackDbModel && docId == other.docId;
  }

  @override
  int get hashCode => docId.hashCode;
}
