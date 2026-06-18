import 'package:ampify/buisness_logic/library_bloc/library_bloc.dart';
import 'package:ampify/data/utils/exports.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LibResponseModel extends Equatable {
  final SortOrder? sortby;
  final LibItemType? filterSel;
  final List<LibDbModel> items;

  const LibResponseModel({
    required this.sortby,
    required this.filterSel,
    required this.items,
  });

  factory LibResponseModel.fromJson(Map<String, dynamic>? json) {
    return LibResponseModel(
      sortby: SortOrder.values
          .firstWhereOrNull((e) => e.name == json?['sort_order']),
      filterSel: LibItemType.values
          .firstWhereOrNull((e) => e.id == json?['filter_order']),
      items: List<LibDbModel>.from(
          (json?['items'] as List? ?? []).map((e) => LibDbModel.fromJson(e))),
    );
  }

  Map<String, dynamic> toJson() => {
        'sort_order': sortby,
        'filter_order': filterSel,
        'items': items.map((e) => e.toJson()).toList(),
      };

  @override
  List<Object?> get props => [sortby, filterSel, items];
}

class LibDbModel extends Equatable {
  final LibraryModel item;
  final DateTime addedAt;

  const LibDbModel({required this.item, required this.addedAt});

  factory LibDbModel.fromJson(Map<String, dynamic> json) {
    return LibDbModel(
        item: LibraryModel.fromJson(json['item']), addedAt: json['added_at']);
  }

  Map<String, dynamic> toJson() =>
      {'item': item.toJson(), 'added_at': FieldValue.serverTimestamp()};

  @override
  List<Object?> get props => [item, addedAt];
}
